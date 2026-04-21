# Skill: deep-interview

> Socratic intent-clarification loop with ambiguity scoring - turn vague ideas into execution-ready specs before planning.
> Inspired by: oh-my-codex (deep-interview)

## When to Trigger

- User says "deep interview", "interview me", "clarify this first", "don't assume"
- Request is broad, ambiguous, or missing concrete acceptance criteria
- You need a requirements artifact before handing off to plan, ultrawork, or team
- User wants to avoid misaligned implementation from underspecified requirements

## Do NOT Trigger When

- Request already has concrete file/symbol targets and clear acceptance criteria
- User explicitly asks to skip planning and execute immediately
- User wants lightweight brainstorming only (use `plan` instead)
- A complete PRD/plan already exists and execution should start
- Simple bug fix or well-defined task (use `deep-dive` or `trace` instead)

## Why This Exists

Execution quality is bottlenecked by intent clarity, not implementation detail. A single expansion pass often misses why the user wants a change, where scope should stop, which tradeoffs are unacceptable, and which decisions require user approval. This skill applies Socratic pressure + quantitative ambiguity scoring so downstream skills begin with an explicit, testable, intent-aligned spec.

## Workflow

### Step 0 - Preflight Context

1. Parse the user's initial statement
2. Create an initial context snapshot:
   - Task statement
   - Desired outcome (stated or inferred)
   - Probable intent hypothesis (why they likely want this)
   - Known facts/evidence
   - Constraints
   - Open questions
   - Decision-boundary unknowns
3. Classify: **brownfield** (existing codebase) vs **greenfield**
4. For brownfield, gather relevant codebase context before questioning

### Step 1 - Initialize Clarity Dimensions

Score each dimension 0.0-1.0 (0=clear, 1=unknown):

| Dimension | Description |
|-----------|-------------|
| Intent | Why the user wants this change |
| Outcome | What end state they want |
| Scope | How far the change should go |
| Non-goals | What is explicitly out of scope |
| Constraints | Technical or business limits that must hold |
| Success Criteria | How completion will be judged |
| Decision Boundaries | What the agent can decide vs. what needs user approval |
| Context | Existing codebase understanding (brownfield only) |

Compute weighted ambiguity score (0.0 = fully clear, 1.0 = fully ambiguous).

### Step 2 - Socratic Interview Loop

Repeat until ambiguity <= threshold or max rounds reached:

**Depth profiles:**
- Quick: threshold 0.30, max 5 rounds
- Standard (default): threshold 0.20, max 12 rounds
- Deep: threshold 0.15, max 20 rounds

**Each round:**

1. Target the weakest clarity dimension
2. Follow stage priority:
   - Stage 1 (Intent-first): Intent, Outcome, Scope, Non-goals, Decision Boundaries
   - Stage 2 (Feasibility): Constraints, Success Criteria
   - Stage 3 (Grounding): Context Clarity (brownfield only)
3. Ask ONE question per round (never batch)
4. Apply the pressure ladder after each answer:
   - Ask for a concrete example or evidence
   - Probe the hidden assumption that makes the claim true
   - Force a boundary or tradeoff: what would you explicitly NOT do?
   - If answer describes symptoms, reframe toward root cause
5. Stay on the same thread when it has highest leverage - breadth without pressure is not progress
6. Re-score ambiguity after each answer

**Display format per round:**
```
Round {n} | Target: {weakest_dimension} | Ambiguity: {score}%

{question}
```

### Step 3 - Crystallize Specification

When ambiguity threshold is met AND Non-goals + Decision Boundaries are resolved:

1. Produce the Interview Artifact:

```markdown
## Interview Summary: {topic}

### Intent
{why the user wants this}

### Desired Outcome
{concrete end state}

### Scope
{what's in scope}

### Non-goals
{what's explicitly excluded}

### Decision Boundaries
- Agent can decide: {list}
- Requires user approval: {list}

### Constraints
{technical/business limits}

### Success Criteria
{how completion is verified}

### Ambiguity Score
Initial: {start}% -> Final: {end}%
Rounds used: {n} / {max}

### Open Items (if any)
{items user chose to defer}
```

2. Save to `.artifacts/deep-interview/{slug}-{timestamp}.md`

### Step 4 - Handoff

Present the crystallized spec and suggest next step:
- If scope is clear and small: suggest `plan` or direct execution
- If scope is large and needs architecture: suggest `architecture` then `plan`
- If scope needs team coordination: suggest `team`
- If user wants persistent completion: suggest `ultrawork` or `ralph`

## Rules

- Ask about intent and boundaries BEFORE implementation detail
- Treat every answer as a claim to pressure-test before moving on
- Do NOT rotate to a new dimension just for coverage when the current answer is still vague
- Before crystallizing, complete at least one pressure pass revisiting an earlier answer
- Gather codebase facts via search/read before asking user about internals
- Reduce user effort: never ask for facts that can be discovered directly from code
- For brownfield work, prefer evidence-backed confirmation: "I found X in Y. Should this follow that pattern?"
- Do not crystallize while Non-goals or Decision Boundaries remain unresolved
- Treat early exit as a safety valve, not the default path

## Output Format

The Interview Artifact produced in Step 3 is the primary output:

```markdown
## Interview Summary: {topic}

### Intent
{why the user wants this}

### Desired Outcome
{concrete end state}

### Scope
{what's in scope}

### Non-goals
{what's explicitly excluded}

### Decision Boundaries
- Agent can decide: {list}
- Requires user approval: {list}

### Constraints
{technical/business limits}

### Success Criteria
{how completion is verified}

### Ambiguity Score
Initial: {start}% → Final: {end}%
Rounds used: {n} / {max}

### Open Items (if any)
{items user chose to defer}
```

Saved to `.artifacts/deep-interview/{slug}-{timestamp}.md`.

## Not Responsible For

- Executing the work (hand off to plan/ultrawork/team after crystallizing)
- Code review (use review)
- Bug investigation where code already exists to analyze (use deep-dive or trace)
- Lightweight brainstorming without rigor (use plan)
