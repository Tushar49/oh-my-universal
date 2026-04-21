# Skill: perf-audit

> Performance profiling and optimization recommendations.
> Identifies bottlenecks, suggests fixes, measures improvement.
> Inspired by: claude-forge performance profiling

## When to Trigger

- User says "optimize", "slow", "performance", "bottleneck"
- Application response time is unacceptable
- Before scaling decisions (optimize first, scale second)
- When profiling data is available

## Analysis Dimensions

### 1. Algorithmic Complexity
- O(n^2) or worse operations on large datasets?
- Unnecessary nested loops?
- Linear search where hash lookup would work?
- Sorting in hot paths?

### 2. I/O & Network
- N+1 query patterns (database calls in loops)?
- Missing caching for repeated lookups?
- Synchronous I/O blocking the event loop?
- Large payloads without pagination?
- Missing connection pooling?

### 3. Memory
- Large objects kept in memory unnecessarily?
- Memory leaks (event listeners, closures, caches without eviction)?
- Loading entire files when streaming would work?

### 4. Frontend (if applicable)
- Bundle size (unnecessary large dependencies)?
- Render blocking resources?
- Unoptimized images?
- Missing lazy loading?

### 5. Build & CI
- Build time bottlenecks?
- Test suite running too slow?
- Unnecessary rebuilds?

## Workflow

### Step 1 — Identify Hot Paths
Find where time is actually spent:
- Read existing profiling data if available
- Identify user-reported slow operations
- Check for obvious algorithmic issues in critical paths

### Step 2 — Measure Baseline
Before any optimization, record current metrics:
```
Baseline: {operation} takes {X}ms / {X} memory / {X} queries
```

### Step 3 — Recommend Fixes
Prioritize by impact vs effort:

| # | Issue | Impact | Effort | Fix |
|---|-------|--------|--------|-----|
| 1 | N+1 queries in /api/users | HIGH | LOW | Add .include() / eager loading |
| 2 | No caching for config | MEDIUM | LOW | Add in-memory cache with TTL |

### Step 4 — Apply & Measure
For each fix:
1. Apply the optimization
2. Re-measure the same metric
3. Report improvement: `{operation}: {Xms} -> {Yms} ({Z%} improvement)`

## Output Format

```markdown
## Performance Audit: {scope}

**Baseline:** {operation} — {Xms} / {memory} / {queries}
**After optimization:** {Yms} / {memory} / {queries}
**Improvement:** {Z%}

### Findings
| # | Issue | Impact | Effort | Fix | Result |
|---|-------|--------|--------|-----|--------|
| 1 | {issue} | HIGH | LOW | {fix applied} | {Xms -> Yms} |

### Recommendations
- {remaining optimizations not yet applied}
```

## Rules

- Always MEASURE before and after. "Feels faster" is not evidence.
- Optimize the bottleneck, not the fast parts. Profile first.
- Don't sacrifice readability for micro-optimizations
- Premature optimization is the root of all evil — optimize hot paths only

## Not Responsible For

- Code quality (see review)
- Correctness (see verify)
