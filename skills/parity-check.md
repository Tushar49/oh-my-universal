# Skill: parity-check

> Agent health and contract smoke tests — verify tools, skills, and environment are working.
> Inspired by: oh-my-codex (parity-smoke/sweep), claw-code (parity harness)

## When to Trigger

- User says "parity check", "health check", "is everything working", "smoke test"
- After initial setup or install to verify the environment
- When unexpected tool failures occur (diagnose before debugging)
- Auto-run after setup (optional)

## Workflow

### Step 1 — Tool availability

Verify that expected tools are available and functional:

| Tool | How to verify |
|------|--------------|
| File read | Read a known file (e.g., `README.md` or any skill file) |
| File write | Create a scratch file, verify contents, delete it |
| Shell/bash | Run `echo "ok"` and verify output |
| Git | Run `git status` and verify it returns without error |
| Grep/search | Search for a known string in the project |
| Glob | Find files matching `*.md` pattern |

If a tool is unavailable (e.g., sandbox mode blocks shell), record as DEGRADED, not BROKEN.

### Step 2 — Skill file integrity

For each file in `skills/`:
1. Verify the file exists and is readable
2. Check it has the required sections: `# Skill:` or `# Workflow Spec:` header, `## When to Trigger` or `## Trigger`, at least one `## Workflow` or `## Rules` section
3. Check for broken cross-references (e.g., `skills/nonexistent.md`)

### Step 3 — Memory file check

If `.memory/` exists:
1. Verify files are readable
2. Check for corruption (empty files, malformed markdown)
3. Report memory file sizes (oversized memory files degrade performance)

### Step 4 — Smoke test

Run a quick end-to-end operation:
1. Create a temp file: `.parity-check-temp`
2. Write test content to it
3. Read it back and verify contents match
4. Delete the temp file
5. Verify deletion

This confirms the full read-write-delete cycle works.

### Step 5 — Report

Compile results into a health score.

## Output Format

```markdown
## Parity Check

### Tool Availability
| Tool | Expected | Actual | Status |
|------|----------|--------|--------|
| file read | ✓ | ✓ | PASS |
| file write | ✓ | ✓ | PASS |
| shell | ✓ | ✓ | PASS |
| git | ✓ | ✓ | PASS |
| grep | ✓ | ✓ | PASS |
| glob | ✓ | ✓ | PASS |

### Skill Files ({N} total)
| Skill | Path | Status |
|-------|------|--------|
| plan | skills/plan.md | PASS |
| review | skills/review.md | PASS |
| verify | skills/verify.md | PASS |

### Cross-References
- skills/pre-commit-check.md → skills/verify.md: OK
- skills/pre-commit-check.md → skills/review.md: OK

### Memory Files
| File | Size | Status |
|------|------|--------|
| .memory/conventions.md | 2.1 KB | OK |
| .memory/gotchas.md | 0.8 KB | OK |

### Smoke Test
- Create file: PASS
- Write content: PASS
- Read content: PASS
- Verify match: PASS
- Delete file: PASS

### Health: HEALTHY — {N}/{N} checks passed
```

Health scores:
- **HEALTHY** — all checks pass
- **DEGRADED** — some tools unavailable or warnings found, but core functionality works
- **BROKEN** — critical failures that prevent normal operation

## Rules

- Parity check is READ-ONLY except for the smoke test temp file (always clean up)
- Never modify skill files, memory files, or project files during a check
- Adapt tool names to the current CLI — don't hardcode tool names from a specific agent
- If a check fails, report the SPECIFIC failure (not just "FAIL")
- Doctor skill checks PROJECT health; parity-check checks AGENT health — they complement each other
- Keep the check fast (< 30 seconds) — it's a diagnostic, not a full test suite
- The temp file for smoke test must be cleaned up even if earlier steps fail

## Not Responsible For

- Project health or build status (see doctor skill)
- Code quality or security scanning (see review, verify, security-review skills)
- Fixing discovered issues — only diagnosing and reporting them
- Performance benchmarking of agent tools
