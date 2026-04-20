---
evaluator:
  command: npm test -- --coverage --coverageReporters=json-summary
  format: json
---

Focus only on test coverage for existing application code.
Do not broaden into writing new features, refactoring production code, or changing build config.
Do not delete or skip existing tests.
Do not introduce test utilities or frameworks beyond what the project already uses.
