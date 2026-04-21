---
evaluator:
  command: npm audit --audit-level=high && npm test -- --grep "security"
  format: json
  keep_policy: pass_only
---

Focus only on application-level security: input handling, auth, deps, secrets.

Allowed changes:
- src/**/*.ts (security-related fixes only)
- src/**/*.js (security-related fixes only)
- package.json (dependency version bumps for CVE fixes)
- package-lock.json

Avoid:
- Infrastructure, deployment, or network-level concerns
- CI/CD pipelines, Dockerfiles, or cloud configuration
- Changing existing API contracts — fixes must be backward-compatible
- Adding new dependencies solely for security scanning
