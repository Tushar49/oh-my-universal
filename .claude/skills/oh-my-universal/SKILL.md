---
name: oh-my-universal
description: "16 cross-project development skills: plan, review, ultrawork, TDD, team delegation, repo merge, security audit, and more."
user_invocable: true
args: skill_name
argument-hint: "[plan | review | ultrawork | verify | security-review | tdd | build-fix | team | repo-merge | doctor | architecture | remember | pre-commit-check | session-protocol | notify]"
---

# oh-my-universal — Skill Router for Claude Code

## Routing

Read the skill file based on `{{skill_name}}`:

| Input | Skill file |
|-------|-----------|
| `plan` | `skills/plan.md` |
| `review` | `skills/review.md` |
| `ultrawork` | `skills/ultrawork.md` |
| `verify` | `skills/verify.md` |
| `security-review` or `security` | `skills/security-review.md` |
| `tdd` | `skills/tdd.md` |
| `build-fix` or `fix` | `skills/build-fix.md` |
| `team` | `skills/team.md` |
| `repo-merge` or `merge` | `skills/repo-merge.md` |
| `doctor` | `skills/doctor.md` |
| `architecture` or `arch` | `skills/architecture.md` |
| `remember` | `skills/remember.md` |
| `doc-maintainer` or `docs` | `skills/doc-maintainer.md` |
| `pre-commit-check` or `pre-commit` | `skills/pre-commit-check.md` |
| `session-protocol` or `wrap-up` | `skills/session-protocol.md` |
| `notify` | `skills/notify.md` |
| `refactor` | `skills/refactor.md` |
| `perf-audit` or `perf` | `skills/perf-audit.md` |
| `multi-model-review` or `thorough-review` | `skills/multi-model-review.md` |
| `skillify` | `skills/skillify.md` |
| (empty / no args) | Show this menu |
| (JD or task text) | Default to `ultrawork` |

Read the matched skill file and execute its workflow.
