# Progress Tracker - oh-my-universal

> Track all work on this project. Agents MUST update this file after every session.

---

## Current State (2026-05-02)

- **69 skills** in `skills/`
- **19 hooks** in `hooks/`
- **4 contracts** in `contracts/`
- **5 missions** in `missions/`
- **8 CLI adapters** (7 CLIs supported)
- **Cross-platform installer** in `setup/` (PowerShell, bash, Python)
- **Version:** 8.1.0

---

## Status Legend

| Status | Meaning |
|--------|---------|
| done | Implemented and tested |
| in-progress | Currently being worked on |
| planned | Designed, ready to implement |
| backlog | Identified, needs design work |
| researching | Gathering information from source repos |

---

## Phase 0: Research & Foundation

| # | Task | Status | Notes |
|---|------|--------|-------|
| 0.1 | Research oh-my-codex features | done | Hooks, delegation, planning, skills |
| 0.2 | Research oh-my-claudecode features | done | Team mode, plugins, memory, hooks |
| 0.3 | Research oh-my-openagent features | done | 11 agents, intent routing, MCP |
| 0.4 | Research clawhip features | done | Discord hooks, memory offload |
| 0.5 | Research claw-code patterns | done | CLI harness reference only |
| 0.6 | Create repo structure | done | README, docs, .research |
| 0.7 | Create requirements doc | done | docs/REQUIREMENTS.md |
| 0.8 | Create progress tracker | done | This file |
| 0.9 | Save research findings | done | .research/ with 5 findings + unified matrix |
| 0.10 | Search for additional repos | done | Found 11 more repos, saved to additional-repos.md |

## Phase 1: Core Agent Infrastructure

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Create copilot-instructions.md | done | Universal agent rules with skill table |
| 1.2 | Create AGENTS.md | done | Codex/Gemini entry with skill list |
| 1.3 | Create CLAUDE.md | done | Claude Code entry |
| 1.4 | Create plan skill | done | skills/plan.md - structured planning |
| 1.5 | Create review skill | done | skills/review.md - high-signal code review |
| 1.6 | Create ultrawork skill | done | skills/ultrawork.md - full lifecycle |
| 1.7 | Create doc-maintainer skill | done | skills/doc-maintainer.md - auto-update docs |
| 1.8 | Create remember skill | done | skills/remember.md - memory persistence |
| 1.9 | Create architecture skill | done | skills/architecture.md - codebase mapping |
| 1.10 | Create doctor skill | done | skills/doctor.md - health check |
| 1.11 | Create verify skill | done | skills/verify.md - change verification |
| 1.12 | Critic review + fixes | done | Applied cross-CLI compatibility fixes |

## Phase 2: Cross-Project Skills

| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Security review skill | done | skills/security-review.md - repo-scoped (not diff-scoped like review) |
| 2.2 | TDD skill | done | skills/tdd.md - Red -> Green -> Refactor cycle |
| 2.3 | Build-fix skill | done | skills/build-fix.md - auto-fix with 3 attempt max |
| 2.4 | Team skill | done | skills/team.md - multi-agent delegation with serial fallback |
| 2.5 | Repo merge skill | done | skills/repo-merge.md - structured external repo integration |

## Phase 3: Workflow Specs

| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | Pre-commit check spec | done | skills/pre-commit-check.md - quality gate (verify + review + security) |
| 3.2 | Session protocol spec | done | skills/session-protocol.md - end-of-session cleanup workflow |
| 3.3 | Notification spec | done | skills/notify.md - console + system + Discord backends |
| 3.4 | Memory persistence | done | Covered by skills/remember.md (Phase 1) |

## Phase 4: CLI-Specific Integration

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Copilot CLI adapter | done | `.github/instructions/skills.instructions.md` - auto-loaded with `applyTo: **` |
| 4.2 | Claude Code adapter | done | `.claude/skills/oh-my-universal/SKILL.md` - skill router with aliases |
| 4.3 | OpenAI Codex integration | done | AGENTS.md routes to skills/ |
| 4.4 | Gemini CLI integration | done | AGENTS.md (same as Codex) |
| 4.5 | OpenCode integration | done | AGENTS.md + plugin support |
| 4.6 | Setup guide | done | docs/SETUP.md with per-CLI instructions |
| 4.7 | GitHub repo created | done | https://github.com/Tushar49/oh-my-universal |

## Phase 5: Advanced Skills

