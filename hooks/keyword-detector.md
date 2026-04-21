# Hook: keyword-detector

> Scan user input for skill trigger words and auto-activate matching skills.

## Trigger

Fires on every user message — scans the input text for known trigger patterns.

## Behavior

1. **Scan input** — match user message against skill trigger keywords from all loaded skill definitions
2. **Rank matches** — if multiple skills match, rank by specificity (exact phrase > keyword > fuzzy)
3. **Auto-activate** — trigger the best-matching skill without requiring explicit invocation
4. **Confirm ambiguous** — if multiple skills match equally, ask user which they meant
5. **Learn patterns** — track which keywords lead to which skills; refine matching over time

## Input

- User message text (raw)
- All loaded skill definitions with their `When to Trigger` sections
- Recent conversation context (last 3 messages)
- Keyword match history

## Output / Side Effects

- Matching skill activated (fires `skill-start` hook)
- Ambiguous matches prompt user for clarification
- No match = no action (message handled normally)
- Match history updated for future refinement

## Example

```
User: "let's review the commit before pushing"

🔍 keyword-detector:
   Matched: "review" + "commit" → skills/pre-commit-check.md (confidence: high)
   Auto-activating pre-commit-check...
```

```
User: "clean up the code"

🔍 keyword-detector:
   Matched: "clean up" → skills/code-simplifier.md (0.8)
   Matched: "clean" → skills/cleanup.md (0.6)
   → Which did you mean: code simplifier or file cleanup?
```
