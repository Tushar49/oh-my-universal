# Skill: ai-slop-cleaner

> Strip AI-generated cliches, fluff, and filler from output text. Make it sound human.
> Inspired by: oh-my-claudecode (ai-slop-cleaner skill)

## When to Trigger

- User says "clean this up", "remove slop", "de-fluff", "strip the AI talk"
- Auto-run on doc-maintainer output before committing documentation
- When reviewing commit messages, PR descriptions, or comments that read like ChatGPT wrote them
- When cover letters or professional writing sounds generic and templated

## Workflow

### Step 1 — Scan for Slop Patterns

Scan the input text for AI-typical patterns across these categories:

**Filler openers:** "I'd be happy to", "Let me", "Great question!", "Certainly!", "Sure thing!", "Absolutely!", "Of course!"

**Corporate jargon:** "leverage", "cutting-edge", "robust", "seamless", "innovative", "synergy", "best practices", "paradigm", "holistic", "ecosystem"

**Hedging fluff:** "It's worth noting that", "It's important to understand", "As you may know", "In today's fast-paced world", "At the end of the day"

**Redundant summaries:** "In summary", "To summarize", "In conclusion", "As we've discussed" (when the content is short enough to not need a summary)

**Empty affirmations:** "That's a great approach", "This is a solid foundation", "You're on the right track" (without specific reasoning)

**Cliche phrases:** "proven track record", "results-oriented", "passionate about", "spearheaded", "facilitated", "demonstrated ability to"

### Step 2 — Choose Mode

**CLEAN mode** (default):
- Auto-strip all detected slop
- Preserve technical content, specific details, code, and data
- Tighten sentences — remove unnecessary words
- Replace jargon with plain language where possible

**AUDIT mode:**
- Flag each instance with its location and category
- Suggest replacements but don't apply them
- Produce a report of slop density (instances per 100 words)

### Step 3 — Process

For each detected pattern:
1. Identify the slop phrase and its context
2. Determine if it carries any actual meaning (some uses of "robust" are legitimate)
3. If no meaning: remove entirely and adjust surrounding text for flow
4. If some meaning: replace with a direct, specific alternative

### Step 4 — Verify

- Re-read the cleaned text to ensure it still makes sense
- Check that no technical content was accidentally removed
- Verify the tone is still appropriate for the context (formal doc vs casual comment)

## Output Format

### CLEAN Mode

Return the cleaned text directly, followed by a brief diff summary:

```markdown
{cleaned text}

---
**Slop removed:** {count} instances
**Categories:** {list of categories found}
**Changes:** {brief list of notable changes}
```

### AUDIT Mode

```markdown
## Slop Audit: {document name}

### Stats
- **Slop density:** {n} instances per 100 words
- **Total instances:** {count}
- **Rating:** CLEAN / MILD / HEAVY / EGREGIOUS

### Findings
| # | Line | Pattern | Category | Suggestion |
|---|------|---------|----------|------------|
| 1 | 3 | "I'd be happy to help" | filler opener | Remove entirely |
| 2 | 7 | "leverage" | corporate jargon | "use" |
| 3 | 12 | "robust and seamless" | corporate jargon | "reliable" |
| 4 | 15 | "In summary..." | redundant summary | Remove — text is 4 lines long |
```

## Rules

- NEVER remove technical terms, specific metrics, code, or data. Only strip filler.
- Context matters — "leverage" in a finance doc about financial leverage is fine. "Leverage our synergies" is slop.
- Don't over-correct. One or two natural hedges ("might", "could") are fine. Strip only when excessive.
- In CLEAN mode, the output should read like a confident human wrote it, not like it was run through a thesaurus.
- Preserve the author's intended meaning. Strip the fluff, keep the signal.
- For commit messages and code comments: be aggressive. These should be terse and direct.
- For cover letters and professional docs: be moderate. Some formality is expected.

## Not Responsible For

- Rewriting content from scratch (use writer-memory or doc-maintainer)
- Checking factual accuracy of the content
- Grammar and spelling correction (use a linter for that)
- Tone adjustment beyond slop removal (that's an editorial decision)
