# Skill: autoresearch

> Systematic multi-source research before implementation. Survey the landscape, then recommend.
> Inspired by: oh-my-claudecode (autoresearch), oh-my-codex (autoresearch)

## When to Trigger

- User says "research this", "investigate options", "what's the best approach for", "survey"
- Before adopting a new library, framework, or tool
- When multiple viable approaches exist and you need to pick one
- When implementing something unfamiliar and you need external knowledge first
- When you're about to guess — stop and research instead

## Workflow

### Step 1 — Define the Research Question

Clearly state:
- **Question:** What are we trying to find out?
- **Context:** Why does this matter? What's the use case?
- **Constraints:** What limits the solution? (language, performance, compatibility, license)
- **Decision criteria:** How will we evaluate options? (popularity, maintenance, performance, API design)

### Step 2 — Survey Sources

Research across multiple sources in parallel where possible:

1. **Codebase** — grep/read for existing patterns, prior art, or relevant code
2. **Documentation** — official docs for tools/libraries under consideration
3. **Web search** — articles, tutorials, comparisons, benchmarks
4. **GitHub** — stars, issues, recent activity, release frequency, open PRs
5. **Stack Overflow** — common problems, gotchas, community consensus
6. **GitHub Issues** — known bugs, feature requests, breaking changes
7. **Changelogs/RFCs** — recent changes, deprecations, migration paths

For each source, record:
- What was found
- How relevant it is (HIGH / MEDIUM / LOW)
- How recent the information is (date if available)

### Step 3 — Cross-validate

Compare findings across sources:
- Do multiple sources agree? → HIGH confidence
- Only one source says it? → LOW confidence, needs verification
- Sources contradict? → Flag as uncertain, note both positions

### Step 4 — Synthesize

Organize findings into:
- **Well-established:** Multiple sources confirm, high confidence
- **Probable:** Some evidence, moderate confidence
- **Uncertain:** Conflicting or insufficient evidence
- **Needs experimentation:** Can't determine from research alone, must try it

### Step 5 — Recommend

Based on the research, provide:
- **Recommendation:** The best option given the constraints
- **Runner-up:** Second choice and when you'd pick it instead
- **Avoid:** Options that looked promising but have deal-breakers
- **Next steps:** What to do with this knowledge (implement, prototype, experiment)

## Output Format

```markdown
## Research: {topic}

### Question
{what we're investigating}

### Constraints
- {constraint 1}
- {constraint 2}

### Findings by Source

#### Codebase
- {existing patterns found}
- Relevance: {HIGH/MEDIUM/LOW}

#### Documentation
- {key findings from official docs}
- Relevance: {HIGH/MEDIUM/LOW}

#### Web / Community
- {articles, benchmarks, opinions}
- Relevance: {HIGH/MEDIUM/LOW}

#### GitHub Activity
- {stars, issues, release cadence}
- Relevance: {HIGH/MEDIUM/LOW}

### Comparison Matrix
| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| {criterion 1} | {rating} | {rating} | {rating} |
| {criterion 2} | {rating} | {rating} | {rating} |
| {criterion 3} | {rating} | {rating} | {rating} |

### Confidence Assessment
- **Well-established:** {findings with high confidence}
- **Probable:** {findings with moderate confidence}
- **Uncertain:** {findings needing more investigation}
- **Needs experimentation:** {things that can only be settled by trying}

### Recommendation
**Pick:** {option} — {why}
**Runner-up:** {option} — {when you'd pick this instead}
**Avoid:** {option} — {deal-breaker reason}

### Next Steps
1. {action item}
2. {action item}
```

## Rules

- ALWAYS check the codebase first. The best solution is often already partially there.
- Cross-validate before recommending. A single blog post is not enough to base a decision on.
- Date your sources. A 2019 article about a JS framework may be completely irrelevant today.
- State confidence levels honestly. "I found one Reddit comment" is not HIGH confidence.
- Don't research forever. Set a time box. If you can't find enough after reasonable effort, say what's uncertain and move on.
- Separate facts from opinions. "Library X has 50k stars" is a fact. "Library X is the best" is an opinion.
- Include the "avoid" section. Knowing what NOT to use is as valuable as knowing what to use.

## Not Responsible For

- Investigating existing codebase internals (use deep-dive for that)
- Debugging specific bugs (use trace for that)
- Actually implementing the chosen solution (use plan or ultrawork)
- Security auditing of dependencies (use security-review)
- Performance benchmarking (use perf-audit)