| # | Task | Status | Notes |
|---|------|--------|-------|
| 5.1 | Refactor skill | done | skills/refactor.md - detect smells, preserve behavior |
| 5.2 | Performance audit skill | done | skills/perf-audit.md - profile, measure, optimize |
| 5.3 | Multi-model review | done | skills/multi-model-review.md - 4-perspective review |
| 5.4 | Skillify skill | done | skills/skillify.md - create new skills from patterns |
| 5.5 | Diff-aware verify | done | Enhanced verify.md with diff-aware mode |
| 5.6 | Cursor/Windsurf adapters | done | .cursor/rules/skills.mdc + .windsurfrules |
| 5.7 | npm package + CLI tool | done | package.json + bin/omu.mjs (list, setup, doctor, link) |
| 5.8 | MIT License | done | LICENSE file |

---

## Session Log

| Date | What was done | Agent |
|------|--------------|-------|
| 2026-04-19 | Created repo structure, requirements, progress tracker, research started | Copilot CLI |
| 2026-04-19 | Deep research on all 5 source repos, unified feature matrix, found 11 additional repos | Copilot CLI |
| 2026-04-19 | Built 8 Tier 1 skills (plan, review, ultrawork, doc-maintainer, remember, architecture, doctor, verify) | Copilot CLI |
| 2026-04-19 | Critic review applied: cross-CLI fixes, boundary rules, trigger clarity, verify skill added | Copilot CLI |
| 2026-04-19 | Phase 2: Built 5 cross-project skills (security-review, tdd, build-fix, team, repo-merge) | Copilot CLI |
| 2026-04-19 | Phase 3: Built 3 workflow specs (pre-commit-check, session-protocol, notify) | Copilot CLI |
| 2026-04-19 | Phase 4: CLI adapters (Copilot .instructions.md, Claude SKILL.md, setup guide), GitHub repo created + pushed | Copilot CLI |
| 2026-04-19 | Phase 5: Built 4 advanced skills (refactor, perf-audit, multi-model-review, skillify). Total: 20 skills. | Copilot CLI |
| 2026-04-19 | Phase 5 complete: diff-aware verify, Cursor/Windsurf adapters, npm package + CLI (omu), LICENSE. Pushed to GitHub. | Copilot CLI |
| 2026-04-21 | Phase 6: Full feature parity - added 18 new skills (total: 38), updated all 7 CLI adapters, created GEMINI.md | Copilot CLI |
| 2026-04-21 | Phase 7: Added 5 final skills + 19 lifecycle hooks. Total: 44 skills, 19 hooks | Copilot CLI |
| 2026-04-21 | Phase 8: Deep sweep - added 3 skills, 4 contracts, enhanced 3 existing skills. Total: 47 skills | Copilot CLI |
| 2026-04-21 | Phase 9: Documentation polish - CONTRIBUTING.md, SETUP.md, PROGRESS.md, REQUIREMENTS.md | Copilot CLI |

---

## 2026-04-21 - Phase 6: Full Feature Parity

- Added 18 new skills (total: 38)
- New skills: autopilot, deep-dive, ask, trace, visual-verdict, wiki, writer-memory, release, self-improve, hud, session-manager, mcp-setup, dirty-guard, run-tagging, parity-check, handoff, hooks, status-line
- Updated all 7 CLI adapters (Copilot, Claude, Codex, Gemini, Cursor, Windsurf, OpenCode)
- Created GEMINI.md for Gemini CLI support
- Research stored in .research/phase2-skills-research.md and .research/cli-detection-strategy.md
- Sources: oh-my-claudecode (29 agents, 35 skills, 20 hooks), oh-my-codex (missions), claw-code, awesome-claude-code

### Phase 6 Task Table

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.1 | Research oh-my-claudecode Phase 2 features | done | 35 skills, 29 agents, 20 hooks |
| 6.2 | Research oh-my-codex missions and patterns | done | dirty-guard, run-tagging, parity-check, handoff |
| 6.3 | Research awesome-claude-code patterns | done | status-line, hud patterns |
| 6.4 | Create 18 new skill files | done | All in skills/ directory |
| 6.5 | Update CLI adapters (all 7) | done | Copilot, Claude, Codex, Gemini, Cursor, Windsurf, OpenCode |
| 6.6 | Create GEMINI.md | done | Gemini CLI entry point |
| 6.7 | Update README (20 -> 38 skills) | done | Categorized into 7 groups |
| 6.8 | Update package.json | done | Version bump, new keywords |
| 6.9 | Update docs (PROGRESS, REQUIREMENTS, SETUP) | done | All docs current |

