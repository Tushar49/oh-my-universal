# Skill: tdd

> Test-driven development cycle: Red -> Green -> Refactor.
> Write failing test first, implement minimally, then refactor.
> Inspired by: oh-my-codex ($tdd), claude-forge

## When to Use

- User says "tdd", "test-driven", "write tests first"
- When building a new function, class, or module from scratch
- When fixing a bug (write a test that reproduces it first)

## Workflow

### Step 1 — Red (Failing Test)

Before writing ANY implementation:
1. Understand the requirement
2. Write a test that exercises the expected behavior
3. Run the test — it MUST fail (if it passes, the test is wrong or the feature already exists)
4. Confirm the failure message is clear and describes what's missing

```
Test written: test_calculate_discount_applies_10_percent
Result: FAIL - calculate_discount is not defined
Status: RED ✓ (expected failure)
```

### Step 2 — Green (Minimal Implementation)

Write the MINIMUM code to make the test pass:
1. Don't add extra features, optimizations, or edge case handling yet
2. The goal is ONLY to turn the test green
3. Run the test — it must pass now
4. If it still fails, fix the implementation (not the test)

```
Implementation: added calculate_discount function
Result: PASS
Status: GREEN ✓
```

### Step 3 — Refactor

Now clean up without changing behavior:
1. Remove duplication
2. Improve naming
3. Simplify logic
4. Add edge case tests and handle them
5. Run ALL tests after each refactor step — they must stay green

```
Refactored: extracted discount_rate constant, added validation
All tests: PASS
Status: REFACTORED ✓
```

### Step 4 — Next Cycle

Repeat for the next requirement. Each cycle should be small (15-30 minutes max).

## Output Format

```markdown
## TDD Cycle: {feature name}

### Cycle 1: {specific behavior}
- RED: {test name} — FAIL ({why})
- GREEN: {what was implemented} — PASS
- REFACTOR: {what was cleaned up} — ALL PASS

### Cycle 2: {next behavior}
...

### Coverage
- {N} tests written
- {N} passing
- Key behaviors covered: {list}
- Edge cases covered: {list}
```

## Rules

- NEVER write implementation before the test
- Each cycle should be one small, focused behavior
- If the test is hard to write, the design probably needs simplifying
- Rerun ALL tests after every change, not just the new one
- Not responsible for: security auditing (see security-review), general code review (see review)
