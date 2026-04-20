# Phase 2 Skills Research — Consolidated Findings

> Research for 18 new skills to add to oh-my-universal.
> Sources: oh-my-claudecode (Yeachan-Heo), oh-my-codex (Yeachan-Heo), claw-code (ultraworkers/greycheer), awesome-claude-code (hesreallyhim)
> Created: 2026-04-20

---

## 1. autopilot

**Source:** oh-my-claudecode `/oh-my-claudecode:autopilot`
**Purpose:** Fully autonomous 5-phase pipeline that takes an idea from concept to validated working code with zero human intervention.

**Key Behaviors:**
- Phase 1 — Expansion: Analyst + Architect expand the idea into requirements and technical spec. Stored at `.omc/autopilot/spec.md`.
- Phase 2 — Planning: Architect creates an execution plan, validated by Critic agent. Stored at `.omc/plans/autopilot-impl.md`.
- Phase 3 — Execution: Ralph + Ultrawork implement the plan with parallel agents. Tracks files created/modified.
- Phase 4 — QA: UltraQA ensures build/lint/tests pass through iterative fix cycles (max 5 cycles).
- Phase 5 — Validation: Specialized architects perform functional, security, and quality reviews. Uses tournament-style verdicts (APPROVED/REJECTED/NEEDS_FIX).
- State persisted to `.omc/state/autopilot-state.json` with phase durations, agent spawn count, and iteration tracking.
- Supports pause-after-expansion, pause-after-planning, skip-qa, skip-validation, auto-commit config flags.
- Cancel/resume supported: `cancelAutopilot()` preserves progress, `resumeAutopilot()` picks up from last phase.

**Trigger Conditions:**
- User says "autopilot", "build me", "I want a", "handle it all", "end to end", "e2e this", "full auto", "fullsend"
- Explicit `/autopilot "..."` command

**Output Format:**
- Spec document (expansion output)
- Implementation plan (planning output)
- Modified/created files (execution output)
- QA report (qa output)
- Validation verdicts per dimension (validation output)
- Summary with phase durations and agent count

**Cross-CLI Notes:**
- OMC uses TypeScript state machine + Claude Code hooks. Our version must be pure markdown instructions.
- The 5 phases map to composing existing skills: plan -> implement -> verify -> review -> commit. But autopilot adds the expansion (requirements clarification) and validation (multi-perspective review) phases that ultrawork lacks.
- Key difference from ultrawork: autopilot starts from a VAGUE IDEA, ultrawork starts from a CLEAR TASK.
- Magic keyword detection is CLI-specific (hooks). In markdown skills, trigger via explicit invocation or agent routing.

---

## 2. deep-dive

**Source:** oh-my-claudecode `/oh-my-claudecode:deep-dive`
**Purpose:** Two-stage pipeline that combines trace (evidence-driven causal analysis) with deep-interview (Socratic questioning) for thorough codebase investigation.

**Key Behaviors:**
- Stage 1 — Trace: Evidence-driven causal tracing of the problem. Uses the `tracer` agent to form competing hypotheses and gather evidence from codebase.
- Stage 2 — Deep Interview: Socratic questioning to clarify ambiguities and hidden assumptions discovered during trace. Measures clarity across weighted dimensions.
- Context handoff between stages: trace findings flow into deep-interview as pre-loaded context.
- Exposes hidden assumptions and measures readiness before any code is written.
- Produces structured output with verified findings vs. unverified hypotheses.

**Trigger Conditions:**
- User says "deep dive", "investigate this thoroughly", "trace and analyze"
- When a bug or behavior is complex and root cause is unclear
- When requirements are vague AND there's existing code to analyze

**Output Format:**
```markdown
## Deep Dive: {topic}

### Trace Findings
| Hypothesis | Evidence For | Evidence Against | Verdict |
|...

### Interview Findings
| Dimension | Clarity Score | Notes |
|...

### Recommendations
1. ...
```

