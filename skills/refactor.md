# Skill: refactor

> Detect code patterns that need refactoring and apply improvements.
> Preserves behavior while improving structure, readability, and maintainability.
> Inspired by: claude-forge refactor agent

## When to Use

- User says "refactor", "clean up this code", "improve structure"
- After a feature is working but the code is messy
- When duplicated code is detected across files
- As part of TDD's refactor step (Red -> Green -> **Refactor**)

## Detection Patterns

Look for these code smells:

| Smell | Signal | Fix |
|-------|--------|-----|
| Duplication | Same/similar code in 2+ places | Extract to shared function/module |
| Long function | 50+ lines, multiple responsibilities | Split into smaller functions |
| Deep nesting | 3+ levels of if/for/while | Early returns, guard clauses, extract |
| God object | One file does everything | Split by responsibility |
| Magic numbers | Hardcoded values without names | Extract to named constants |
| Dead code | Unused imports, functions, variables | Remove |
| Inconsistent naming | Mix of camelCase, snake_case | Standardize to project convention |
| Long parameter lists | 4+ parameters | Use options object or config |

## Workflow

### Step 1 — Analyze
Scan the target code (file, function, or module) for patterns above.
Rank findings by impact: HIGH (structural) > MEDIUM (readability) > LOW (cosmetic).

### Step 2 — Plan Changes
For each finding:
```markdown
| # | Pattern | Location | Proposed change | Risk |
|---|---------|----------|----------------|------|
| 1 | Duplication | file.js:20,45 | Extract to utils.js | LOW |
| 2 | Long function | file.js:80-150 | Split into 3 functions | MEDIUM |
```

### Step 3 — Verify Behavior Preservation
Before refactoring:
- Run existing tests (they should pass)
- Note what the code currently does

### Step 4 — Apply Changes
Refactor one pattern at a time. After EACH change:
- Run tests again
- If tests break, REVERT that change and reassess
- If tests pass, continue to next pattern

### Step 5 — Report
```markdown
## Refactoring Report

**Files changed:** {N}
**Patterns addressed:** {N}
**Tests:** all passing

| Change | Before | After |
|--------|--------|-------|
| {pattern} | {old approach} | {new approach} |
```

## Rules

- NEVER change behavior. Refactoring = same behavior, better structure.
- Always verify tests pass after each change. No tests = higher risk.
- Don't refactor code you don't understand yet (use `architecture` skill first).
- Small refactors are better than big ones. Each should be independently revertible.
- Not responsible for: adding features (see plan), fixing bugs (see build-fix), security (see security-review)
