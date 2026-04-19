# Unified Feature Matrix

> Maps features across all source repos to what oh-my-universal will implement.
> This is the master porting plan.

## Tier 1: Must Have (core value)

| Feature | Source | oh-my-universal implementation |
|---------|--------|-------------------------------|
| Plan before implementing | oh-my-codex ($plan, $ralplan) + oh-my-claudecode (ralplan) | `skills/plan.md` - agent reads task, creates plan, gets critique, then executes |
| Auto code review | oh-my-codex ($code-review) + oh-my-openagent (Momus) | `skills/review.md` - reviews staged/unstaged changes before commit |
| Full workflow (plan+impl+verify) | oh-my-codex ($ultrawork) + oh-my-claudecode (ultrawork) | `skills/ultrawork.md` - complete task lifecycle |
| Doc maintenance | oh-my-openagent (Librarian) | `.github/agents/doc-maintainer.agent.md` - updates docs after changes |
| Memory persistence | oh-my-claudecode (remember) + clawhip (memory-offload) | `skills/remember.md` - save/load context across sessions |
| Architecture analysis | oh-my-openagent (Atlas) | `skills/architecture.md` - map codebase structure |
| Project setup/health | oh-my-codex (setup/doctor) + oh-my-claudecode (setup) | `skills/doctor.md` - validate project prerequisites |

## Tier 2: Should Have (significant value)

| Feature | Source | oh-my-universal implementation |
|---------|--------|-------------------------------|
| Multi-agent team | oh-my-codex ($team) + oh-my-claudecode (team) | `skills/team.md` - delegate to parallel subagents |
| Security review | oh-my-codex ($security-review) | `skills/security-review.md` - security-focused code audit |
| TDD workflow | oh-my-codex ($tdd) | `skills/tdd.md` - test-driven development cycle |
| Build-fix loop | oh-my-codex ($build-fix) + oh-my-openagent (Hephaestus) | `skills/build-fix.md` - auto-fix build errors |
| Discord notifications | clawhip | `skills/notify.md` - notify on task completion |
| QA verification | oh-my-codex ($ultraqa) + oh-my-claudecode (verify) | `skills/verify.md` - verification pass |
| Wiki/knowledge base | oh-my-codex (wiki) + oh-my-claudecode (wiki) | `skills/wiki.md` - project knowledge base |

## Tier 3: Nice to Have

| Feature | Source | oh-my-universal implementation |
|---------|--------|-------------------------------|
| Code critic | oh-my-openagent (Momus) | Covered by review skill |
| Visual verdict | oh-my-claudecode (visual-verdict) | `skills/visual-review.md` |
| Repo merge | Custom | `skills/merge-repo.md` - merge external repo features |
| Eco mode | oh-my-codex ($ecomode) | `skills/ecomode.md` - reduce token usage |
| Persistent task runner | oh-my-codex ($ralph) + oh-my-openagent (Sisyphus) | `skills/persistent-task.md` |
| Intent classifier | oh-my-openagent (IntentGate) | Built into copilot-instructions routing |
| Skill creator | oh-my-claudecode (skillify) | `skills/skillify.md` - create new skills from patterns |

## NOT Porting

| Feature | Source | Why skip |
|---------|--------|----------|
| Rust CLI binary | claw-code | We use existing CLIs, not building a new one |
| tmux workers | oh-my-codex team mode | Windows-specific: use PowerShell jobs instead |
| Bun dependency | oh-my-openagent | Keep Node.js only for simplicity |
| Platform binaries | oh-my-openagent | No native compilation needed |
| GitHub star prompt | clawhip | Not relevant |

## Cross-CLI Compatibility Plan

Each skill will be implemented as a markdown file that works across CLIs:

| CLI | How skills load | Agent format |
|-----|----------------|-------------|
| Copilot CLI | `/add-dir` loads .github/agents/ and skills/ | `.agent.md` files |
| Claude Code | `--plugin-dir` or CLAUDE.md references | SKILL.md files |
| OpenAI Codex | AGENTS.md routes to skills/ | Skills in AGENTS.md |
| Gemini CLI | AGENTS.md routes to skills/ | Same as Codex |
| OpenCode | Plugin or AGENTS.md | Same as Codex |

The key insight: **markdown-based skills work everywhere**. No CLI-specific code needed.
Each skill is just a well-structured .md file with instructions that any agent can follow.