**Cross-CLI Notes:**
- OMC's deep-dive composes two separate skills (trace + deep-interview) with automatic context handoff. Our version should document the two-stage workflow but can be a single skill file.
- The `tracer` agent in OMC is a dedicated sonnet-tier agent. In our universal version, this is instructions for the agent to follow, not a separate agent spawn.

---

## 3. ask

**Source:** oh-my-claudecode `/oh-my-claudecode:ask`, `omc ask`
**Purpose:** Query multiple AI models (Claude, Codex, Gemini) via their local CLIs and compare/synthesize answers.

**Key Behaviors:**
- Routes prompts to external AI CLIs: `claude`, `codex`, `gemini` via shell commands.
- Saves each response as a markdown artifact under `.omc/artifacts/ask/{provider}-{slug}-{timestamp}.md`.
- Supports `--agent-prompt` flag to specify which agent persona the external CLI should use.
- The `ccg` variant fans out to Codex + Gemini simultaneously, then Claude synthesizes.
- Can be used for cross-validation: ask Codex to review what Claude built, or Gemini for UI feedback.

**Trigger Conditions:**
- User says "ask codex", "ask gemini", "get a second opinion"
- When cross-validation of a decision is needed
- When a specific model's strength is relevant (Gemini for large context, Codex for code review)

**Output Format:**
- Individual provider response saved as markdown artifact
- For ccg mode: synthesized comparison showing agreement/disagreement points
- Artifacts stored at `.omc/artifacts/ask/` or project-local equivalent

**Cross-CLI Notes:**
- Requires Codex CLI (`npm i -g @openai/codex`) and/or Gemini CLI (`npm i -g @google/gemini-cli`) installed.
- Not all CLIs available on all platforms. Skill should gracefully degrade if a provider CLI is missing.
- This is fundamentally a shell-command skill. The markdown skill just describes the workflow; actual execution depends on CLI availability.
- For Copilot CLI: can use `task` tool to spawn sub-agents with different models.

---

## 4. trace

**Source:** oh-my-claudecode `tracer` agent + `/oh-my-claudecode:trace`
**Purpose:** Evidence-driven causal tracing for debugging — forms competing hypotheses and systematically gathers evidence to confirm or eliminate them.

**Key Behaviors:**
- Form 2-4 competing hypotheses about root cause before looking at code.
- For each hypothesis, identify what evidence would confirm or refute it.
- Systematically gather evidence from codebase (grep, read files, run tests).
- Score each hypothesis based on evidence found. Eliminate weak ones.
- Present final verdict with full evidence chain — no speculation.
- Uses structured output: hypothesis table, evidence log, verdict with confidence level.

**Trigger Conditions:**
- User says "trace this", "debug this", "why is this happening"
- When a bug is reproducible but root cause is unclear
- When multiple possible causes exist and need systematic elimination

**Output Format:**
```markdown
## Trace: {problem}

### Hypotheses
| # | Hypothesis | Prior | Evidence For | Evidence Against | Posterior |
|---|...

### Evidence Log
1. Checked {file:line} — found {evidence} — supports H1, refutes H2
2. ...

### Verdict
**Root cause:** {hypothesis N} (confidence: HIGH/MEDIUM/LOW)
**Evidence chain:** {summary}
**Recommended fix:** {action}
```

**Cross-CLI Notes:**
- OMC has a dedicated `tracer` agent (sonnet tier). Our version is instructions any agent follows.
- The key insight is the STRUCTURED DEBUGGING METHOD — hypotheses first, then evidence, not random code reading.
- Works with any CLI since it's just a reasoning framework + file reading.

---

## 5. visual-verdict

**Source:** oh-my-claudecode `vision` agent + visual review patterns
**Purpose:** Screenshot-based UI review — take screenshots of UI changes and get structured visual feedback.

**Key Behaviors:**
- Take before/after screenshots of UI changes using platform screenshot tools.
- Analyze screenshots for visual regressions: layout shifts, color changes, spacing issues.
- Check accessibility: contrast ratios, text readability, interactive element sizing.
- Compare against design specs if provided.
- Produce structured visual review with annotated issues.

**Trigger Conditions:**
- User says "visual review", "check the UI", "does this look right"
- After CSS/frontend changes
- When design fidelity verification is needed

