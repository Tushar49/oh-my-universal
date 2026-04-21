---
evaluator:
  command: npm run build && npm test
  format: json
  keep_policy: score_improvement
---

Focus only on measurable performance improvements with before/after evidence.

Allowed changes:
- src/**/*.ts, src/**/*.js (hot-path optimizations)
- benchmarks/**
- performance test fixtures

Avoid:
- Architectural redesign, caching strategies, or infrastructure scaling
- Changing public APIs or database schemas
- Adding new dependencies for profiling — use built-in tools and existing dev dependencies
- Micro-optimizations without measurable impact
