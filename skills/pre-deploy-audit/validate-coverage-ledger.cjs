#!/usr/bin/env node

// Zero-dependency validator for the deterministic coverage ledger.
// Usage: node validate-coverage-ledger.cjs <coverage-ledger.json>

const fs = require("node:fs");

const MAX_BYTES = 5 * 1024 * 1024;
const MAX_UNITS = 10000;
const MAX_DEPTH = 64;
const MAX_COLLECTION = 1000;
const STATUSES = new Set(["planned", "in_progress", "covered", "candidate", "blocked", "deferred", "out_of_scope", "not_applicable"]);
const PRIOR_STATUSES = new Set([
  "new", "prior_confirmed_same_source", "prior_confirmed_changed_source", "prior_needs_validation",
  "prior_deferred", "prior_blocked", "prior_out_of_scope", "prior_covered_same_source",
  "prior_covered_changed_source", "prior_rejected_claim_changed", "none",
]);
const WINDOWS_DEVICE_NAMES = new Set([
  "con", "prn", "aux", "nul", "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9",
  "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9",
]);

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function visible(value) {
  return typeof value === "string"
    && value.length > 0
    && value.trim() === value
    && value.normalize("NFC") === value
    && !/[\u0000-\u001f\u007f\u2028\u2029]/u.test(value)
    && !/\p{Default_Ignorable_Code_Point}/u.test(value);
}

function relativePath(value) {
  if (typeof value !== "string" || value.length === 0 || value.includes("\\")) return false;
  if (value.startsWith("/") || /^[A-Za-z]:/.test(value)) return false;
  return !value.split("/").some((part) => part === ".." || part === "");
}

function safeAgentId(value) {
  if (typeof value !== "string" || !/^[a-z0-9][a-z0-9_-]{0,63}$/u.test(value)) return false;
  return !WINDOWS_DEVICE_NAMES.has(value);
}

function add(errors, location, message) {
  errors.push(`${location}: ${message}`);
}

function required(value, fields, location, errors) {
  for (const field of fields) {
    if (!Object.prototype.hasOwnProperty.call(value, field)) add(errors, location, `missing required field ${field}`);
  }
}

function keys(value, allowed, location, errors) {
  if (!isObject(value)) {
    add(errors, location, "must be an object");
    return;
  }
  for (const key of Object.keys(value)) if (!allowed.has(key)) add(errors, `${location}.${JSON.stringify(key)}`, "unknown field");
}