**Output Format:**
```markdown
## Visual Verdict: {page/component}

### Screenshots
Before: {path}  After: {path}

### Findings
| Issue | Severity | Location | Description |
|...

### Accessibility
- Contrast: PASS/FAIL
- Touch targets: PASS/FAIL
- Text readability: PASS/FAIL

### Verdict: APPROVED / NEEDS_FIX
```

**Cross-CLI Notes:**
- Requires screenshot capability. Claude Code has vision (image input). Copilot CLI has browser CDP tools. Codex has limited image support.
- Not all CLIs can process images. Skill should degrade to "take screenshot, save to path, ask user to review" on CLIs without vision.
- OMC uses a dedicated `vision` agent (sonnet tier with multimodal).

---

## 6. wiki

**Source:** oh-my-claudecode `omx wiki`, oh-my-codex `.omx/wiki/`
**Purpose:** Auto-maintained project knowledge base that the agent reads before exploring the codebase, reducing repeated file reads.

**Key Behaviors:**
- Maintain a local wiki under `.wiki/` (or `.omc/wiki/` in OMC) with markdown pages.
- Auto-generate wiki pages from codebase: architecture overview, API reference, dependency graph, conventions.
- `wiki list` — show all pages. `wiki query` — search across pages. `wiki refresh` — regenerate stale pages.
- `wiki lint` — check for broken links, outdated content, missing pages.
- Wiki-first context: when exploring code, check wiki FIRST before reading source files.
- Markdown-first, search-first (not vector-first) — simple grep over markdown files.

**Trigger Conditions:**
- User says "update wiki", "what does the wiki say about X"
- Automatically at session start: load wiki overview for context
- After significant codebase changes: refresh affected wiki pages

**Output Format:**
```
.wiki/
  index.md           # Table of contents
  architecture.md    # System architecture overview
  api.md             # API surface documentation
  conventions.md     # Project conventions
  dependencies.md    # Dependency map
  {custom}.md        # User-created pages
```

**Cross-CLI Notes:**
- Wiki is just markdown files — works on every CLI.
- The auto-generation feature requires codebase analysis (grep/glob/read) — all CLIs can do this.
- OMC has `omc wiki` CLI commands + MCP server. Our version is instructions-only.
- Key value: reduces token usage by caching codebase knowledge in readable markdown.

---

## 7. writer-memory

**Source:** oh-my-claudecode `/oh-my-claudecode:writer-memory`
**Purpose:** Enhanced persistent context system specifically for writing projects — maintains tone, style, character details, and narrative continuity across sessions.

**Key Behaviors:**
- Store and retrieve writing-specific context: character profiles, plot points, tone guidelines, style rules.
- Automatic tone consistency checking: compare new output against stored style guide.
- Track narrative state: what happened, what's planned, unresolved threads.
- Different from `remember` skill: writer-memory is content-focused (stories, docs, articles), remember is code-focused (conventions, gotchas).
- Supports multiple projects: each writing project gets its own memory namespace.

**Trigger Conditions:**
- User is working on documentation, blog posts, technical writing, creative writing
- User says "remember the tone", "keep the style consistent"
- When continuing a multi-session writing project

**Output Format:**
```
.memory/writing/
  style-guide.md      # Tone, voice, formatting rules
  context.md          # Current project state
  characters.md       # For narrative: character details
  outline.md          # Structure/outline of the work
  continuity-log.md   # What was written, in what order
```

**Cross-CLI Notes:**
- Pure markdown storage — works everywhere.
- Enhanced version of `remember` with writing-specific fields.
- Consider merging with `remember` as a mode rather than separate skill.

---

## 8. release

**Source:** oh-my-claudecode `/oh-my-claudecode:release`
**Purpose:** Automated release workflow — changelog generation, version bump, git tag, and optional publish.

