#!/usr/bin/env node

const assert = require("node:assert/strict");
const { validate } = require("./validate-findings.cjs");

function trace() {
  return [
    { kind: "entrypoint", file: "src/router.ts", line: 10, scope: "deleteUser", description: "Принимает id записи." },
    { kind: "sink", file: "src/store.ts", line: 31, scope: "delete", description: "Удаляет запись без owner check." },
  ];
}

function evidence() {
  return [{ file: "src/store.ts", line: 31, description: "Перед удалением не вызывается проверка владельца." }];
}

function confirmed(overrides = {}) {
  return {
    verdict: "confirmed",
    fingerprint: "src-store-delete-owner",
    title: "Удаление записи без проверки владельца",
    description: "Нижнеуровневый handler принимает id и удаляет чужую запись.",
    root_cause: "Проверка owner отсутствует в delete handler.",
    intended_behavior: "Удалять только ресурс текущего principal.",
    trace: trace(),
    evidence: evidence(),
    conditions: [],
    execution: {
      attacker_perspective: "Аутентифицированный dummy user без доступа к записи.",
      payloads: ["id=dummy-other-user-record"],
      instructions: ["Вызвать локальный handler с dummy principal и чужим dummy id."],
      observed_result: "Чужая dummy-запись удалена.",
    },
    remediation: { strategy: "Проверять owner/tenant до delete.", code_changes: [] },
    severity: {
      likelihood: { score: "high", reason: "Handler достижим из entrypoint." },
      impact: { score: "high", reason: "Чужой ресурс изменяется." },
      overall_severity: "high",
    },
    confidence: { score: "high", reason: "Trace и local fixture совпадают." },
    ...overrides,
  };
}

function needsValidation() {
  return {
    verdict: "needs_validation",
    fingerprint: "src-router-proxy-auth",
    title: "Внешняя auth boundary не наблюдается",
    description: "Source path зависит от deployment middleware.",
    claimed_root_cause: "Handler может быть доступен без authentication.",
    trace: [{ kind: "entrypoint", file: "src/router.ts", line: 10, scope: "route", description: "Регистрирует route." }],
    evidence: evidence(),
    blockers: ["В репозитории нет конфигурации reverse proxy."],
    validation_plan: { deployment: "Владелец проверяет effective route policy в тестовом окружении." },
  };
}

assert.deepEqual(validate([]), []);
assert.deepEqual(validate([confirmed()]), []);
assert.deepEqual(validate([needsValidation()]), []);
assert.doesNotThrow(() => validate([{ verdict: "confirmed", trace: [null, null] }]));
assert.notEqual(validate([confirmed({ needs_validation: true })]).length, 0);
assert.notEqual(validate([confirmed(), confirmed()]).length, 0);
assert.notEqual(validate([needsValidation(), { ...needsValidation(), severity: { overall_severity: "high" } }]).length, 0);
console.log("validate-findings.test.cjs: ok");
