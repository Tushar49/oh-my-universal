# Skill: ask

> Query multiple AI models and cross-validate answers. Get a second opinion.
> Inspired by: oh-my-claudecode (ask, ccg)

## When to Trigger

- User says "ask codex", "ask gemini", "get a second opinion", "cross-validate"
- When a decision benefits from multiple perspectives
- When a specific model's strength is relevant (Gemini for large context, Codex for code review)

## Workflow

### Step 1 — Prepare the Prompt

1. Take the user's question or task
2. Add relevant context: file contents, error messages, architectural constraints
3. Format as a self-contained prompt that any model can answer without access to the conversation history

### Step 2 — Route to Providers

Dispatch the prompt to available AI CLIs via shell:

**Claude CLI:**
```bash
echo "{prompt}" | claude --print 2>/dev/null
```

**Codex CLI:**
```bash
echo "{prompt}" | codex --quiet 2>/dev/null
```

**Gemini CLI:**
```bash
echo "{prompt}" | gemini 2>/dev/null
```

**Copilot CLI (sub-agent):**
Use the `task` tool to spawn a sub-agent with a different model if available.

Before running, check if each CLI exists:
```bash
command -v claude && echo "available" || echo "missing"
```

If a provider is unavailable, skip it and note it in the output. Don't fail the whole skill.

### Step 3 — Save Artifacts

Save each response as a markdown artifact:
- Path: `.artifacts/ask/{provider}-{slug}-{timestamp}.md`
- Include: provider name, prompt, full response, timestamp

### Step 4 — Synthesize Comparison

If multiple providers responded, create a synthesis:

1. **Agreement points** — Where do the models agree?
2. **Disagreement points** — Where do they differ? What's the reasoning on each side?
3. **Unique insights** — What did one model catch that others missed?
4. **Recommendation** — Based on the comparison, what's the best answer?

## Output Format

```markdown
## Ask: {question summary}

### Providers Queried
| Provider | Status    | Response Length |
|----------|-----------|----------------|
| Claude   | responded | ~500 words      |
| Codex    | responded | ~300 words      |
| Gemini   | missing   | —               |

### Agreement
- {point where models agree}

### Disagreement
| Point | Claude says | Codex says |
|-------|------------|------------|
| {topic} | {position} | {position} |

### Unique Insights
- **Claude:** {insight only Claude mentioned}
- **Codex:** {insight only Codex mentioned}

### Recommendation
{synthesized answer based on comparison}

### Artifacts
- `.artifacts/ask/claude-{slug}-{ts}.md`
- `.artifacts/ask/codex-{slug}-{ts}.md`
```

## Rules

- Always check CLI availability before calling. Gracefully degrade if a provider is missing.
- Save raw responses as artifacts before synthesizing. Don't lose the original answers.
- The synthesis should be objective — present disagreements fairly, don't bias toward one model.
- If only one provider is available, still save the artifact and present the response. Skip comparison.
- Prompts sent to external models must be self-contained (include all necessary context).
- Don't send sensitive data (secrets, credentials) to external models.
- For Copilot CLI users: use the `task` tool to spawn sub-agents with different model parameters instead of shelling out to external CLIs.

## Not Responsible For

- Making the final decision (the user or calling skill decides)
- Executing code suggested by external models (use plan/ultrawork for that)
- Managing API keys or CLI installation (user's responsibility)
- Real-time chat with external models (single prompt/response only)