**Key Behaviors:**
- Analyze commits since last tag to generate changelog (conventional commits format).
- Determine version bump type: major/minor/patch based on commit types (feat=minor, fix=patch, BREAKING=major).
- Update version in package.json / pyproject.toml / Cargo.toml / version file.
- Generate/update CHANGELOG.md with grouped entries (Features, Fixes, Breaking Changes).
- Create git tag with version.
- Optionally: run `npm publish`, `cargo publish`, `pip publish`, or custom publish command.
- Dry-run mode: show what would happen without making changes.

**Trigger Conditions:**
- User says "release", "cut a release", "publish", "bump version"
- After a set of features/fixes are ready for release

**Output Format:**
```markdown
## Release: v{version}

### Changes Since v{previous}
#### Features
- {feat commit message}

#### Fixes
- {fix commit message}

### Actions Taken
- [x] Version bumped: {old} -> {new}
- [x] CHANGELOG.md updated
- [x] Git tag created: v{version}
- [ ] Published to npm (awaiting approval)
```

**Cross-CLI Notes:**
- Uses `git log` and file editing — works on all CLIs.
- Publish step is optional and requires user approval.
- Version detection must be language-agnostic: check for package.json, pyproject.toml, Cargo.toml, VERSION file.

---

## 9. self-improve

**Source:** oh-my-claudecode `/oh-my-claudecode:self-improve`
**Purpose:** Agent improves its own prompts, skills, and instructions based on failures and session analysis.

**Key Behaviors:**
- Analyze recent session failures: what went wrong, what instructions were unclear.
- Propose improvements to skill files, CLAUDE.md, AGENTS.md, or copilot-instructions.
- Uses tournament selection: generate multiple improvement candidates, evaluate each, pick the best.
- Topic-scoped: improvements stored under `.omc/self-improve/topics/{topic-slug}/` with version history.
- Tracks improvement lineage: what was changed, why, and whether it helped.
- Safety: all changes proposed as diffs, not auto-applied. User reviews before merging.

**Trigger Conditions:**
- After a session with repeated failures or retries
- User says "improve yourself", "why do you keep making this mistake"
- Periodically: analyze last N sessions for patterns

**Output Format:**
```markdown
## Self-Improvement: {topic}

### Problem Observed
{What went wrong in recent sessions}

### Root Cause
{Why the current instructions/skills led to failure}

### Proposed Changes
```diff
- old instruction
+ improved instruction
```

### Expected Impact
{How this change should prevent future failures}

### Confidence: HIGH/MEDIUM/LOW
```

**Cross-CLI Notes:**
- This is meta-skill: it modifies OTHER skill files. Requires write access to skills/.
- OMC uses tournament selection with multiple candidates. Simpler version: analyze failures, propose single improvement.
- Must not auto-apply changes. Always show diff and wait for approval.

---

## 10. hud

**Source:** oh-my-claudecode `/oh-my-claudecode:hud`, `omc hud`
**Purpose:** Heads-up display showing real-time agent status, token usage, active modes, and progress in the terminal status bar.

**Key Behaviors:**
- Display in terminal status bar: active skill/mode, token usage, agent count, elapsed time.
- Presets: "focused" (minimal), "detailed" (full metrics), "team" (multi-agent status).
- Track: current phase (plan/implement/verify), agents spawned, files modified, errors encountered.
- Token usage: input/output tokens, cost estimate, context window utilization percentage.
- Rate limit awareness: show remaining quota, time until reset.
- Live refresh: update status bar as work progresses.

**Trigger Conditions:**
- User says "show hud", "status", "what's happening"
- Auto-enable during long-running operations (autopilot, team, ralph)

**Output Format:**
Terminal status bar:
```
[autopilot:execution] 🔄 3/5 files | 📊 45k tokens | ⏱️ 2m30s | 👥 3 agents
```

**Cross-CLI Notes:**
- HUD is highly CLI-specific. Claude Code has hook-based status injection. Other CLIs don't have status bars.
- Universal version: periodic progress report to stdout rather than status bar integration.
- For Copilot CLI: use `report_intent` tool as lightweight HUD equivalent.
- This may be better as a "progress reporting convention" rather than a true HUD skill.

---

## 11. session-manager

**Source:** oh-my-claudecode `/oh-my-claudecode:project-session-manager` (PSM)
**Purpose:** Manage, resume, and fork agent sessions — isolated dev environments using git worktrees + tmux.

