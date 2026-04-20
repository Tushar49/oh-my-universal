# Mission: Performance Baseline

Establish performance baselines and fix obvious bottlenecks. Measure first, optimize second, measure again.

## Goal

Create measurable performance baselines for critical paths and fix the top 3 most impactful bottlenecks, proving improvement with before/after numbers.

## Focus Areas

- Database queries (N+1 patterns, missing indexes, unoptimized joins)
- Bundle size and asset loading (large dependencies, unoptimized imports)
- Slow API endpoints and request handlers
- Memory leaks and unnecessary allocations
- Hot loops and algorithmic inefficiency

## Success Criteria

1. `perf-audit` skill produces a documented baseline with metrics for at least 5 critical paths
2. Top 3 bottlenecks identified and fixed with before/after measurements
3. No performance regression in non-targeted areas (baseline metrics hold)
4. Bundle size (if applicable) does not increase; ideally decreases
5. All fixes pass existing tests — no correctness regressions

## Constraints

- Do not optimize prematurely — measure first, prove the bottleneck exists
- Do not sacrifice code readability for micro-optimizations
- Do not change database schema unless the N+1 fix requires it
- Do not add caching layers in this mission (that's a separate architectural decision)
- Focus on quick wins — large architectural changes are out of scope
