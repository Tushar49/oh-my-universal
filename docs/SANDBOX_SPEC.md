# Sandbox Specification

Sandboxes are machine-readable execution contracts that accompany missions.
While `mission.md` is the human-readable goal, `sandbox.md` is the harness contract
that defines HOW the mission is evaluated and WHAT scope is allowed.

## Format

Every `sandbox.md` has YAML frontmatter + markdown body:

```yaml
---
evaluator:
  command: <test command to run>
  format: json          # output format: json | text | tap
  keep_policy: pass_only | score_improvement | always
---
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `evaluator.command` | Yes | Shell command that evaluates the mission outcome |
| `evaluator.format` | Yes | Output format of the evaluator (json, text, tap) |
| `evaluator.keep_policy` | No | When to keep results: `pass_only` (default), `score_improvement`, `always` |

### Keep Policies

- **pass_only** — Only keep results where `pass=true`
- **score_improvement** — Keep results that improve the score over baseline
- **always** — Keep all results regardless of pass/fail

### Evaluation Output (JSON format)

```json
{
  "pass": true,
  "score": 0.95,
  "details": "All 19/20 checks passed"
}
```

### Body Content

The markdown body defines scope constraints:
- **Allowed changes** — files/directories the agent MAY modify
- **Avoid** — things the agent must NOT do
- **Scope focus** — what to stay focused on

## Example

```yaml
---
evaluator:
  command: npm test -- --grep "auth"
  format: json
  keep_policy: pass_only
---
Focus only on authentication module hardening.

Allowed changes:
- src/auth/**
- tests/auth/**

Avoid:
- Unrelated refactors
- Adding new dependencies
- Changing public API signatures
```

## Relationship to Missions

```
missions/my-task/
  mission.md    → WHAT to do (human goal + success criteria)
  sandbox.md    → HOW to evaluate (machine contract + scope limits)
```

The `mission-runner` skill reads both files: mission.md for the goal, sandbox.md for constraints and evaluation.