**Key Behaviors:**
- Create isolated sessions: each session gets a git worktree + dedicated terminal/tmux pane.
- Resume sessions: pick up where a previous session left off with full context.
- Fork sessions: branch a session to explore alternative approaches.
- Session state stored in `.omc/state/sessions/{session_id}/` with mode states, memory, and progress.
- Session precedence: explicit session scope > current session > root scope fallback.
- Reconciliation: stale root survivors are terminalized during reconciliation.
- Session search: `omc session search "query"` searches across session transcripts.

**Trigger Conditions:**
- User says "new session", "resume session", "fork this"
- When working on multiple features in parallel
- When wanting to try an alternative approach without losing current progress

**Output Format:**
```
Sessions:
| ID | Branch | Status | Last Active | Summary |
| ses_abc | feature/auth | active | 2m ago | Implementing OAuth flow |
| ses_def | feature/api | paused | 1h ago | API refactoring |
```

**Cross-CLI Notes:**
- Git worktrees are universal. tmux is Unix-only (psmux on Windows).
- Session state files are just JSON — works everywhere.
- Most CLIs already have basic session resume (e.g., `claude --resume`). This skill adds structured management.
- For Copilot CLI: session management is handled by the CLI itself. Skill focuses on worktree isolation.

---

## 12. mcp-setup

**Source:** oh-my-claudecode `/oh-my-claudecode:mcp-setup`
**Purpose:** Auto-configure MCP (Model Context Protocol) servers for a project based on its tech stack.

**Key Behaviors:**
- Detect project tech stack: languages, frameworks, databases, cloud providers.
- Suggest relevant MCP servers: filesystem, GitHub, database, cloud, etc.
- Generate `.mcp.json` or equivalent config with proper server entries.
- Verify MCP servers are reachable and working.
- Handle authentication: prompt for API keys, tokens, connection strings.
- Registry of known MCP servers with categories and compatibility info.

**Trigger Conditions:**
- User says "setup MCP", "configure tools", "connect to database"
- First time in a new project (as part of doctor/setup workflow)
- When an MCP server is needed but not configured

**Output Format:**
```json
// .mcp.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "..." }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "..." }
    }
  }
}
```

**Cross-CLI Notes:**
- MCP config format varies by CLI: `.mcp.json` (Claude Code), `mcp-config.json` (Copilot CLI), etc.
- Skill must know config paths for each CLI and generate the right format.
- Not all CLIs support MCP yet. Codex and Gemini CLI support is emerging.

---

## 13. dirty-guard

**Source:** oh-my-codex `resume-dirty-guard` pattern
**Purpose:** Block dangerous operations (reset, force-push, checkout) when the git worktree has uncommitted changes.

**Key Behaviors:**
- Check `git status --porcelain` before destructive operations.
- Block: `git reset --hard`, `git checkout -- .`, `git clean -fd`, force-push, branch delete.
- Allow: normal commits, pushes, pulls, merges (non-destructive).
- Provide clear message: what's dirty, what operation was blocked, how to proceed (commit or stash first).
- Override: user can explicitly say "force" or "I know what I'm doing" to bypass.

**Trigger Conditions:**
- Before any git operation that could lose uncommitted work
- Proactively: warn user if worktree is dirty before starting destructive operations
- Auto-check at session start if dirty worktree detected

**Output Format:**
```
⚠️ DIRTY GUARD: Blocked `git reset --hard`
   Uncommitted changes:
   M  src/auth.ts
   ??  src/new-file.ts
   
   Options:
   1. Commit changes first: git add . && git commit -m "wip"
   2. Stash changes: git stash
   3. Force override: say "force reset" to proceed (DANGER)
```

**Cross-CLI Notes:**
- Pure git operations — works on every CLI.
- In OMC, this is implemented as a hook that intercepts Bash tool use. In our version, it's instructions the agent follows.
- Key insight: agents are overly willing to run destructive commands. This skill teaches caution.

---

## 14. run-tagging