function encodePart(value) {
  return encodeURIComponent(value).replace(/[!'()*]/gu, (char) => `%${char.charCodeAt(0).toString(16).toUpperCase()}`);
}

function expectedCoverageId(refs) {
  const fields = ["surface", "boundary", "subsystem", "attack_class"];
  const encoded = fields.map((field) => encodePart(refs[field]));
  if (Object.prototype.hasOwnProperty.call(refs, "lifecycle")) encoded.push(encodePart(refs.lifecycle));
  return encoded.join("::");
}

function checkStringArray(value, location, errors, { allowEmpty = true, paths = false } = {}) {
  if (!Array.isArray(value) || value.length > MAX_COLLECTION || (!allowEmpty && value.length === 0)) {
    add(errors, location, allowEmpty ? "must be an array within the size limit" : "must be a non-empty array within the size limit");
    return;
  }
  value.forEach((item, index) => {
    if (typeof item !== "string" || item.length === 0 || (paths ? !relativePath(item) : !visible(item))) {
      add(errors, `${location}[${index}]`, paths ? "must be a repository-relative path" : "must be visible text");
    }
  });
}

function checkCheck(value, location, errors) {
  const allowed = new Set(["agent_id", "method", "artifact", "reviewed_paths", "invariant", "result"]);
  keys(value, allowed, location, errors);
  if (!isObject(value)) return;
  required(value, [...allowed], location, errors);
  if (!safeAgentId(value.agent_id)) add(errors, `${location}.agent_id`, "must be a canonical lowercase agent ID");
  if (!["source", "local"].includes(value.method)) add(errors, `${location}.method`, "must be source or local");
  if (value.method === "source" && value.artifact !== null) add(errors, `${location}.artifact`, "source-only check must use null artifact");
  if (value.method === "local") {
    const prefix = `agents/${value.agent_id}/artifacts/`;
    if (typeof value.artifact !== "string" || !value.artifact.startsWith(prefix) || !relativePath(value.artifact)) {
      add(errors, `${location}.artifact`, "local artifact must belong to the check owner");
    }
  }
  checkStringArray(value.reviewed_paths, `${location}.reviewed_paths`, errors, { allowEmpty: false, paths: true });
  if (!visible(value.invariant)) add(errors, `${location}.invariant`, "must be visible text");
  if (!visible(value.result)) add(errors, `${location}.result`, "must be visible text");
}

function checkAttempts(value, location, errors) {
  if (value === undefined) return;
  if (!Array.isArray(value) || value.length > MAX_COLLECTION) {
    add(errors, location, "must be an array within the size limit");
    return;
  }
  value.forEach((attempt, index) => {
    const attemptLocation = `${location}[${index}]`;
    if (!isObject(attempt)) {
      add(errors, attemptLocation, "must be an object");
      return;
    }
    required(attempt, ["wave", "status", "agent_id", "reviewed_paths", "local_checks", "result_fingerprints", "unresolved"], attemptLocation, errors);
    if (!Number.isInteger(attempt.wave) || attempt.wave < 1) add(errors, `${attemptLocation}.wave`, "must be a positive integer");
    if (!STATUSES.has(attempt.status) || attempt.status === "planned" || attempt.status === "in_progress") add(errors, `${attemptLocation}.status`, "archived attempt must be terminal or blocked");
    if (attempt.agent_id !== null && !safeAgentId(attempt.agent_id)) add(errors, `${attemptLocation}.agent_id`, "invalid archived agent ID");
    checkStringArray(attempt.reviewed_paths, `${attemptLocation}.reviewed_paths`, errors, { paths: true });
    if (!Array.isArray(attempt.local_checks)) add(errors, `${attemptLocation}.local_checks`, "must be an array");
    else attempt.local_checks.forEach((check, checkIndex) => checkCheck(check, `${attemptLocation}.local_checks[${checkIndex}]`, errors));
    checkStringArray(attempt.result_fingerprints, `${attemptLocation}.result_fingerprints`, errors);
    checkStringArray(attempt.unresolved, `${attemptLocation}.unresolved`, errors);
  });
}

function checkUnit(unit, index, errors) {
  const location = `$[${index}]`;
  if (!isObject(unit)) {
    add(errors, location, "must be an object");
    return null;
  }
  const allowed = new Set([
    "coverage_id", "canonical_refs", "surface", "boundary", "subsystem", "attack_class", "lifecycle",
    "starting_paths", "ordinary_attack_class_block", "selected_companion_blocks", "excluded_blocks",
    "prior_status", "attempts", "wave", "status", "agent_id", "reviewed_paths", "local_checks",
    "result_fingerprints", "unresolved", "priority", "notes", "assignment_reason",
  ]);
  keys(unit, allowed, location, errors);
  required(unit, [
    "coverage_id", "canonical_refs", "surface", "boundary", "subsystem", "attack_class",
    "starting_paths", "ordinary_attack_class_block", "selected_companion_blocks", "excluded_blocks",
    "prior_status", "wave", "status", "agent_id", "reviewed_paths", "local_checks",
    "result_fingerprints", "unresolved",
  ], location, errors);

  const refs = unit.canonical_refs;
  const refKeys = new Set(["surface", "boundary", "subsystem", "attack_class", "lifecycle"]);
  keys(refs, refKeys, `${location}.canonical_refs`, errors);
  if (isObject(refs)) {
    required(refs, ["surface", "boundary", "subsystem", "attack_class"], `${location}.canonical_refs`, errors);
    for (const field of ["surface", "boundary", "subsystem", "attack_class"]) {
      if (!visible(refs[field])) add(errors, `${location}.canonical_refs.${field}`, "must be visible canonical text");
    }
    if (Object.prototype.hasOwnProperty.call(refs, "lifecycle") && !visible(refs.lifecycle)) add(errors, `${location}.canonical_refs.lifecycle`, "must be visible canonical text");
    if (isObject(refs) && ["surface", "boundary", "subsystem", "attack_class"].every((field) => visible(refs[field]))) {
      const expected = expectedCoverageId(refs);
      if (unit.coverage_id !== expected) add(errors, `${location}.coverage_id`, "does not match canonical references");
    }
  }
  if (!visible(unit.coverage_id)) add(errors, `${location}.coverage_id`, "must be visible text");
  for (const field of ["surface", "boundary", "subsystem", "attack_class"]) {
    if (!visible(unit[field])) add(errors, `${location}.${field}`, "must be visible text");
    if (isObject(refs) && visible(refs[field]) && unit[field] !== refs[field]) add(errors, `${location}.${field}`, "must match canonical_refs");
  }
  if (unit.lifecycle !== undefined && !visible(unit.lifecycle)) add(errors, `${location}.lifecycle`, "must be visible text");
  if (isObject(refs) && refs.lifecycle !== undefined && unit.lifecycle !== refs.lifecycle) add(errors, `${location}.lifecycle`, "must match canonical_refs.lifecycle");
  checkStringArray(unit.starting_paths, `${location}.starting_paths`, errors, { allowEmpty: false, paths: true });
  if (unit.ordinary_attack_class_block !== null && !visible(unit.ordinary_attack_class_block)) add(errors, `${location}.ordinary_attack_class_block`, "must be visible text or null");
  checkStringArray(unit.selected_companion_blocks, `${location}.selected_companion_blocks`, errors);
  if (!Array.isArray(unit.excluded_blocks) || unit.excluded_blocks.length > MAX_COLLECTION) add(errors, `${location}.excluded_blocks`, "must be an array within the size limit");
  else unit.excluded_blocks.forEach((entry, entryIndex) => {
    const entryLocation = `${location}.excluded_blocks[${entryIndex}]`;
    keys(entry, new Set(["block", "reason"]), entryLocation, errors);
    if (!isObject(entry)) return;
    required(entry, ["block", "reason"], entryLocation, errors);
    if (!visible(entry.block) || !visible(entry.reason)) add(errors, entryLocation, "block and reason must be visible text");
  });
  if (!PRIOR_STATUSES.has(unit.prior_status)) add(errors, `${location}.prior_status`, "invalid prior status");
  if (!Number.isInteger(unit.wave) || unit.wave < 1) add(errors, `${location}.wave`, "must be a positive integer");
  if (!STATUSES.has(unit.status)) add(errors, `${location}.status`, "invalid ledger status");
  if (unit.agent_id !== null && !safeAgentId(unit.agent_id)) add(errors, `${location}.agent_id`, "must be null or a canonical lowercase agent ID");
  checkStringArray(unit.reviewed_paths, `${location}.reviewed_paths`, errors, { paths: true });
  if (!Array.isArray(unit.local_checks) || unit.local_checks.length > MAX_COLLECTION) add(errors, `${location}.local_checks`, "must be an array within the size limit");
  else unit.local_checks.forEach((check, checkIndex) => checkCheck(check, `${location}.local_checks[${checkIndex}]`, errors));
  checkStringArray(unit.result_fingerprints, `${location}.result_fingerprints`, errors);
  checkStringArray(unit.unresolved, `${location}.unresolved`, errors);
  checkAttempts(unit.attempts, `${location}.attempts`, errors);

  if (Array.isArray(unit.local_checks) && Array.isArray(unit.reviewed_paths)) {
    const checkPaths = new Set(unit.local_checks.flatMap((check) => Array.isArray(check.reviewed_paths) ? check.reviewed_paths : []));
    const unitPaths = new Set(unit.reviewed_paths);
    if (checkPaths.size !== unitPaths.size || [...checkPaths].some((path) => !unitPaths.has(path))) add(errors, `${location}.reviewed_paths`, "must equal the union of check reviewed_paths");
  }

  const reviewedPaths = Array.isArray(unit.reviewed_paths) ? unit.reviewed_paths : [];
  const localChecks = Array.isArray(unit.local_checks) ? unit.local_checks : [];
  const resultFingerprints = Array.isArray(unit.result_fingerprints) ? unit.result_fingerprints : [];
  const unresolved = Array.isArray(unit.unresolved) ? unit.unresolved : [];
  const evidenceEmpty = reviewedPaths.length === 0 && localChecks.length === 0 && resultFingerprints.length === 0;
  if (unit.status === "planned") {
    if (unit.agent_id !== null || !evidenceEmpty || unresolved.length !== 0) add(errors, location, "planned unit must be unassigned and empty");
  } else if (unit.status === "in_progress") {
    if (!safeAgentId(unit.agent_id) || !evidenceEmpty || unresolved.length !== 0) add(errors, location, "in_progress unit must have only a canonical owner");
  } else if (["deferred", "out_of_scope", "not_applicable"].includes(unit.status)) {
    if (unit.agent_id !== null || !evidenceEmpty || unresolved.length === 0) add(errors, location, "deferred/out_of_scope/not_applicable unit needs only a reason");
  } else if (unit.status === "blocked") {
    if (!safeAgentId(unit.agent_id) || reviewedPaths.length === 0 || localChecks.length === 0 || resultFingerprints.length !== 0 || unresolved.length === 0) add(errors, location, "blocked unit needs owned partial evidence and a blocker");
  } else if (unit.status === "covered") {
    if (!safeAgentId(unit.agent_id) || reviewedPaths.length === 0 || localChecks.length === 0 || resultFingerprints.length !== 0 || unresolved.length !== 0) add(errors, location, "covered unit needs complete owned evidence");
  } else if (unit.status === "candidate") {
    if (!safeAgentId(unit.agent_id) || reviewedPaths.length === 0 || localChecks.length === 0 || resultFingerprints.length === 0) add(errors, location, "candidate unit needs evidence and a fingerprint");
  }
  return unit.coverage_id;
}

function depthOf(value, depth = 0) {
  if (depth > MAX_DEPTH) return depth;
  if (!value || typeof value !== "object") return depth;
  const children = Array.isArray(value) ? value : Object.values(value);
  return children.reduce((max, child) => Math.max(max, depthOf(child, depth + 1)), depth);
}

function validate(value) {
  const errors = [];
  if (!Array.isArray(value)) {
    add(errors, "$", "top level must be an array");
    return errors;
  }
  if (value.length > MAX_UNITS) add(errors, "$", "too many coverage units");
  if (depthOf(value) > MAX_DEPTH) add(errors, "$", "nesting depth exceeds limit");
  const IDs = new Set();
  const semanticTuples = new Set();
  let previousID = null;
  value.forEach((unit, index) => {
    const ID = checkUnit(unit, index, errors);
    if (ID !== null) {
      if (IDs.has(ID)) add(errors, `$[${index}].coverage_id`, "duplicate coverage ID");
      IDs.add(ID);
      if (previousID !== null && ID < previousID) add(errors, "$", "units must be sorted lexicographically by coverage_id");
      previousID = ID;
    }
    if (isObject(unit) && isObject(unit.canonical_refs)) {
      const refs = unit.canonical_refs;
      const tuple = [refs.surface, refs.boundary, refs.subsystem, refs.attack_class, refs.lifecycle || ""].join("\u0000");
      if (semanticTuples.has(tuple)) add(errors, `$[${index}].canonical_refs`, "semantic tuple already uses another coverage ID");
      semanticTuples.add(tuple);
    }
  });
  return errors;
}

function readInput(inputPath) {
  let stat;
  try { stat = fs.lstatSync(inputPath); } catch { throw new Error("cannot read coverage ledger input"); }
  if (!stat.isFile() || stat.isSymbolicLink()) throw new Error("coverage ledger input must be a regular file");
  if (stat.size > MAX_BYTES) throw new Error("coverage ledger input exceeds size limit");
  return fs.readFileSync(inputPath, "utf8");
}

function main(argv) {
  if (argv.length !== 3) {
    console.error("Usage: node validate-coverage-ledger.cjs <coverage-ledger.json>");
    return 2;
  }
  let value;
  try { value = JSON.parse(readInput(argv[2])); }
  catch (error) { console.error(`Failed to read coverage ledger: ${error.message}`); return 1; }
  const errors = validate(value);
  if (errors.length > 0) {
    console.error(`Invalid coverage-ledger.json (${errors.length} error${errors.length === 1 ? "" : "s"})`);
    errors.slice(0, 100).forEach((error) => console.error(error));
    if (errors.length > 100) console.error("Further errors omitted.");
    return 1;
  }
  console.log("coverage-ledger.json: valid");
  return 0;
}

if (require.main === module) process.exitCode = main(process.argv);
module.exports = { validate, expectedCoverageId };
