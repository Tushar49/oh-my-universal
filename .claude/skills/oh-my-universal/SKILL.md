---
name: oh-my-universal
description: "66 cross-project development skills + 20 lifecycle hooks + 5 behavior contracts: plan, review, ultrawork, autopilot, TDD, team, security, deep-dive, trace, release, and more."
user_invocable: true
args: skill_name
argument-hint: "[plan | ultrawork | autopilot | verify | build-fix | tdd | ralph | pipeline | ecomode | deep-dive | trace | ask | architecture | analyst | autoresearch | external-context | debug | deep-interview | scientist | review | multi-model-review | security-review | visual-verdict | perf-audit | pre-commit-check | designer | ai-slop-cleaner | ultraqa | deliverables | api-design | critic | doc-maintainer | wiki | remember | writer-memory | release | hooks | dirty-guard | run-tagging | parity-check | handoff | status-line | hud | cancel | workflow-state | container-sandbox | worktree-sandbox | git-master | cost-tracker | dependency-upgrade | self-improve | skillify | doctor | mcp-setup | session-manager | session-protocol | mission-runner | command-gen | config-sync | deepinit | rules-discovery | web-clone | team | repo-merge | notify | refactor]"
---

# oh-my-universal — Skill Router for Claude Code (66 skills)

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
| `ralph` or `fix-loop` | `skills/ralph.md` |
| `pipeline` or `stages` | `skills/pipeline.md` |
| `ecomode` or `eco` | `skills/ecomode.md` |

### Investigation
| Input | Skill file |
|-------|-----------|
| `deep-dive` or `dive` | `skills/deep-dive.md` |
| `trace` or `debug` | `skills/trace.md` |
| `ask` or `cross-validate` | `skills/ask.md` |
| `architecture` or `arch` | `skills/architecture.md` |
| `analyst` or `requirements` | `skills/analyst.md` |
| `autoresearch` or `research` | `skills/autoresearch.md` |
| `external-context` or `load-context` | `skills/external-context.md` |
| `debug` or `step-debug` | `skills/debug.md` |
| `deep-interview` or `interview` | `skills/deep-interview.md` |
| `scientist` or `data-analysis` | `skills/scientist.md` |

### Quality
| Input | Skill file |
|-------|-----------|
| `review` | `skills/review.md` |
| `multi-model-review` or `thorough-review` | `skills/multi-model-review.md` |
| `security-review` or `security` | `skills/security-review.md` |
| `visual-verdict` or `visual` | `skills/visual-verdict.md` |
| `perf-audit` or `perf` | `skills/perf-audit.md` |
| `pre-commit-check` or `pre-commit` | `skills/pre-commit-check.md` |
| `designer` or `ui-spec` | `skills/designer.md` |
| `ai-slop-cleaner` or `clean-slop` | `skills/ai-slop-cleaner.md` |
| `ultraqa` or `qa` | `skills/ultraqa.md` |
| `deliverables` or `check-deliverables` | `skills/deliverables.md` |
| `api-design` or `api` | `skills/api-design.md` |
| `critic` or `critique` | `skills/critic.md` |

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
| `cancel` or `abort` | `skills/cancel.md` |
| `workflow-state` or `state` | `skills/workflow-state.md` |
| `container-sandbox` or `sandbox` | `skills/container-sandbox.md` |
| `worktree-sandbox` or `worktree` | `skills/worktree-sandbox.md` |
| `git-master` or `git` | `skills/git-master.md` |
| `cost-tracker` or `costs` | `skills/cost-tracker.md` |
| `dependency-upgrade` or `upgrade-deps` | `skills/dependency-upgrade.md` |

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
| `command-gen` or `gen-command` | `skills/command-gen.md` |
| `config-sync` or `sync-config` | `skills/config-sync.md` |
| `deepinit` or `init` | `skills/deepinit.md` |
| `rules-discovery` or `discover-rules` | `skills/rules-discovery.md` |
| `web-clone` or `clone-site` | `skills/web-clone.md` |

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

## Lifecycle Hooks

The `hooks/` directory contains 20 lifecycle hooks covering session, tool,
skill, keyword, memory, safety, quality, subagent, and context events.
See `hooks/README.md` for the full list.

## Contracts

5 formal behavior contracts in `contracts/` that all skills and hooks MUST respect.
See `contracts/README.md` for details.