**Source:** oh-my-codex `fresh-run-tagging` pattern
**Purpose:** Assign a unique identity to each agent session/run to prevent lane reuse and enable audit trails.

**Key Behaviors:**
- Generate unique run ID at session start: `run-{YYYYMMDD}-{HHMMSS}-{random}`.
- Tag all artifacts with run ID: plans, logs, commits, state files.
- Prevent lane reuse: if a previous run's state is found, force-start a new lane rather than resuming stale state.
- Audit trail: run ID appears in commit messages, file headers, and state metadata.
- Staleness check: runs older than configurable threshold (default: 2 hours) are treated as stale.

**Trigger Conditions:**
- Automatically at session start
- When resuming work: detect if previous run state is stale

**Output Format:**
```
Run ID: run-20260420-143022-a7f3
Session: {cli-name} at {project-path}
Started: 2026-04-20T14:30:22Z
```

**Cross-CLI Notes:**
- Pure metadata — works everywhere.
- OMC uses session IDs from Claude Code's native session system. Our version generates its own.
- Useful for multi-agent scenarios where runs must not collide.
- Can be implemented as part of session-protocol skill rather than standalone.

---

## 15. parity-check

**Source:** oh-my-codex parity-smoke/sweep, claw-code parity harness
**Purpose:** Agent health and contract smoke tests — verify that the agent environment, tools, and skills are working correctly.

**Key Behaviors:**
- Verify all expected tools are available: file read/write, grep, glob, bash/shell, git.
- Verify skill files exist and are readable.
- Run a simple end-to-end smoke test: create temp file, read it, delete it.
- Check CLI-specific features: MCP servers reachable, hooks registered, plugins loaded.
- Compare expected vs. actual capability matrix.
- Report pass/fail with specific failure details.

**Trigger Conditions:**
- User says "parity check", "smoke test", "are my tools working"
- After setup/install to verify everything works
- When unexpected tool failures occur (diagnose the environment)

**Output Format:**
```markdown
## Parity Check

### Tool Availability
| Tool | Expected | Actual | Status |
|------|----------|--------|--------|
| file read | ✓ | ✓ | PASS |
| file write | ✓ | ✓ | PASS |
| bash | ✓ | ✗ | FAIL — sandbox mode |
| git | ✓ | ✓ | PASS |

### Skill Files
| Skill | Path | Status |
|-------|------|--------|
| plan | skills/plan.md | PASS |
| review | skills/review.md | PASS |

### Smoke Test
- Create file: PASS
- Read file: PASS  
- Delete file: PASS

### Result: 11/12 PASS (1 FAIL)
```

**Cross-CLI Notes:**
- Tool names vary by CLI. Skill must adapt checks to current CLI.
- Extends doctor skill with runtime tool verification (doctor checks project health, parity-check checks agent health).
- claw-code's parity harness is a Rust-based compatibility layer. Our version is instructions-only.

---

## 16. handoff

**Source:** oh-my-codex `candidate-handoff` pattern, OMC artifact-first handoff
**Purpose:** Structured state handoff between agent runs — serialize current progress so a future session can resume seamlessly.

**Key Behaviors:**
- At session end: serialize current state to a handoff file (`candidate.json` or `handoff.md`).
- Include: what was done, what's left, key decisions made, files modified, test results, blockers.
- At session start: check for handoff file and load context.
- Handoff format is human-readable (markdown) with machine-parseable sections.
- Bounded handoff: large artifacts referenced by path/descriptor, not embedded inline.
- OMC pattern: control plane (small, operational) vs. data plane (durable artifacts) separation.

**Trigger Conditions:**
- End of every session (as part of session-protocol)
- When switching between agents or CLI tools mid-task
- User says "hand off", "save state", "prepare for next session"

