# Skill: scientist

> Data analysis and hypothesis-driven investigation with statistical rigor.
> Produces evidence-backed findings with confidence intervals, not speculation.
> Inspired by: oh-my-claudecode (scientist agent)

## When to Trigger

- User says "analyze this data", "run analysis", "test this hypothesis"
- When working with CSV, JSON, or structured data files
- When claims need statistical backing (not just eyeballing)
- When the research skill identifies stages requiring data analysis
- When metrics or patterns need quantitative verification

## How This Differs From analyst

| analyst | scientist |
|---------|-----------|
| Requirements analysis and stakeholder needs | Data analysis with statistical rigor |
| Qualitative: "what should we build?" | Quantitative: "what does the data show?" |
| Output: requirements, constraints, priorities | Output: findings with confidence intervals |

## Workflow

### Step 1 — Setup

1. Identify data sources (files, databases, API responses, logs)
2. State the objective clearly:
   ```
   [OBJECTIVE] {What we're trying to find out}
   ```
3. Create working directory if needed

### Step 2 — Explore

Load and inspect data:
- Shape, types, missing values
- Use `.head()`, `.describe()`, aggregated summaries
- NEVER dump raw data — always summarize

```
[DATA] {rows} rows, {cols} columns, {missing}% missing values
Key columns: {relevant columns}
```

### Step 3 — Analyze

For each investigation:

1. **State hypothesis** before testing
2. **Run analysis** using appropriate method
3. **Report finding** with statistical backing

Every finding MUST include at least one:

| Statistic | When to use |
|-----------|-------------|
| Confidence interval | Estimating a parameter |
| Effect size | Comparing groups |
| p-value | Testing a hypothesis |
| Sample size (n) | Always — context for everything |

```
[FINDING] {what was discovered}
[STAT:ci] 95% CI: [{lower}, {upper}]
[STAT:effect_size] {measure} = {value} ({small/medium/large})
[STAT:p_value] p = {value}
[STAT:n] n = {sample size}
```

### Step 4 — Synthesize

Summarize findings with limitations:

```
[LIMITATION] {caveat about the analysis}
```

Common limitations to always check:
- Sample size adequacy
- Missing data bias
- Confounding variables
- Correlation ≠ causation
- Selection bias

## Output Format

```markdown
## Analysis: {objective}

### Data Summary
- Source: {file/query}
- Size: {rows} x {cols}
- Quality: {missing data %, outliers}

### Findings

#### Finding 1: {title}
- Result: {what was found}
- Confidence: {CI or effect size}
- Evidence: {statistical test + result}
- Sample: n = {size}

#### Finding 2: {title}
...

### Limitations
- {caveat 1}
- {caveat 2}

### Conclusions
{What the data tells us, stated conservatively}

### Recommendations
{What to do with these findings}
```

## Rules

- Every finding needs statistical backing — no "seems like" or "appears to"
- Never output raw DataFrames — always summarize or aggregate
- State limitations for EVERY analysis — there are always caveats
- Hypothesis-driven: state what you expect BEFORE testing
- Use visualizations when they clarify (save to file, don't try to display)
- Don't install packages without asking — use standard library when possible
- Correlation ≠ causation — always call this out when relevant

## Not Responsible For

- Requirements gathering (see analyst, deep-interview)
- Codebase investigation (see deep-dive, trace)
- Tool/library comparison (see autoresearch)
- Implementation (see plan, ultrawork)
