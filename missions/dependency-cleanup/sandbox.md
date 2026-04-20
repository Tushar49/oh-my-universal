---
evaluator:
  command: npm audit --audit-level=high && npm test
  format: text
---

Focus only on dependency management — additions, removals, updates, and lockfile hygiene.
Do not broaden into code refactoring, feature changes, or build system modifications.
Do not change application logic even if a dependency update requires API changes (flag it for manual review instead).
Do not upgrade to pre-release or unstable versions.
