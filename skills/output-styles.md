# Skill: output-styles

> Configurable output modes for different communication needs. Match the format to the moment.
> Inspired by: claude-workflow-v2 output-styles

## When to Trigger

- User says "use architect mode", "be rapid", "teach me", "mentor mode", "be concise"
- User requests a specific communication style
- Agent detects context that benefits from a particular style (e.g., code review -> review mode)
- At session start, default to the style best suited for the task

## Styles

### architect

Detailed specifications for design and planning discussions.

- Use formal, precise language
- Include diagrams (ASCII or mermaid) where helpful
- Present tradeoff tables for every significant decision
- Reference patterns by name (Repository, Strategy, Observer, etc.)
- Include interface definitions and type signatures
- Specify error handling and edge cases explicitly

**When:** Architecture decisions, system design, API design, technical proposals.

### rapid

Minimal output — just code, commands, and essential context.

- No explanations unless the code is non-obvious
- No preamble or summary
- Show only the diff or the new code
- Commands without commentary
- If asked a question, answer in one line

**When:** User is experienced, flow state, quick fixes, repetitive tasks.

### mentor

Educational output that teaches concepts and builds understanding.

- Explain WHY, not just what
- Connect new concepts to ones the user likely knows
- Show alternatives and explain when each is appropriate
- Include "you might be wondering" anticipatory explanations
- Use analogies for complex concepts
- Suggest further reading or exploration

**When:** User is learning, asks "why", exploring unfamiliar territory, onboarding.

### review

Structured code review feedback with severity and precision.

- Categorize findings: BUG / SECURITY / PERFORMANCE / STYLE / SUGGESTION
- Include severity: CRITICAL / HIGH / MEDIUM / LOW
- Reference specific lines (`file.ts:42-50`)
- Explain the issue and suggest a fix
- Group by file, then by severity
- Skip praise — focus on actionable findings

**When:** Code review, PR review, audit, quality checks.

### concise

Bullet points only, no prose.

- Every output is a bulleted list
- No introductory sentences
- No concluding paragraphs
- Headers for structure, bullets for content
- Code blocks inline when needed, but no surrounding explanation

**When:** Status updates, summaries, checklists, quick decisions.

## Workflow

### Step 1 — Detect or Accept Style

Check for explicit user request first:
- "use {style} mode" -> activate that style
- "be {style}" -> activate that style

If no explicit request, auto-select based on context:
- Planning task -> architect
- Quick fix -> rapid
- Learning/exploring -> mentor
- Reviewing code -> review
- Status check -> concise

### Step 2 — Apply Style

Format ALL output according to the active style until:
- User requests a different style
- Task context changes significantly (auto-switch with notice)
- Session ends

### Step 3 — Style Switch Notification

When switching styles (auto or manual), briefly note:
```
[Style: rapid -> architect] (design discussion detected)
```

## Output Format

Style indicator at the top of first response after activation:
```
[Style: {name}] {one-line description of why}
```

## Rules

- User's explicit style request ALWAYS overrides auto-detection
- Don't announce style on every message — only on activation or switch
- rapid mode means RAPID. If your response is more than 10 lines, you're not being rapid.
- mentor mode is for teaching, not for being verbose. Stay focused on the concept at hand.
- review mode findings must be actionable. "This could be improved" is not actionable. "Use Map instead of Object here for O(1) delete" is.
- Styles affect FORMAT, not substance. The technical accuracy is the same in every style.
- If a style feels wrong for the current task, suggest a switch but don't force it
- Multiple styles can't be active at once. Pick the dominant one.

## Not Responsible For

- Changing the agent's personality or values (styles are format, not character)
- Enforcing project-specific terminology (use config-sync for that)
- Output length limits (that's a CLI/runtime concern)
- Language or locale settings
