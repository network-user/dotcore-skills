#!/usr/bin/env node

// Zero-dependency validator for report-schema.json.
// Usage: node validate-findings.cjs <findings.json>

const fs = require("node:fs");

const MAX_BYTES = 5 * 1024 * 1024;
const MAX_RECORDS = 1000;
const MAX_DEPTH = 64;
const SEVERITIES = ["informational", "low", "medium", "high", "critical"];
const SEVERITY_RANK = Object.fromEntries(SEVERITIES.map((value, index) => [value, index]));
const TRACE_KINDS = new Set(["entrypoint", "propagation", "sink"]);
const CONDITION_KINDS = new Set([
  "authentication_level", "authorization_role", "user_interaction",
  "system_configuration", "network_routing", "environmental_dependency",
  "data_state", "timing_dependency", "third_party_dependency",
]);

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isVisible(value) {
  return typeof value === "string" && value.trim().length > 0 && !/[\u0000-\u001f\u007f]/u.test(value);
}

function isRepoPath(value) {
  if (typeof value !== "string" || value.length === 0 || value.includes("\\")) return false;
  if (value.startsWith("/") || /^[A-Za-z]:/.test(value)) return false;
  return !value.split("/").some((part) => part === ".." || part === "");
}

function isFingerprint(value) {
  return typeof value === "string" && /^[A-Za-z0-9][A-Za-z0-9._:/@+-]*$/u.test(value);
}

function add(errors, location, message) {
  errors.push(`${location}: ${message}`);
}

function checkObjectKeys(value, allowed, location, errors) {
  if (!isObject(value)) {
    add(errors, location, "must be an object");
    return;
  }
  for (const key of Object.keys(value)) {
    if (!allowed.has(key)) add(errors, `${location}.${JSON.stringify(key)}`, "unknown field");
  }
}

function required(value, fields, location, errors) {
  for (const field of fields) {
    if (!Object.prototype.hasOwnProperty.call(value, field)) add(errors, location, `missing required field ${field}`);
  }
}

function checkText(value, location, errors) {
  if (!isVisible(value)) add(errors, location, "must be non-empty visible text");
}

function checkPath(value, location, errors) {
  if (!isRepoPath(value)) add(errors, location, "must be a repository-relative path");
}

function checkTrace(value, location, errors) {
  if (!Array.isArray(value) || value.length === 0) {
    add(errors, location, "must be a non-empty array");
    return;
  }
  value.forEach((step, index) => {
    const stepLocation = `${location}[${index}]`;
    checkObjectKeys(step, new Set(["kind", "file", "line", "scope", "description"]), stepLocation, errors);
    if (!isObject(step)) return;
    required(step, ["kind", "file", "line", "scope", "description"], stepLocation, errors);
    if (!TRACE_KINDS.has(step.kind)) add(errors, `${stepLocation}.kind`, "invalid trace kind");
    checkPath(step.file, `${stepLocation}.file`, errors);
    if (!Number.isInteger(step.line) || step.line < 1) add(errors, `${stepLocation}.line`, "must be a positive integer");
    checkText(step.scope, `${stepLocation}.scope`, errors);
    checkText(step.description, `${stepLocation}.description`, errors);
  });
  if (value.length > 1) {
    const firstKind = isObject(value[0]) ? value[0].kind : undefined;
    const lastKind = isObject(value[value.length - 1]) ? value[value.length - 1].kind : undefined;
    if (firstKind !== "entrypoint") add(errors, location, "multi-step trace must start with entrypoint");
    if (lastKind !== "sink") add(errors, location, "multi-step trace must end with sink");
    value.slice(1, -1).forEach((step, index) => {
      if (!isObject(step) || step.kind !== "propagation") add(errors, `${location}[${index + 1}].kind`, "middle trace step must be propagation");
    });
  } else if (!isObject(value[0]) || !["entrypoint", "sink"].includes(value[0].kind)) {
    add(errors, `${location}[0].kind`, "single-step trace must be entrypoint or sink");
  }
}

function checkEvidence(value, location, errors) {
  if (!Array.isArray(value) || value.length === 0) {
    add(errors, location, "must be a non-empty array");
    return;
  }
  value.forEach((item, index) => {
    const itemLocation = `${location}[${index}]`;
    checkObjectKeys(item, new Set(["file", "line", "description"]), itemLocation, errors);
    if (!isObject(item)) return;
    required(item, ["file", "line", "description"], itemLocation, errors);
    checkPath(item.file, `${itemLocation}.file`, errors);
    if (!Number.isInteger(item.line) || item.line < 1) add(errors, `${itemLocation}.line`, "must be a positive integer");
    checkText(item.description, `${itemLocation}.description`, errors);
  });
}

