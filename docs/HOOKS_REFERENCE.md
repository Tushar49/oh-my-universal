# Hooks Reference

> Complete reference for all 19 built-in lifecycle hooks and hook definition patterns.
> For the hooks skill workflow (creating/managing hooks), see `skills/hooks.md`.

---

## Hook Points

| Event | When It Fires | Typical Use |
|-------|---------------|-------------|
| `pre-plan` | Before creating a plan | Inject context, load project memory |
| `post-plan` | After plan is created | Validate plan against constraints |
| `pre-edit` | Before modifying a file | Dirty-guard check, backup original |
| `post-edit` | After modifying a file | Format, lint, validate syntax |
| `pre-commit` | Before committing | Run pre-commit-check skill, quality gate |
| `post-commit` | After committing | Update docs, notify, tag release |
| `pre-test` | Before running tests | Set up fixtures, check test env |
| `post-test` | After tests complete | If tests fail, trigger build-fix |
| `on-error` | When any operation fails | Log to .memory/failures.md, suggest self-improve |
| `on-success` | When a full workflow completes | Notify, update progress tracker |

---

## Hook Types

### Guard Hooks
Guard hooks can **BLOCK** an operation. They return PASS or FAIL. If a guard fails, the operation does not proceed.

```
Type: guard
Event: pre-edit
Action: Check if working tree has unstaged changes in target file
Result: PASS -> continue | FAIL -> abort with message
```

Examples:
- **dirty-guard:** Block edits to files with uncommitted changes (prevent merge conflicts)
- **branch-guard:** Block commits to protected branches (main, production)
- **size-guard:** Block commits that add files over a size threshold

### Action Hooks
Action hooks perform **side effects**. They always run - they cannot block the operation.

```
Type: action
Event: post-commit
Action: Send notification via skills/notify.md
Result: Always continues (failures logged, not fatal)
```

Examples:
- **notify:** Send Discord/system notification when long tasks complete
- **log:** Append operation details to .memory/session-log.md
- **progress:** Update progress tracker after completing a task

### Transform Hooks
Transform hooks **modify** the operation's input or output. They receive data, transform it, and pass it along.

```
Type: transform
Event: post-edit
Action: Normalize curly quotes to straight quotes, em-dashes to hyphens
Result: Modified content replaces original output
```

Examples:
- **ats-normalize:** Clean special characters for ATS compatibility
- **format:** Run project formatter on edited files
- **inject-context:** Add project-specific context to agent prompts

---

## Hook Definition

Hooks are defined in the `.hooks/` directory. Each hook is a markdown file or shell script.

### Markdown Hook (`.hooks/{name}.md`)

```markdown
# Hook: dirty-guard

Event: pre-edit
Type: guard
Enabled: true
Priority: 10

## Condition
Target file has unstaged changes in git.

## Action
Check `git diff --name-only` for the target file.
If file appears in the diff, FAIL with:
"File {path} has uncommitted changes. Commit or stash first."

## On Fail
Block the edit. Show the uncommitted diff to the user.
```

### Shell Hook (`.hooks/{name}.sh`)

```bash
#!/bin/bash
# Hook: format-on-save
# Event: post-edit
# Type: action
# Priority: 20

# $1 = file path that was edited
npx prettier --write "$1" 2>/dev/null || true
```

### Hook Properties

| Property | Required | Description |
|----------|----------|-------------|
| `Event` | Yes | Which hook point this attaches to |
| `Type` | Yes | `guard`, `action`, or `transform` |
| `Enabled` | No | Default `true`. Set `false` to disable without deleting. |
| `Priority` | No | Execution order (lower = earlier). Default `50`. |
| `Condition` | No | When this hook should actually fire (subset of the event) |

---

## Execution Order

1. Hooks for the same event run in **priority order** (lowest number first)
2. Guard hooks run **before** action and transform hooks
3. If ANY guard hook returns FAIL, the operation is aborted - remaining hooks do not run
4. Action hooks run independently - one failure does not affect others
5. Transform hooks run in sequence - each receives the output of the previous

```
Event fires
  -> Guard hooks (priority order) -> any FAIL? -> ABORT
  -> Transform hooks (priority order) -> chain input/output
  -> Action hooks (priority order) -> fire-and-forget
  -> Operation proceeds
```

---

## Built-in Hook Library

19 pre-defined hooks in `hooks/` covering the complete agent lifecycle.

| Category | Hooks | Count |
|----------|-------|-------|
| Session | session-start, session-end | 2 |
| Tool | pre-tool, post-tool, tool-failure | 3 |
| Skill | skill-start, skill-end | 2 |
| Keyword | keyword-detector | 1 |
| Memory | memory-save, memory-load | 2 |
| Safety | permission-check, dirty-guard-hook, context-guard | 3 |
| Quality | verify-deliverables, code-simplifier-hook | 2 |
| Subagent | subagent-start, subagent-end | 2 |
| Context | pre-compact, context-inject | 2 |
| **Total** | | **19** |

---

## Built-in Hooks (Detailed)

### `pre-commit` -> Quality Gate
```
Event: pre-commit
Type: guard
Action: Run skills/pre-commit-check.md (verify + review + security)
On Fail: Show findings, recommend fixing before commit
```

### `post-commit` -> Documentation & Notify
```
Event: post-commit
Type: action
Action:
  1. Run skills/doc-maintainer.md on affected docs
  2. Run skills/notify.md if long-running session
```

### `on-error` -> Learn from Failure
```
Event: on-error
Type: action
Action:
  1. Log error details to .memory/failures.md
  2. Check if error matches a known pattern in .memory/
  3. Suggest running skills/self-improve.md if pattern is recurring
```

### `pre-edit` -> Dirty Guard
```
Event: pre-edit
Type: guard
Action: Check git status for target file
On Fail: Warn about uncommitted changes, suggest stash or commit first
```

### `post-test` -> Auto-Fix on Failure
```
Event: post-test
Type: action
Condition: Tests failed
Action: Trigger skills/build-fix.md to attempt automated repair
```

---

## CLI-Specific Implementation

Hook implementation varies by CLI. The concepts are universal; the wiring is not.

| CLI | Implementation |
|-----|---------------|
| Claude Code | `hooks.json` with Node.js scripts at `.claude/hooks.json` |
| Codex CLI | `.codex/hooks.json` with shell commands |
| Copilot CLI | No native hooks - embed as behavioral instructions in `copilot-instructions.md` |
| Cursor | `.cursor/rules/*.mdc` for rules-based hooks |
| Markdown-only CLIs | Hooks become behavioral instructions the agent follows voluntarily |

### For CLIs Without Native Hooks

When the CLI does not support programmatic hooks, the agent should:
1. **Read** `.hooks/` directory at session start to learn what hooks are configured
2. **Self-enforce** guard hooks by checking conditions before operations
3. **Self-trigger** action hooks after operations complete
4. **Apply** transform hooks to output before presenting to the user

This is advisory, not enforced - the agent follows the hooks as instructions, not as hard gates.

---

## Hook Templates

Create hook templates in `templates/hooks/` for reusable hook patterns:
- `stop-continuation.md` - Auto-stop when task is complete (prevent over-engineering)
- `code-simplifier.md` - Delegate simplification after implementation
- `delegation-enforcer.md` - Enforce delegation rules in team mode

Templates can be copied to project `.hooks/` directories and customized.
