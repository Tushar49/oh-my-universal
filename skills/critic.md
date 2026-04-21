# Skill: critic

> Structured multi-perspective review with investigation protocol.
> The final quality gate — evaluates plans, code, and analysis with mathematical rigor.
> Inspired by: oh-my-claudecode (critic agent)

## When to Trigger

- Before executing a plan (consensus-plan's critic step)
- User says "critique this", "find the flaws", "challenge this plan"
- After a plan is drafted but before implementation begins
- When review skill finds issues and deeper analysis is needed
- For high-risk work: auth, migrations, data changes, public APIs

## How This Differs From review

| review | critic |
|--------|--------|
| Reviews CODE changes (diffs) | Reviews PLANS, designs, and analysis |
| 4 dimensions (correctness, security, logic, breaking) | 5-phase investigation protocol |
| Quick pass, max 5 findings | Exhaustive: pre-commitment, multi-perspective, gap analysis |
| Triggered on git diffs | Triggered on plans, specs, proposals |

## Workflow

### Phase 1 — Pre-commitment

Before reading the work in detail, predict the 3-5 most likely problem areas based on the type of work and its domain. Write them down. Then investigate each specifically.

This activates **deliberate search** rather than passive reading.

### Phase 2 — Verification

Read the work thoroughly. Extract ALL:
- File references and function names
- Technical claims and assumptions
- Dependencies and ordering requirements

Verify each against the actual codebase.

**For plans/proposals:**
1. **Key Assumptions:** List every assumption (explicit AND implicit). Rate each:
   - VERIFIED — evidence in codebase/docs
   - REASONABLE — plausible but untested
   - FRAGILE — could easily be wrong (highest priority targets)

2. **Pre-Mortem:** "Assume this plan was executed exactly as written and failed. Generate 5 specific failure scenarios." Check if the plan addresses each.

3. **Dependency Audit:** For each step: inputs, outputs, blocking dependencies. Check for circular deps, missing handoffs, implicit ordering.

4. **Ambiguity Scan:** For each step: "Could two developers interpret this differently?" If yes, document both interpretations and the risk.

5. **Feasibility Check:** For each step: "Does the executor have everything needed to complete this without asking questions?"

**For code:**
- Trace execution paths, especially error paths
- Check for off-by-one, race conditions, null checks, type assumptions

### Phase 3 — Multi-Perspective Review

**For code:**
- **Security Engineer:** Trust boundaries crossed? Input not validated? Exploitable?
- **New Hire:** Could someone unfamiliar follow this? What context is assumed?
- **Ops Engineer:** What happens at scale? Under load? When dependencies fail?

**For plans:**
- **Executor:** "Can I do each step with only what's written here?"
- **Stakeholder:** "Does this actually solve the stated problem?"
- **Skeptic:** "What is the strongest argument this approach will fail?"

### Phase 4 — Gap Analysis

Explicitly look for what is MISSING:
- "What would break this?"
- "What edge case isn't handled?"
- "What assumption could be wrong?"
- "What was conveniently left out?"

### Phase 4.5 — Self-Audit

Re-read your findings. For each CRITICAL/MAJOR:
1. Confidence: HIGH / MEDIUM / LOW
2. "Could the author refute this with context I'm missing?"
3. "Is this a genuine flaw or a stylistic preference?"

- LOW confidence → move to Open Questions
- Stylistic preference → downgrade to MINOR or remove

### Phase 5 — Verdict

| Verdict | Meaning |
|---------|---------|
| APPROVE | Ready for execution |
| ITERATE | Specific issues need addressing, then re-review |
| REJECT | Fundamental problems — needs rethinking |

## Output Format

```markdown
## Critic Review: {subject}

### Pre-commitment Predictions
1. {predicted problem area} — {confirmed/not found}

### Findings

#### 🔴 CRITICAL: {title}
Severity: CRITICAL
Evidence: {file:line or quoted excerpt}
Fix: {concrete, actionable fix}

#### 🟠 MAJOR: {title}
Severity: MAJOR
Evidence: {evidence}
Fix: {fix}

#### 🟡 MINOR: {title}
Severity: MINOR
Note: {observation}

### Gap Analysis
- Missing: {what's absent}
- Assumed: {unstated assumptions}

### Open Questions (low confidence)
- {things that might be issues but need more context}

### Verdict: {APPROVE / ITERATE / REJECT}
Justification: {why this verdict}
```

## Rules

- Every CRITICAL/MAJOR finding must include evidence (file:line or quoted text)
- Every finding must include a concrete fix, not just a complaint
- Don't invent problems — if it's solid, say "Looks good" and move on
- Don't soften language to be polite — be direct and specific
- Distinguish genuine issues from stylistic preferences
- Self-audit is mandatory — remove low-confidence findings from main list
- Max severity ratings: CRITICAL (blocks execution), MAJOR (significant rework), MINOR (suboptimal)

## Not Responsible For

- Creating plans (see plan, consensus-plan)
- Implementing fixes (see ultrawork)
- Gathering requirements (see deep-interview)
- Code-level review of diffs (see review)
