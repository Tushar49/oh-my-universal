# Hook: code-simplifier-hook

> After code changes, check for unnecessary complexity and suggest refactoring.

## Trigger

Fires after:
- Multiple edits to the same file in one session
- A file grows by more than 30% in line count
- A function exceeds a complexity threshold (nested conditionals, long parameter lists)
- User says "review", "clean up", or "simplify"

## Behavior

1. **Measure growth** — compare file size before and after changes
2. **Check complexity** — look for deep nesting (>3 levels), long functions (>50 lines), repeated patterns
3. **Identify extractions** — suggest functions, constants, or modules that could be extracted
4. **Suggest refactor** — offer specific, actionable simplification steps
5. **Skip if intentional** — don't flag complexity in test files, generated code, or config files

## Input

- File diff (before/after)
- File growth percentage
- Complexity indicators (nesting depth, function length, duplication)

## Output / Side Effects

- Complexity report with specific suggestions
- No automatic changes — suggestions only
- Skipped files noted (tests, generated code)
- Invokes `code-simplifier` skill if user approves

## Example

```
🔍 code-simplifier-hook: src/auth.ts
   Growth: +47% (89 → 131 lines)
   Issues found:
   - handleAuth() is 62 lines — extract token validation and role check
   - 3-level nested if/else at line 45 — consider early returns
   - Permission strings repeated 4 times — extract to constants
   
   Run code-simplifier skill to refactor? (yes/skip)
```