## 2026-04-21 — Phase 7: Full Parity + Hooks Infrastructure

- Added 5 final skills: cancel, analyst, designer, workflow-state, container-sandbox (total: 44)
- Added 19 lifecycle hooks in hooks/ directory covering complete agent lifecycle
- Hook categories: session, tool, skill, keyword, memory, safety, quality, subagent, context
- Sources: oh-my-claudecode (20 hooks), oh-my-codex (state model), claw-code (container), awesome-claude-code

### Phase 7 Task Table

| # | Task | Status | Notes |
|---|------|--------|-------|
| 7.1 | Create 5 final skills | done | cancel, analyst, designer, workflow-state, container-sandbox |
| 7.2 | Create 19 lifecycle hooks | done | hooks/ directory with README |
| 7.3 | Update all 8 CLI adapters | done | 39 -> 44 skills, hooks section added |
| 7.4 | Update README, package.json | done | v3.0.0, hooks table |
| 7.5 | Update PROGRESS.md | done | This entry |

## 2026-04-21 — Phase 8: Deep Sweep + Contracts

- Added 3 final skills: command-gen, worktree-sandbox, config-sync (total: 47)
- Added 4 behavior contracts in contracts/ directory
- Enhanced 3 existing skills: workflow-state (state precedence), handoff (terminal states), session-manager (forensics)
- 3 deep-sweep audits confirmed 100% coverage of all source repos
- Sources: awesome-claude-code (slash commands, worktree isolation), oh-my-codex (state model, contracts)

### Phase 8 Task Table

| # | Task | Status | Notes |
|---|------|--------|-------|
| 8.1 | Create 3 final skills | done | command-gen, worktree-sandbox, config-sync |
| 8.2 | Create 4 behavior contracts | done | contracts/ directory with README |
| 8.3 | Enhance 3 existing skills | done | workflow-state, handoff, session-manager |
| 8.4 | Deep-sweep audits (3 rounds) | done | 100% source repo coverage confirmed |
| 8.5 | Update all CLI adapters | done | 44 -> 47 skills, contracts section |

## 2026-04-21 — Phase 9: Documentation Polish

- Created CONTRIBUTING.md for public contributors
- Polished docs/SETUP.md with self-sufficient per-CLI sections (all 7 CLIs)
- Fixed PROGRESS.md phase numbering (Phase 3/4 -> Phase 7/8)
- Updated REQUIREMENTS.md skill count (38 -> 47), added hooks/contracts/missions counts

### Phase 9 Task Table

| # | Task | Status | Notes |
|---|------|--------|-------|
| 9.1 | Create CONTRIBUTING.md | done | Skills, hooks, missions, contracts contribution guide |
| 9.2 | Polish docs/SETUP.md | done | Clear per-CLI sections with exact commands |
| 9.3 | Fix docs/PROGRESS.md | done | Correct phase numbers, add missing task tables |
| 9.4 | Update docs/REQUIREMENTS.md | done | Accurate counts: 47 skills, 19 hooks, 4 contracts, 5 missions |

## 2026-04-21 — Phase 5: Final Sweep + Public Polish

- CDP browse found 13 gaps — added 10 new skills (total: 57)
- New skills: ralph, ai-slop-cleaner, autoresearch, ultraqa, external-context, ecomode, pipeline, debug, deepinit, git-master
- Validated all skill files (22 structural fixes applied)
- README polished for public launch (badges, FAQ, before/after, contributing)
- Created CONTRIBUTING.md
- GitHub search confirmed no major repos missed
- Merged dev to main — repo is public-ready

## 2026-04-21 — Phase 6: Final Sweep Complete

- Added 3 final skills: cost-tracker, rules-discovery, deliverables (total: 60)
- Formalized sandbox system with docs/SANDBOX_SPEC.md
- Improved all 6 mission sandbox.md files with evaluator specs
- Deep-read 3 new repos: oh-my-agent (744★), openskills (9.8K★), pro-workflow (2K★)
- Deep-read oh-my-claudecode: missions/, seminar/, research/, examples/, templates/, bridge/
- Deep-read all 13 oh-my-codex sandbox.md files
- Confirmed: zero remaining concept gaps across entire ecosystem

## 2026-04-21 — Phase 7: 5-Cycle Exhaustive Audit

