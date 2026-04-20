# Skill: deep-dive

> Two-stage investigation: evidence-driven causal tracing + Socratic questioning to expose hidden assumptions.
> Inspired by: oh-my-claudecode (deep-dive, trace, deep-interview)

## When to Trigger

- User says "deep dive", "investigate this thoroughly", "trace and analyze"
- When a bug or behavior is complex and root cause is unclear
- When requirements are vague AND there's existing code to analyze
- When you need both evidence gathering and assumption challenging

## Workflow

### Step 1 — Trace (Evidence-Driven Causal Analysis)

Form competing hypotheses and systematically gather evidence:

1. **Define the problem** — What is the observed behavior? What is expected?
2. **Form 2-4 hypotheses** about root cause BEFORE reading code
3. **For each hypothesis**, identify what evidence would confirm or refute it
4. **Gather evidence systematically:**
   - Search codebase (grep for relevant patterns)
   - Read key files and trace execution paths
   - Run tests to reproduce behavior
   - Check logs, configs, dependencies
5. **Score each hypothesis** based on evidence found
6. **Eliminate weak hypotheses** — only keep those with supporting evidence

Produce a hypothesis table:

| # | Hypothesis | Evidence For | Evidence Against | Status |
|---|------------|-------------|-----------------|--------|
| 1 | ... | ... | ... | CONFIRMED / REFUTED / UNCERTAIN |

### Step 2 — Interview (Socratic Questioning)

Using trace findings as context, probe deeper into ambiguities:

1. **Identify gaps** — What did the trace leave unresolved? What assumptions remain untested?
2. **Ask clarifying questions** across these dimensions:
   - **Intent:** What was the original design goal here?
   - **Constraints:** What limitations exist that aren't documented?
   - **Dependencies:** What external factors affect this behavior?
   - **History:** Why was it built this way? What changed since?
   - **Edge cases:** What happens under unusual conditions?
3. **For each question**, either:
   - Answer it from the codebase evidence (self-interview)
   - Flag it as needing user input
4. **Measure clarity** across dimensions after questioning

### Step 3 — Synthesize

Combine trace findings and interview insights into recommendations:
- What is confirmed vs. still uncertain
- What hidden assumptions were exposed
- What actions to take next

## Output Format

```markdown
## Deep Dive: {topic}

### Trace Findings
| # | Hypothesis | Evidence For | Evidence Against | Status |
|---|------------|-------------|-----------------|--------|
| 1 | {hypothesis} | {evidence} | {evidence} | CONFIRMED |
| 2 | {hypothesis} | {evidence} | {evidence} | REFUTED |

### Evidence Log
1. Checked `{file:line}` — found {what} — supports H1, refutes H2
2. Ran `{command}` — output showed {what} — supports H1
3. ...

### Interview Findings
| Dimension    | Clarity | Notes |
|--------------|---------|-------|
| Intent       | HIGH    | Original design goal was X |
| Constraints  | MEDIUM  | Undocumented limit on Y |
| Dependencies | LOW     | External service Z not accounted for |
| History      | HIGH    | Changed in PR #123 because of ... |
| Edge cases   | MEDIUM  | No handling for empty input |

### Unresolved Questions
- {question that needs user input}

### Recommendations
1. {action based on confirmed findings}
2. {action based on exposed assumptions}
3. {investigation needed for unresolved items}
```

## Rules

- ALWAYS trace first, interview second. Evidence before questions.
- Form hypotheses BEFORE reading code. Don't let the code lead your thinking.
- Every finding must cite specific evidence (file:line, command output, test result).
- Distinguish between confirmed findings and unverified hypotheses.
- If trace fully resolves the issue, the interview phase can be brief.
- If trace leaves significant gaps, the interview phase should be thorough.
- Flag questions you can't answer from the codebase — don't guess.

## Not Responsible For

- Fixing the issue (use plan + ultrawork after deep-dive produces recommendations)
- Simple debugging where the cause is obvious (use trace skill directly)
- Code review of changes (use review)
- General research without existing code context (use ask or web search)
