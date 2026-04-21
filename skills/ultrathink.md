# Skill: ultrathink

> Deep reasoning mode — extended thinking for complex problems where the obvious answer is wrong.
> Inspired by: oh-my-claudecode ultrathink mode

## When to Trigger

- User says "think deeply", "ultrathink", "reason through this", "what's the best approach"
- Ambiguous requirements where multiple valid interpretations exist
- Complex architecture decisions with long-term consequences
- Tricky bugs where the surface-level fix might cause regressions
- Design tradeoffs with no clear winner
- When you catch yourself reaching for the first solution — stop and ultrathink

## Workflow

### Step 1 — Frame the Decision

State the core question clearly in one sentence. Then identify:
- **Stakes:** What breaks if we choose wrong? (LOW / MEDIUM / HIGH / IRREVERSIBLE)
- **Constraints:** What limits our options? (time, compatibility, performance, team skill)
- **Success criteria:** How will we know the decision was right in 6 months?

### Step 2 — Enumerate ALL Options

List every viable option, including unconventional ones:
- The obvious choice
- The opposite of the obvious choice
- The "do nothing" option
- The hybrid / compromise option
- The radical rethink option

For each option, write a one-line description. Do NOT evaluate yet — just enumerate.

### Step 3 — Evaluate Each Option

For every option, assess against consistent criteria:

| Option | Complexity | Risk | Maintainability | Performance | Reversibility |
|--------|-----------|------|-----------------|-------------|---------------|
| A      | LOW       | LOW  | HIGH            | MEDIUM      | EASY          |
| B      | HIGH      | MED  | MEDIUM          | HIGH        | HARD          |

For each option, also write:
- **Pros:** 2-3 specific advantages (not generic)
- **Cons:** 2-3 specific disadvantages (not generic)
- **Hidden risks:** What could go wrong that isn't obvious?
- **Second-order effects:** What does this decision force or prevent later?

### Step 4 — Stress-Test the Top 2

Take the two strongest options and attack them:
- What's the strongest argument AGAINST option A?
- What's the strongest argument AGAINST option B?
- Under what conditions would each option fail?
- What would a senior engineer who disagrees with you say?

### Step 5 — Decide and Justify

Pick the winner. State:
- **Decision:** The chosen option
- **Confidence:** HIGH / MEDIUM / LOW
- **Key reason:** The single most important factor that tipped the scales
- **Mitigation:** How to handle the biggest downside of the chosen option
- **Reversal trigger:** What signal would tell you this was the wrong choice

## Output Format

```markdown
## Ultrathink: {decision question}

### Stakes
{what breaks if wrong} — {LOW/MEDIUM/HIGH/IRREVERSIBLE}

### Constraints
- {constraint 1}
- {constraint 2}

### Options
| # | Option | Summary |
|---|--------|---------|
| 1 | {name} | {one-line description} |
| 2 | {name} | {one-line description} |
| 3 | {name} | {one-line description} |

### Evaluation
| Option | Complexity | Risk | Maintainability | Performance | Reversibility |
|--------|-----------|------|-----------------|-------------|---------------|
| 1      | ...       | ...  | ...             | ...         | ...           |
| 2      | ...       | ...  | ...             | ...         | ...           |

### Stress Test
- **Against Option {A}:** {strongest counterargument}
- **Against Option {B}:** {strongest counterargument}

### Decision
**Winner:** Option {N} — {name}
**Confidence:** {HIGH/MEDIUM/LOW}
**Key reason:** {the decisive factor}
**Mitigation:** {how to handle the main downside}
**Reversal trigger:** {signal that this was wrong}
```

## Rules

- ALWAYS enumerate at least 3 options. If you can only think of 2, you haven't thought hard enough.
- Evaluate ALL options against the SAME criteria. No cherry-picking dimensions per option.
- Stress-test the top 2. If you skip this, you're just picking your first instinct with extra steps.
- Hidden risks and second-order effects are mandatory. These are where ultrathink earns its keep.
- If confidence is LOW, say so and explain what information would raise it.
- Time-box: ultrathink should take 2-5 minutes of reasoning, not 30. Deep doesn't mean slow.
- Don't ultrathink trivial decisions. If the stakes are LOW and reversibility is EASY, just pick one and move on.

## Not Responsible For

- Executing the chosen option (use plan or ultrawork for that)
- Debugging specific bugs (use trace for hypothesis-driven debugging)
- Requirements gathering (use analyst to clarify what needs to be built)
- Research or learning about a topic (use deep-dive for that)