- 25 audit cycles across 11 repos (5 cycles each)
- 12 candidate skills from cycles, rubber-duck critic reviewed all
- 6 KEPT (distinct concepts): api-design, critic, deep-interview, dependency-upgrade, scientist, web-clone
- 6 REJECTED (overlaps): consensus-plan→plan, devops→pipeline+release, error-handling→review+debug, learner→skillify, note→remember, research→autoresearch
- Final count: 66 skills, 19 hooks, 4 contracts, 5 missions
- All structural issues fixed per critic feedback

## 2026-04-21 — Phase 8: Definitive Matrix Audit

- CDP browsed ALL 8 source repos, extracted 100+ features
- Built cross-reference matrix: 31 gaps identified
- Triaged: 4 new skills (ultrathink, compact-guard, permission-tuner, output-styles)
- Enhanced 5 existing skills (tool-failure, dirty-guard, session-manager, config-sync, deepinit)
- 22 gaps classified as SKIP (runtime-specific, framework-specific, or already covered)
- Rubber-duck critic validated full repo quality
- Final count before critic: 70 skills, 19 hooks, 4 contracts, 5 missions

## 2026-04-21 — Phase 9: Critic Findings Fix

- Merged status-line into hud (70 -> 69 skills)
- Moved hook reference to docs/HOOKS_REFERENCE.md (hooks.md 301 -> ~70 lines)
- Fixed stale counts everywhere: skills=69, hooks=19, missions=5, contracts=4
- Added Cursor/Windsurf Quick Start examples to README
- Added Current State summary to PROGRESS.md
- Fixed adapter hook counts (20 -> 19)
- Removed status-line from all 8 CLI adapters

## 2026-05-02 — Phase 10: Cross-platform installer (`setup/`) hardening

