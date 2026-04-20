# Skill: autopilot

> Fully autonomous 5-phase pipeline: idea to validated working code with zero human intervention.
> Inspired by: oh-my-claudecode (autopilot)

## When to Trigger

- User says "autopilot", "build me", "handle it all", "end to end", "full auto"
- When a vague idea needs to go from concept to working code autonomously
- Key difference from ultrawork: autopilot starts from a VAGUE IDEA, ultrawork starts from a CLEAR TASK

## Workflow

```
1. EXPAND      → Clarify idea into requirements and technical spec
2. PLAN        → Create execution plan, get critique
3. EXECUTE     → Implement the plan using existing skills
4. QA          → Build/lint/test pass with iterative fix cycles (max 5)
5. VALIDATE    → Multi-perspective review (functional, security, quality)
```

### Step 1 — Expand

Act as analyst + architect. Take the user's vague idea and produce:
- A clear problem statement
- Functional requirements (what it must do)
- Non-functional requirements (performance, security, compatibility)
- Technical spec: key components, data flow, API surface
- Out of scope: what this does NOT include

Save the expansion to a spec document or present inline.

If `pause-after-expansion` is set, stop here and share the spec with the user for feedback before continuing.

### Step 2 — Plan

Follow the planning workflow from skills/plan.md (or invoke the named skill if the platform supports it):
- Create a structured plan based on the spec from Step 1
- Include file changes, ordering, and risks
- Self-critique the plan: challenge assumptions, look for gaps
- Revise if the critique finds issues

If `pause-after-planning` is set, stop here and share the plan with the user for feedback before continuing.

### Step 3 — Execute

Implement the plan:
- Follow the execution approach from skills/ultrawork.md
- Make changes file by file in planned order
- If a surprise comes up, revise the plan before continuing
- Track all files created and modified

### Step 4 — QA

Ensure everything works. Run iterative fix cycles (max 5):

```
for cycle in 1..5:
  1. Run build command
  2. Run linter
  3. Run test suite
  4. If all pass → move to Step 5
  5. If failures → fix the issues, increment cycle
  6. If cycle 5 still fails → STOP, report failures
```

Report which cycle achieved green, or what remains broken after 5 cycles.

### Step 5 — Validate

Perform multi-perspective review across three dimensions:

**Functional Review:**
- Does the implementation satisfy all requirements from the spec?
- Are edge cases handled?
- Does it integrate correctly with existing code?

**Security Review:**
- Any hardcoded secrets, injection vectors, unsafe operations?
- Are inputs validated? Are permissions checked?

**Quality Review:**
- Is the code clean and maintainable?
- Are there obvious performance issues?
- Is error handling adequate?

For each dimension, produce a verdict: APPROVED / NEEDS_FIX / REJECTED.
- If any dimension is NEEDS_FIX, fix and re-validate (max 2 rounds).
- If any dimension is REJECTED, stop and report to the user.

## Output Format

```markdown
## Autopilot Summary: {task title}

### Spec
{1-2 sentence summary of expanded requirements}

### Plan
{1-2 sentence summary of approach}

### Execution
- Files created: {list}
- Files modified: {list}

### QA
- Cycles needed: {N}/5
- Build: PASS/FAIL
- Lint: PASS/FAIL
- Tests: PASS/FAIL

### Validation
| Dimension  | Verdict    | Notes |
|------------|------------|-------|
| Functional | APPROVED   |       |
| Security   | APPROVED   |       |
| Quality    | NEEDS_FIX  | ...   |

### Duration
| Phase    | Time   |
|----------|--------|
| Expand   | {time} |
| Plan     | {time} |
| Execute  | {time} |
| QA       | {time} |
| Validate | {time} |
| Total    | {time} |
```

## Rules

- If ANY phase fails irrecoverably, stop and report. Don't push through.
- Autopilot composes existing skills (plan, ultrawork, verify, review). Follow their workflows where referenced.
- The expansion phase is what separates autopilot from ultrawork. Don't skip it.
- QA fix cycles are capped at 5. If still broken, escalate to the user.
- Validation re-checks are capped at 2 rounds.
- User can set `pause-after-expansion` or `pause-after-planning` to review intermediate output before continuing.
- Always report phase durations in the summary.

## Not Responsible For

- Clear, well-specified tasks (use ultrawork instead)
- Standalone planning without execution (use plan)
- Code review of external changes (use review)
- Deployment or release (use release/deploy skills if available)
