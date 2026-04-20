# Skill: trace

> Evidence-driven debugging with structured hypothesis testing. Hypotheses first, then evidence.
> Inspired by: oh-my-claudecode (tracer agent, trace)

## When to Trigger

- User says "trace this", "debug this", "why is this happening"
- When a bug is reproducible but root cause is unclear
- When multiple possible causes exist and need systematic elimination
- When you're tempted to just read random code — stop and trace instead

## Workflow

### Step 1 — Define the Problem

Before touching any code, clearly state:
- **Observed behavior:** What is actually happening?
- **Expected behavior:** What should happen instead?
- **Reproduction:** How to trigger the bug (command, input, steps)
- **Scope:** What parts of the codebase are likely involved?

### Step 2 — Form Hypotheses

Generate 2-4 competing hypotheses about root cause BEFORE reading code:

For each hypothesis:
- State the hypothesis clearly
- Assign a prior probability (gut feeling: HIGH / MEDIUM / LOW)
- Identify what evidence would CONFIRM it
- Identify what evidence would REFUTE it

Do this from your understanding of the problem and the system, not from reading the code. The point is to avoid anchoring bias.

### Step 3 — Gather Evidence

Systematically test each hypothesis:

1. **Search** — grep for relevant patterns, function names, error messages
2. **Read** — examine the specific files and lines each hypothesis predicts are involved
3. **Run** — execute tests, reproduce the bug, check logs
4. **Trace** — follow the execution path through the code

For each piece of evidence found:
- Record what you checked and what you found
- Note which hypotheses it supports or refutes
- Update your confidence in each hypothesis

### Step 4 — Score and Eliminate

After gathering evidence, score each hypothesis:
- **CONFIRMED** — Strong evidence supports it, nothing refutes it
- **LIKELY** — More evidence for than against, but not conclusive
- **UNCERTAIN** — Mixed evidence, can't determine
- **REFUTED** — Strong evidence against it

Eliminate REFUTED hypotheses. Focus remaining investigation on CONFIRMED or LIKELY ones.

If all hypotheses are refuted, form new ones based on what you learned and repeat from Step 2.

### Step 5 — Present Verdict

Declare the root cause with:
- The winning hypothesis
- Confidence level (HIGH / MEDIUM / LOW)
- Complete evidence chain that led to the conclusion
- Recommended fix

## Output Format

```markdown
## Trace: {problem description}

### Problem
- **Observed:** {what happens}
- **Expected:** {what should happen}
- **Repro:** {how to trigger}

### Hypotheses
| # | Hypothesis | Prior | Evidence For | Evidence Against | Posterior |
|---|------------|-------|-------------|-----------------|----------|
| 1 | {cause A} | HIGH | {evidence} | — | CONFIRMED |
| 2 | {cause B} | MEDIUM | {evidence} | {evidence} | REFUTED |
| 3 | {cause C} | LOW | — | {evidence} | REFUTED |

### Evidence Log
1. `grep -r "pattern" src/` — found 3 matches in `auth.ts` — supports H1
2. Read `src/auth.ts:45-60` — validates token incorrectly — supports H1
3. Ran `npm test -- auth` — test passes but doesn't cover this path — neutral
4. Read `src/middleware.ts:12` — correctly passes token — refutes H2

### Verdict
**Root cause:** H1 — {description} (confidence: HIGH)
**Evidence chain:** {file:line} shows X, which causes Y, leading to observed behavior Z
**Recommended fix:** {specific action to fix the issue}
```

## Rules

- ALWAYS form hypotheses BEFORE reading code. This is the core discipline.
- Every claim must cite evidence (file:line, command output, test result). No speculation.
- If you can't find evidence for or against a hypothesis, say so. Don't fill gaps with guesses.
- Max 4 hypotheses to start. If all are refuted, form new ones (max 2 additional rounds).
- Don't go down rabbit holes — if a line of investigation isn't producing evidence after reasonable effort, move on.
- If confidence is LOW after full investigation, say so. A low-confidence answer is better than a wrong confident one.

## Not Responsible For

- Fixing the bug (present the verdict, then use plan/ultrawork to fix)
- Investigating vague requirements without a specific bug (use deep-dive)
- Performance profiling (use perf-audit)
- Security auditing (use security-review)
