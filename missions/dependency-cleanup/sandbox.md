---
evaluator:
  command: npm audit --audit-level=high && npm outdated --json && npm test
  format: json
  keep_policy: pass_only
---

Focus only on dependency management — additions, removals, updates, and lockfile hygiene.

Allowed changes:
- package.json
- package-lock.json
- yarn.lock
- .npmrc
- import/require statements (only to match updated package APIs)

Avoid:
- Code refactoring, feature changes, or build system modifications
- Changing application logic even if a dependency update requires API changes (flag for manual review)
- Upgrading to pre-release or unstable versions
- Removing dependencies that are used but appear unused due to dynamic imports
