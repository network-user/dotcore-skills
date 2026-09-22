#!/usr/bin/env node

const assert = require("node:assert/strict");
const { validate, expectedCoverageId } = require("./validate-coverage-ledger.cjs");

function unit(overrides = {}) {
  const canonical_refs = {
    surface: "src/router.ts#DELETE /users/:id",
    boundary: "src/authz.ts#requireOwner",
    subsystem: "packages/api",
    attack_class: "ATTACK-CLASSES.md#Access control and identity",
  };
  const coverage_id = expectedCoverageId(canonical_refs);
  return {
    coverage_id,
    canonical_refs,
    surface: canonical_refs.surface,
    boundary: canonical_refs.boundary,
    subsystem: canonical_refs.subsystem,
    attack_class: canonical_refs.attack_class,
    starting_paths: ["src/router.ts"],
    ordinary_attack_class_block: "ATTACK-CLASSES.md#Access control and identity",
    selected_companion_blocks: [],
    excluded_blocks: [],
    prior_status: "none",
    wave: 1,
    status: "planned",
    agent_id: null,
    reviewed_paths: [],
    local_checks: [],
    result_fingerprints: [],
    unresolved: [],
    ...overrides,
  };
}

assert.deepEqual(validate([unit()]), []);
assert.doesNotThrow(() => validate([{}]));
assert.notEqual(validate([unit({ coverage_id: "wrong" })]).length, 0);
assert.notEqual(validate([unit(), unit()]).length, 0);
assert.notEqual(validate([unit({ status: "deferred", unresolved: [] })]).length, 0);
assert.notEqual(validate([unit({ status: "in_progress", agent_id: "Hunter-1" })]).length, 0);
console.log("validate-coverage-ledger.test.cjs: ok");