function checkConditions(value, location, errors) {
  if (!Array.isArray(value)) {
    add(errors, location, "must be an array");
    return;
  }
  value.forEach((item, index) => {
    const itemLocation = `${location}[${index}]`;
    checkObjectKeys(item, new Set(["kind", "description"]), itemLocation, errors);
    if (!isObject(item)) return;
    required(item, ["kind", "description"], itemLocation, errors);
    if (!CONDITION_KINDS.has(item.kind)) add(errors, `${itemLocation}.kind`, "invalid condition kind");
    checkText(item.description, `${itemLocation}.description`, errors);
  });
}

function checkExecution(value, location, errors) {
  checkObjectKeys(value, new Set(["attacker_perspective", "payloads", "instructions", "observed_result"]), location, errors);
  if (!isObject(value)) return;
  required(value, ["attacker_perspective", "payloads", "instructions", "observed_result"], location, errors);
  checkText(value.attacker_perspective, `${location}.attacker_perspective`, errors);
  if (!Array.isArray(value.payloads) || value.payloads.length === 0) add(errors, `${location}.payloads`, "must be a non-empty array");
  else value.payloads.forEach((item, index) => { if (typeof item !== "string") add(errors, `${location}.payloads[${index}]`, "must be a string"); });
  if (!Array.isArray(value.instructions) || value.instructions.length === 0) add(errors, `${location}.instructions`, "must be a non-empty array");
  else value.instructions.forEach((item, index) => checkText(item, `${location}.instructions[${index}]`, errors));
  checkText(value.observed_result, `${location}.observed_result`, errors);
}

function checkRemediation(value, location, errors) {
  checkObjectKeys(value, new Set(["strategy", "code_changes"]), location, errors);
  if (!isObject(value)) return;
  required(value, ["strategy"], location, errors);
  checkText(value.strategy, `${location}.strategy`, errors);
  if (value.code_changes === undefined) return;
  if (!Array.isArray(value.code_changes)) {
    add(errors, `${location}.code_changes`, "must be an array");
    return;
  }
  value.code_changes.forEach((change, index) => {
    const changeLocation = `${location}.code_changes[${index}]`;
    checkObjectKeys(change, new Set(["file_name", "fixed_code"]), changeLocation, errors);
    if (!isObject(change)) return;
    required(change, ["file_name", "fixed_code"], changeLocation, errors);
    checkPath(change.file_name, `${changeLocation}.file_name`, errors);
    if (typeof change.fixed_code !== "string") add(errors, `${changeLocation}.fixed_code`, "must be a string");
  });
}

function checkScore(value, location, errors) {
  checkObjectKeys(value, new Set(["score", "reason"]), location, errors);
  if (!isObject(value)) return;
  required(value, ["score", "reason"], location, errors);
  if (!SEVERITIES.includes(value.score)) add(errors, `${location}.score`, "invalid severity score");
  checkText(value.reason, `${location}.reason`, errors);
}

function checkSeverity(value, location, errors) {
  checkObjectKeys(value, new Set(["likelihood", "impact", "overall_severity"]), location, errors);
  if (!isObject(value)) return;
  required(value, ["likelihood", "impact", "overall_severity"], location, errors);
  checkScore(value.likelihood, `${location}.likelihood`, errors);
  checkScore(value.impact, `${location}.impact`, errors);
  if (!SEVERITIES.includes(value.overall_severity)) add(errors, `${location}.overall_severity`, "invalid overall severity");
  if (SEVERITIES.includes(value.impact && value.impact.score) && SEVERITIES.includes(value.overall_severity)
      && SEVERITY_RANK[value.overall_severity] > SEVERITY_RANK[value.impact.score]) {
    add(errors, `${location}.overall_severity`, "cannot exceed demonstrated impact");
  }
}

function checkConfidence(value, location, errors) {
  checkObjectKeys(value, new Set(["score", "reason"]), location, errors);
  if (!isObject(value)) return;
  required(value, ["score", "reason"], location, errors);
  if (!["low", "medium", "high"].includes(value.score)) add(errors, `${location}.score`, "invalid confidence score");
  checkText(value.reason, `${location}.reason`, errors);
}

function checkValidationPlan(value, location, errors) {
  checkObjectKeys(value, new Set(["local", "deployment"]), location, errors);
  if (!isObject(value)) return;
  if (!isVisible(value.local) && !isVisible(value.deployment)) add(errors, location, "requires local or deployment plan");
  if (value.local !== undefined) checkText(value.local, `${location}.local`, errors);
  if (value.deployment !== undefined) checkText(value.deployment, `${location}.deployment`, errors);
}

