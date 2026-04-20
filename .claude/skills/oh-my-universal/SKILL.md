---
name: oh-my-universal
description: "39 cross-project development skills: plan, review, ultrawork, autopilot, TDD, team, security, deep-dive, trace, release, and more."
user_invocable: true
args: skill_name
argument-hint: "[plan | ultrawork | autopilot | verify | build-fix | tdd | deep-dive | trace | ask | architecture | review | multi-model-review | security-review | visual-verdict | perf-audit | pre-commit-check | doc-maintainer | wiki | remember | writer-memory | release | hooks | dirty-guard | run-tagging | parity-check | handoff | status-line | hud | self-improve | skillify | doctor | mcp-setup | session-manager | session-protocol | mission-runner | team | repo-merge | notify | refactor]"
---

# oh-my-universal — Skill Router for Claude Code (39 skills)

## Routing

Read the skill file based on `{{skill_name}}`:

### Core Workflow
| Input | Skill file |
|-------|-----------|
| `plan` | `skills/plan.md` |
| `ultrawork` | `skills/ultrawork.md` |
| `autopilot` or `auto` | `skills/autopilot.md` |
| `verify` | `skills/verify.md` |
| `build-fix` or `fix` | `skills/build-fix.md` |
| `tdd` | `skills/tdd.md` |

### Investigation
| Input | Skill file |
|-------|-----------|
| `deep-dive` or `dive` | `skills/deep-dive.md` |
| `trace` or `debug` | `skills/trace.md` |
| `ask` or `cross-validate` | `skills/ask.md` |
| `architecture` or `arch` | `skills/architecture.md` |

### Quality
| Input | Skill file |
|-------|-----------|
| `review` | `skills/review.md` |
| `multi-model-review` or `thorough-review` | `skills/multi-model-review.md` |
| `security-review` or `security` | `skills/security-review.md` |
| `visual-verdict` or `visual` | `skills/visual-verdict.md` |
| `perf-audit` or `perf` | `skills/perf-audit.md` |
| `pre-commit-check` or `pre-commit` | `skills/pre-commit-check.md` |

### Documentation
| Input | Skill file |
|-------|-----------|
| `doc-maintainer` or `docs` | `skills/doc-maintainer.md` |
| `wiki` | `skills/wiki.md` |
| `remember` | `skills/remember.md` |
| `writer-memory` or `writing` | `skills/writer-memory.md` |

### Operations
| Input | Skill file |
|-------|-----------|
| `release` or `publish` | `skills/release.md` |
| `hooks` | `skills/hooks.md` |
| `dirty-guard` or `dirty` | `skills/dirty-guard.md` |
| `run-tagging` or `tag-run` | `skills/run-tagging.md` |
| `parity-check` or `parity` | `skills/parity-check.md` |
| `handoff` | `skills/handoff.md` |
| `status-line` or `progress` | `skills/status-line.md` |
| `hud` or `status` | `skills/hud.md` |

### Meta
| Input | Skill file |
|-------|-----------|
| `self-improve` or `improve` | `skills/self-improve.md` |
| `skillify` | `skills/skillify.md` |
| `doctor` | `skills/doctor.md` |
| `mcp-setup` or `mcp` | `skills/mcp-setup.md` |
| `session-manager` or `sessions` | `skills/session-manager.md` |
| `session-protocol` or `wrap-up` | `skills/session-protocol.md` |
| `mission-runner` or `mission` or `run-mission` | `skills/mission-runner.md` |

### Collaboration
| Input | Skill file |
|-------|-----------|
| `team` | `skills/team.md` |
| `repo-merge` or `merge` | `skills/repo-merge.md` |
| `notify` | `skills/notify.md` |
| `refactor` | `skills/refactor.md` |

### Fallback
| Input | Skill file |
|-------|-----------|
| (empty / no args) | Show this menu |
| (JD or task text) | Default to `ultrawork` |

Read the matched skill file and execute its workflow.
