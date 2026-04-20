---
evaluator:
  command: npm audit --audit-level=high
  format: text
---

Focus only on application-level security: input handling, auth, deps, secrets.
Do not broaden into infrastructure, deployment, or network-level concerns.
Do not modify CI/CD pipelines, Dockerfiles, or cloud configuration.
Do not change existing API contracts — fixes must be backward-compatible.