function validateRecord(record, index, errors) {
  const location = `$[${index}]`;
  if (!isObject(record)) {
    add(errors, location, "must be an object");
    return;
  }
  if (!["confirmed", "needs_validation", "rejected"].includes(record.verdict)) {
    add(errors, `${location}.verdict`, "must be confirmed, needs_validation or rejected");
    return;
  }
  if (!isFingerprint(record.fingerprint)) add(errors, `${location}.fingerprint`, "invalid stable fingerprint");
  for (const field of ["title", "description"]) checkText(record[field], `${location}.${field}`, errors);
  checkTrace(record.trace, `${location}.trace`, errors);
  checkEvidence(record.evidence, `${location}.evidence`, errors);

  if (record.verdict === "confirmed") {
    const allowed = new Set([
      "verdict", "fingerprint", "title", "description", "root_cause", "intended_behavior",
      "trace", "evidence", "conditions", "execution", "remediation", "severity", "confidence",
    ]);
    checkObjectKeys(record, allowed, location, errors);
    required(record, [...allowed], location, errors);
    checkText(record.root_cause, `${location}.root_cause`, errors);
    checkText(record.intended_behavior, `${location}.intended_behavior`, errors);
    checkConditions(record.conditions, `${location}.conditions`, errors);
    checkExecution(record.execution, `${location}.execution`, errors);
    checkRemediation(record.remediation, `${location}.remediation`, errors);
    checkSeverity(record.severity, `${location}.severity`, errors);
    checkConfidence(record.confidence, `${location}.confidence`, errors);
  } else if (record.verdict === "needs_validation") {
    const allowed = new Set([
      "verdict", "fingerprint", "title", "description", "claimed_root_cause",
      "trace", "evidence", "blockers", "validation_plan",
    ]);
    checkObjectKeys(record, allowed, location, errors);
    required(record, [...allowed], location, errors);
    checkText(record.claimed_root_cause, `${location}.claimed_root_cause`, errors);
    if (!Array.isArray(record.blockers) || record.blockers.length === 0) add(errors, `${location}.blockers`, "must be a non-empty array");
    else record.blockers.forEach((item, itemIndex) => checkText(item, `${location}.blockers[${itemIndex}]`, errors));
    checkValidationPlan(record.validation_plan, `${location}.validation_plan`, errors);
  } else {
    const allowed = new Set([
      "verdict", "fingerprint", "title", "description", "claimed_root_cause",
      "trace", "evidence", "reason",
    ]);
    checkObjectKeys(record, allowed, location, errors);
    required(record, [...allowed], location, errors);
    checkText(record.claimed_root_cause, `${location}.claimed_root_cause`, errors);
    checkText(record.reason, `${location}.reason`, errors);
  }
}

function depthOf(value, depth = 0) {
  if (depth > MAX_DEPTH) return depth;
  if (!value || typeof value !== "object") return depth;
  const values = Array.isArray(value) ? value : Object.values(value);
  return values.reduce((max, child) => Math.max(max, depthOf(child, depth + 1)), depth);
}

function validate(value) {
  const errors = [];
  if (!Array.isArray(value)) {
    add(errors, "$", "top level must be an array");
    return errors;
  }
  if (value.length > MAX_RECORDS) add(errors, "$", "too many records");
  if (depthOf(value) > MAX_DEPTH) add(errors, "$", "nesting depth exceeds limit");
  const fingerprints = new Set();
  value.forEach((record, index) => {
    validateRecord(record, index, errors);
    if (isObject(record) && typeof record.fingerprint === "string") {
      if (fingerprints.has(record.fingerprint)) add(errors, `$[${index}].fingerprint`, "duplicate fingerprint");
      fingerprints.add(record.fingerprint);
    }
  });
  return errors;
}

function readInput(inputPath) {
  let stat;
  try { stat = fs.lstatSync(inputPath); } catch { throw new Error("cannot read findings input"); }
  if (!stat.isFile() || stat.isSymbolicLink()) throw new Error("findings input must be a regular file");
  if (stat.size > MAX_BYTES) throw new Error("findings input exceeds size limit");
  return fs.readFileSync(inputPath, "utf8");
}

function main(argv) {
  if (argv.length !== 3) {
    console.error("Usage: node validate-findings.cjs <findings.json>");
    return 2;
  }
  let value;
  try { value = JSON.parse(readInput(argv[2])); }
  catch (error) { console.error(`Failed to read findings: ${error.message}`); return 1; }
  const errors = validate(value);
  if (errors.length > 0) {
    console.error(`Invalid findings.json (${errors.length} error${errors.length === 1 ? "" : "s"})`);
    errors.slice(0, 100).forEach((error) => console.error(error));
    if (errors.length > 100) console.error("Further errors omitted.");
    return 1;
  }
  console.log("findings.json: valid");
  return 0;
}

if (require.main === module) process.exitCode = main(process.argv);
module.exports = { validate };
