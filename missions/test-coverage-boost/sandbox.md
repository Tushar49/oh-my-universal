---
evaluator:
  command: npm test -- --coverage --coverageReporters=json-summary
  format: json
  keep_policy: score_improvement
---

Focus only on test coverage for existing application code.

Allowed changes:
- tests/**
- __tests__/**
- *.test.ts, *.test.js, *.spec.ts, *.spec.js
- jest.config.* (coverage thresholds only)

Avoid:
- Writing new features or refactoring production code
- Changing build configuration
- Deleting or skipping existing tests
- Introducing test utilities or frameworks beyond what the project already uses
