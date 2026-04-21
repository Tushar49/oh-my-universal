# Skill: container-sandbox

> Container-isolated agent execution for safety. Run risky operations in Docker/Podman sandboxes.
> Inspired by: claw-code container-first workflow, awesome-claude-code container runners

## When to Trigger

- User says "run in container", "sandbox this"
- Automatically triggered for HIGH risk operations
- When installing unknown dependencies or running arbitrary shell commands
- When the user wants to test destructive operations safely

## Workflow

### Step 1 — Risk Assessment

Classify the operation by risk level:

| Risk | Operations | Action |
|------|-----------|--------|
| LOW | File reads, grep, git log, lint, type-check | Run directly — no container needed |
| MEDIUM | File writes, npm/pip install, build commands, test suites | Offer container — let user decide |
| HIGH | Arbitrary shell commands, curl piped to shell, unknown scripts, rm -rf, database migrations | Require container — refuse to run directly |

If the user explicitly asks to skip the container, warn them and proceed only after confirmation.

### Step 2 — Container Detection

Check for available container runtimes:

1. `docker --version` — prefer Docker if available
2. `podman --version` — use Podman as fallback
3. If neither is available, warn the user and offer alternatives:
   - Run with extra caution (git stash first, verify each step)
   - Skip the operation entirely
   - Guide user through container installation

### Step 3 — Container Setup

Configure the container based on risk level:

**MEDIUM risk (read-write mount):**
```bash
docker run --rm -it \
  -v "$(pwd):/workspace" \
  -w /workspace \
  {base-image} \
  {command}
```

**HIGH risk (read-only mount + temp workspace):**
```bash
docker run --rm -it \
  -v "$(pwd):/workspace:ro" \
  -v "$(pwd)/.sandbox-out:/output" \
  -w /workspace \
  --network=none \
  {base-image} \
  {command}
```

Base image selection:
- Node.js projects: `node:20-slim`
- Python projects: `python:3.12-slim`
- Generic: `ubuntu:24.04`
- Custom: read `Dockerfile` or `.devcontainer/` if present

### Step 4 — Execute

Run the operation inside the container:
- Stream stdout/stderr to the user in real-time
- Capture exit code
- If the operation modifies files (MEDIUM risk), the changes appear in the mounted volume
- If HIGH risk with read-only mount, copy approved outputs from `/output` to the project

### Step 5 — Execution Report

After the container exits, produce a report.

## Output Format

```markdown
## Sandbox Execution Report

### Operation
- **Command:** {what was run}
- **Risk level:** {LOW / MEDIUM / HIGH}
- **Container:** {docker / podman / direct}
- **Image:** {image used}
- **Mount mode:** {read-write / read-only}
- **Network:** {enabled / disabled}

### Result
- **Exit code:** {0 / non-zero}
- **Duration:** {time}
- **Stdout:** {summary or full output}
- **Stderr:** {errors if any}

### Files Changed
| File | Action | Size |
|------|--------|------|
| {path} | created | {size} |
| {path} | modified | {diff size} |
| {path} | deleted | — |

### Safety Notes
- {any warnings, unexpected behavior, or security observations}
```

## Rules

- HIGH risk operations MUST use a container. Do not bypass this without explicit user override.
- ALWAYS use `--rm` flag. Don't leave container artifacts behind.
- For HIGH risk, ALWAYS use `--network=none` unless network access is explicitly required.
- NEVER mount sensitive directories (`.git/`, `.env`, credentials) into HIGH risk containers.
- If a container fails to start, fall back gracefully — don't silently run the command directly.
- The execution report is mandatory. Always show what happened inside the container.
- If the project has a Dockerfile or devcontainer config, prefer that over generic images.

## Not Responsible For

- Managing long-running containers or services (use Docker Compose directly)
- CI/CD pipeline configuration (use release or build-fix skills)
- Container image building or publishing
- Virtual machine management
- Deciding what operations to run (other skills decide — this skill only provides the sandbox)