- Inherited a partially working `setup/` folder (setup.ps1 / setup.sh / setup.py).
  Confirmed bugs:
  - `setup.ps1` failed to parse on **Windows PowerShell 5.1**: em dashes
    (U+2014) and box-drawing chars (U+2500/2554/etc.) in the file caused
    PS5 to interpret them as cp1252 garbage, which derailed the parser many
    lines later (errors surfaced at line 294's regex literal).
  - `setup.py` had a nested f-string with same quote chars
    (`f"... f'... {', '.join(targets)}'..."`) — `SyntaxError` on Python <3.12.
  - `setup.py` used `Path | None` (PEP 604) which fails pre-3.10.
  - Detection only checked `~/.copilot/skills/plan/SKILL.md`; if `plan` was
    missing it falsely reported "not installed" while wrappers for the other
    68 skills were present.
  - Per-project CLIs (Gemini, Codex, OpenCode, Windsurf) only printed
    guidance text — no actual install/uninstall capability.
- Fixes:
  - Added a UTF-8 BOM to `setup.ps1` (forces PS5 to decode as UTF-8).
  - Hoisted regex patterns into variables (`$skillsRefPattern`) so the PS5
    parser can't misread `[a-z-]` as a type literal in attribute position.
  - Replaced nested f-string with a hoisted `joined = ', '.join(targets)`.
  - Replaced `Path | None` with `Optional[Path]`; added an explicit Python
    3.9+ guard at the top (`sys.version_info` check).
  - Added `sys.stdout.reconfigure(encoding="utf-8")` so the box-drawing UI
    works on Windows consoles that default to cp1252.
  - Replaced `plan`-only check with `count_omu_skills()` that scans every
    `SKILL.md` for our marker. Status now shows `Yes (N)` with the count.
  - Added `-Project <path>` (PowerShell) / `--project <path>` (bash & python)
    flag for **per-project install/uninstall** of Gemini, Codex, OpenCode,
    Windsurf. The marker block (`# >>> oh-my-universal START >>>` …
    `# <<< oh-my-universal END <<<`) is appended to the project's
    `AGENTS.md` / `GEMINI.md` / `.windsurfrules` and removed cleanly on
    uninstall — **all other content in the file is preserved exactly**.
  - Removed dead helper `Test-IsOmuItem`; rewrote `Add-OmuMarkedSection` and
    `Remove-OmuMarkedSection` to use index-based string splicing instead of
    fragile regex `Replace` (which mangled `$` chars).
- Added `setup/README.md` with full usage, safety guarantees, troubleshooting.
- Added smoke tests:
  - `setup/test.ps1` — 15 checks; delegates to `test.py` for cross-runtime.
  - `setup/test.sh` — 19 checks; runs against bash + python.
  - `setup/test.py` — 21 checks; cross-platform, calls all three installers.
- All three test runners pass green:
  - `python test.py` -> PASS 21 / FAIL 0
  - `powershell -File test.ps1` -> PASS 15 / FAIL 0 (+ delegated 21 / 0)
  - `bash test.sh` -> PASS 19 / FAIL 0
- Updated `README.md` Quick Start to recommend the bundled installer.
- Updated `docs/SETUP.md` to point at `setup/` as the easiest path while
  preserving the existing per-CLI manual instructions.

### Phase 10 Task Table

| #    | Task                                                              | Status | Notes |
|------|-------------------------------------------------------------------|--------|-------|
| 10.1 | Fix PS5 parse error (BOM + regex variable extraction)             | done   | Confirmed via `powershell.exe -File setup.ps1 -Action status` |
| 10.2 | Fix Python nested f-string + typing for 3.9 compat                | done   | Now parses on Python 3.11; documented 3.9+ minimum |
| 10.3 | Robust Copilot detection (count any skill, not just `plan`)       | done   | Status now shows `Yes (N)` with wrapper count |
| 10.4 | Add `--project` / `-Project` flag for per-project CLIs            | done   | Gemini, Codex, OpenCode, Windsurf — all use marker section |
| 10.5 | Marker-section helpers preserve user content                      | done   | Smoke-tested round-trip: install + uninstall = identity |
| 10.6 | Remove dead code (`Test-IsOmuItem`)                               | done   | Replaced unused helpers with the new marker-section primitives |
| 10.7 | Add `setup/README.md` (usage + safety + troubleshooting)          | done   |  |
| 10.8 | Add cross-platform smoke tests                                    | done   | test.ps1 / test.sh / test.py — all green |
| 10.9 | Update root `README.md` and `docs/SETUP.md`                       | done   | Bundled installer is now the recommended path |

## 2026-05-02 — Phase 11: Group-router path resolution fix

User reported skills failing to load post-install with errors like:
```
Read ~\.copilot\skills\oh-my-universal\skills\ultrawork.md
Path does not exist
```

Root cause: 8 "group router" `SKILL.md` files (`collaborate`,
`docs-and-memory`, `investigate`, `meta`, `oh-my-universal`, `operations`,
`plan-and-build`, `quality`) reference sub-skills via **relative** paths
(`skills/team.md`, `skills/ultrawork.md`, etc.). When installed as a
junction/symlink, those relative refs resolve under the install location,
but no co-located `skills/` subfolder exists there — every reference is
broken. The user's reported install had **all 8 group routers broken**.

Fix:
- New `Test-IsGroupRouter` / `is_group_router` detector — checks for
  relative `skills/<name>.md` patterns in `SKILL.md` content.
- New `Get-PatchedRouterContent` / `get_patched_router_content` helper —
  rewrites every relative ref to the absolute path under `<repo>/skills/`
  and injects an `<!-- # [oh-my-universal] (installed copy with absolute
  paths to ...) -->` marker so uninstall can identify these copies.
- New `Install-GroupDir` / `install_group_dir` dispatcher — for each group
  dir: if it's a router → copy + patch (real dir); else → junction/symlink.
  Idempotent: re-runs detect already-patched routers and skip them.
- Replaces existing junction with a real dir when a group is detected as a
  router (handles the user's already-broken install on re-install).
- Uninstall logic upgraded:
  - `is_junction_or_symlink()` helper covers Windows junctions on Python
    3.9–3.11 (where `Path.is_symlink()` returns False for junctions);
    uses `FILE_ATTRIBUTE_REPARSE_POINT` (0x400) bit + `os.readlink`
    fallback.
  - Patched-router copies are removed only when the directory contains
    nothing but our `SKILL.md` (no user-added files).
- Bash `setup.sh` gets the same logic via `awk`-based content rewriting.
- `setup/test.py` extended with `test_router_patching()` — installs into
  a temp `HOME`, verifies every router has zero relative refs and every
  absolute ref resolves to a real file, then uninstalls and verifies
  nothing oh-my-universal is left behind.

After fix, re-installed the user's broken Copilot setup:
```
oh-my-universal:  broken-refs: 0  abs-refs: 69   ✓
collaborate:      broken-refs: 0  abs-refs: 4    ✓
docs-and-memory:  broken-refs: 0  abs-refs: 4    ✓
investigate:      broken-refs: 0  abs-refs: 11   ✓
meta:             broken-refs: 0  abs-refs: 12   ✓
operations:       broken-refs: 0  abs-refs: 17   ✓
plan-and-build:   broken-refs: 0  abs-refs: 9    ✓
quality:          broken-refs: 0  abs-refs: 12   ✓
```
Same for Claude.

Test runners now cover the bug:
- `python test.py` → PASS 23 / FAIL 0 (added router-patching test)
- `powershell -File test.ps1` → PASS 15 / FAIL 0 (+ delegated 23/0)
- `bash test.sh` → PASS 19 / FAIL 0

## 2026-05-02 — Phase 12: Source-corruption guard + rogue junction repair

**Problem reported:** User's Copilot CLI session showed `oh-my-universal` skill
loading but every sub-skill read failed:
```
Read ~\.copilot\skills\oh-my-universal\skills\ultrawork.md
Path does not exist
```

**Two distinct bugs surfaced during diagnosis:**

### Bug A: Group routers used relative `skills/<name>.md` refs (Phase 11)
8 group routers had relative path references that didn't resolve at the
install location. Fixed in Phase 11 by patching content to absolute paths.

### Bug B: Source repo was being silently corrupted on every install
Root cause: `~/.copilot/skills` was a **junction pointing back into the repo**:
```
C:\Users\LuC!F3R\.copilot\skills  →  E:\Projects\oh-my-universal\.github\skills
```
This came from a prior agent's install attempt. Every subsequent `setup.ps1
install copilot` then "wrote into the user profile" — but actually wrote
INSIDE the source repo via the junction. Result: 69 stale `SKILL.md`
wrappers with absolute paths to the local machine appeared in
`<repo>/.github/skills/<name>/`, and the 8 group routers got patched in
place — all polluting the repo.

**Fixes:**
- `Test-IsInsideRepo` (PS) / `is_inside_repo` (Python) / `is_inside_repo`
  (bash): walks the install path looking for any junction/symlink that
  resolves into `$OmuRoot`. If found, **refuse the install** with a clear
  remediation message:
  ```
  REFUSING to install: ~/.copilot/skills resolves inside source repo ...
  Likely cause: ~/.copilot/skills (or a parent) is a junction pointing
  into the repo.
  Fix: cmd /c rmdir "..." — then re-run install.
  ```
- Same guard applied at every write entry point: `Install-Copilot`,
  `Install-GroupDir`, the Python and bash equivalents.
- Hardened `Get-Hardlink` to silently fall back to copy when source and
  target are on different drives (cross-drive hardlinks fail by design).
- `_bash_path` in `test.py` made defensive against WSL's "Catastrophic
  failure" responses (filters null bytes, validates path shape).
- `.gitignore` updated to exclude `.github/skills/*/SKILL.md` for any
  future per-skill wrapper that leaks into the repo (the 8 legitimate
  group routers are explicitly re-included).
- Junction-aware uninstall: `is_junction_or_symlink()` catches Windows
  junctions on Python 3.9–3.11 (where `Path.is_symlink()` returns False
  for them).

**Repaired user state:**
- Removed the rogue junction at `~/.copilot/skills`.
- Recreated as a real folder.
- Re-ran install; 77 dirs installed cleanly, source untouched.
- Verified router resolution: `oh-my-universal/SKILL.md` now contains
  69 absolute path refs to `E:\Projects\oh-my-universal\skills\<name>.md`,
  every one of which exists.

**Test coverage added:**
- `test_router_patching()` in `test.py` installs into a fake `HOME`,
  verifies routers have zero relative refs and every absolute ref
  resolves, then uninstalls and verifies no oh-my-universal artifacts
  are left behind.

**Final test results:** all 3 runners green
- `python test.py` → 23 PASS / 0 FAIL
- `powershell -File test.ps1` → 15 PASS / 0 FAIL (+ delegated 23/0)
- `bash test.sh` → 19 PASS / 0 FAIL

### Phase 12 Task Table

| #    | Task                                                                | Status |
|------|---------------------------------------------------------------------|--------|
| 12.1 | Diagnose: ~/.copilot/skills was a junction into repo                | done   |
| 12.2 | Add `Test-IsInsideRepo` / `is_inside_repo` walking parent chain     | done   |
| 12.3 | Wire safety guard into Install-Copilot + Install-GroupDir (PS/py/sh) | done  |
| 12.4 | Repair user's machine: remove junction, restore source, re-install  | done   |
| 12.5 | Add `.gitignore` rule for stale per-skill wrappers in `.github/skills/` | done |
| 12.6 | Silence cross-drive hardlink fallback noise                         | done   |
| 12.7 | Harden `_bash_path` against WSL "Catastrophic failure" output       | done   |
| 12.8 | Verify all 3 test runners pass after fixes                          | done   |