**Output Format:**
```markdown
## Handoff: {task}
**Run:** {run-id}
**Date:** {timestamp}
**Status:** IN_PROGRESS / BLOCKED / READY_FOR_REVIEW

### Done
- [x] Implemented auth module (src/auth.ts)
- [x] Added tests (src/auth.test.ts)

### Remaining
- [ ] Integration tests
- [ ] Documentation update

### Key Decisions
- Used JWT over session tokens (see decisions.md)
- Chose bcrypt over argon2 for compatibility

### Blockers
- Need database migration approval

### Files Modified
- src/auth.ts (new)
- src/auth.test.ts (new)
- package.json (modified — added jsonwebtoken)

### Artifacts
| Kind | Path | Description |
|------|------|-------------|
| plan | .plans/auth-plan.md | Implementation plan |
| test-results | .artifacts/test-run-001.log | Last test run |
```

**Cross-CLI Notes:**
- Pure markdown + optional JSON — works everywhere.
- Extends `session-protocol` skill with structured handoff format.
- The candidate.json pattern from OMX stores minimal metadata pointing to full artifacts.
- For multi-CLI workflows (start in Claude Code, continue in Copilot CLI): handoff format must be CLI-agnostic.

---

## 17. hooks

**Source:** oh-my-claudecode (20 hooks across 11 lifecycle events)
**Purpose:** Pre/post hooks system that intercepts agent lifecycle events to inject context, enforce rules, and manage state.

**Key Behaviors:**
- Define hook points: session-start, prompt-submit, pre-tool-use, post-tool-use, pre-compact, stop, session-end.
- Hook types: context injection (add info to prompts), validation (block unsafe operations), state management (save/load state).
- OMC's 20 hooks implement: keyword detection, persistent mode enforcement, project memory, subagent tracking, permission handling, code simplification, session management.
- Hook output injected via `<system-reminder>` tags in Claude Code. Other CLIs have different injection mechanisms.
- Hooks fire automatically — no user action needed. But can be disabled per-hook via env vars.
- Staleness guard: states older than 2 hours treated as inactive (prevents stale state resurrection).

**Trigger Conditions:**
- Hooks fire automatically on lifecycle events — this is not a user-invoked skill.
- The hooks SKILL teaches the agent about the hook system and how to configure it.

**Output Format:**
For the skill file (teaching agents about hooks):
```markdown
## Available Hook Points
| Event | When | Use For |
|-------|------|---------|
| session-start | Session begins | Load context, restore state |
| prompt-submit | User sends message | Keyword detection, routing |
| pre-tool-use | Before tool runs | Validation, permission checks |
| post-tool-use | After tool runs | Result verification, memory |
| pre-compact | Before context trim | Preserve critical state |
| stop | Agent stops | Persist mode, save progress |
| session-end | Session ends | Summary, notifications, cleanup |
```

**Cross-CLI Notes:**
- Hook IMPLEMENTATION is highly CLI-specific:
  - Claude Code: hooks.json with Node.js scripts
  - Codex CLI: .codex/hooks.json with similar structure
  - Copilot CLI: No native hooks (use copilot-instructions.md for behavioral hooks)
  - Cursor: .cursor/rules/*.mdc for rules-based hooks
- Our skill file documents the CONCEPT and what each hook point should do. Actual implementation varies.
- For markdown-only CLIs: hooks become "behavioral instructions" embedded in instruction files.

---

## 18. status-line

**Source:** awesome-claude-code Status Lines section (6+ implementations)
**Purpose:** Terminal progress indicators during long operations — show tokens, cost, git branch, context usage, and rate limits.

**Key Behaviors:**
- Display in terminal: current model, git branch, token usage (input/output), cost estimate.
- Rate limit tracking: 5h/7d usage percentages, burn rate vs. time remaining (pace delta).
- Context window usage: percentage of context window consumed, compaction warnings.
- Git integration: current branch, number of staged/unstaged changes, ahead/behind counts.
- Themes: dark/light mode, minimal/detailed presets.
- Performance: must be lightweight (<5ms update), non-blocking.

**Trigger Conditions:**
- Automatically active during all agent operations
- User says "show status", "how much have I used"

**Output Format:**
Terminal status line:
```
claude-sonnet-4 | main +3 -1 | 📊 12.4k/8.2k tokens ($0.08) | 🧠 34% ctx | ⏱️ 45% 5h
```

**Cross-CLI Notes:**
- Highly CLI-specific. Claude Code supports statusline via settings.json. Other CLIs may not.
- Existing implementations: claude-pace (bash+jq), claude-powerline (vim-style), CCometixLine (Rust), ccstatusline (Node.js).
- Universal version: a REPORTING skill that the agent periodically outputs progress. Not a true status bar.
- For Copilot CLI: use `report_intent` for intent status. Full status line is out of scope.
- Consider merging with hud skill — they overlap significantly.

---

## Cross-Cutting Observations

### Skill Composability
Many of these skills compose with existing ones:
- **autopilot** = expansion + plan + implement + verify + review + commit (new: expansion, validation phases)
- **deep-dive** = trace + deep-interview (new: context handoff between stages)
- **ultrawork** (existing) = plan + implement + verify + review + commit

### Skill vs. Convention
Some "skills" are better as conventions embedded in instruction files:
- **dirty-guard** — behavioral instruction, not a standalone skill
- **run-tagging** — metadata convention, part of session-protocol
- **hooks** — teaching skill about the concept; implementation is CLI-specific
- **status-line** / **hud** — CLI-specific features, not markdown skills

### Priority Grouping
- **High priority (new capabilities):** autopilot, trace, deep-dive, handoff, release, wiki
- **Medium priority (enhanced existing):** self-improve, ask, session-manager, hooks, dirty-guard
- **Low priority (CLI-specific/niche):** hud, status-line, visual-verdict, writer-memory, run-tagging, mcp-setup, parity-check

### Merge Candidates
- hud + status-line → single "progress" or "hud" skill
- run-tagging → fold into session-protocol
- dirty-guard → fold into pre-commit-check or session-protocol
- writer-memory → mode of remember skill

---

## Missions System

**Source:** oh-my-codex (Yeachan-Heo) `missions/` directory
**Purpose:** Scoped task specifications that AI agents pick up and execute autonomously. Missions are the WHAT (specific tasks) while skills are the HOW (reusable patterns).

**Architecture:**
- Each mission lives in `missions/{name}/` with two files:
  - `mission.md` — Goal, focus areas, success criteria (required)
  - `sandbox.md` — Evaluation constraints, scope boundaries (recommended)
- `missions/_template/` provides a copy-paste starter for new missions
- `missions/README.md` documents the system, creation workflow, and examples

**Execution via `mission-runner` skill:**
1. List available missions by scanning `missions/` subdirectories
2. User picks one (or agent auto-selects based on context)
3. Load mission.md (goals) + sandbox.md (constraints)
4. Decompose into steps using the `plan` skill
5. Execute each step using appropriate skills (trace, build-fix, verify, security-review, perf-audit, wiki, etc.)
6. Validate against success criteria — produce PASS/FAIL report with evidence
7. sandbox.md can specify an `evaluator.command` in YAML frontmatter for automated validation

**Key Design Decisions:**
- Missions are project-specific; skills are project-agnostic. A mission like "security-hardening" is a concrete task with an end state. A skill like "security-review" is a reusable pattern.
- Success criteria must be measurable — a tool or command can verify them.
- sandbox.md acts as a guardrail: hard boundaries the agent MUST NOT cross during execution.
- The mission-runner skill composes other skills rather than duplicating their logic.

**Shipped Example Missions (generic, usable in any project):**
- `security-hardening` — Audit and harden security (uses security-review skill)
- `test-coverage-boost` — Increase test coverage by 15%+ (uses tdd, verify skills)
- `performance-baseline` — Establish perf baselines, fix top 3 bottlenecks (uses perf-audit skill)
- `docs-from-scratch` — Generate complete docs for undocumented project (uses wiki skill)
- `dependency-cleanup` — Remove unused deps, patch vulnerabilities, clean lockfile

**Relationship to Existing Skills:**
- `plan` — missions use plan for decomposition
- `verify` — missions use verify for per-criterion validation
- `build-fix` — missions use build-fix when execution breaks the build
- `security-review`, `perf-audit`, `wiki`, `tdd` — domain skills missions delegate to
- `autopilot` — autopilot could auto-select and run missions in fully autonomous mode
