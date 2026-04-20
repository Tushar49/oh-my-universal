# Skill: visual-verdict

> Screenshot-based UI review. Takes screenshots and produces structured visual feedback.
> Inspired by: oh-my-claudecode (vision agent), visual review patterns

## When to Trigger

- User says "review the UI", "visual check", "does this look right"
- After CSS or frontend changes that affect layout or styling
- When design fidelity verification is needed
- User provides a design spec or reference screenshot to compare against

## Workflow

### Step 1 — Capture Screenshots

Take a screenshot of the current UI state using the platform's screenshot tools:
- Browser CDP: `cdp-browser-page -> screenshot`
- Playwright MCP: `browser_take_screenshot`
- If no browser available: ask user to provide a screenshot path

If comparing against a previous version, capture both before and after states.
If a design spec image is provided, load it for reference.

### Step 2 — Analyze Visual Dimensions

Review the screenshot across these dimensions:

**1. Layout Alignment**
- Are elements aligned to the grid?
- Is content centered/justified as expected?
- Are margins and padding consistent between sections?

**2. Spacing Consistency**
- Are gaps between elements uniform?
- Is vertical rhythm maintained (consistent line heights, section gaps)?
- Do repeated elements (cards, list items) have equal spacing?

**3. Color Accuracy**
- Do colors match the design spec or brand palette?
- Are hover/active/focus states using correct colors?
- Is there sufficient contrast between text and background?

**4. Responsive Behavior**
- Does the layout work at common breakpoints (mobile 375px, tablet 768px, desktop 1440px)?
- Do images scale properly?
- Is text readable at all viewport sizes?

**5. Accessibility Contrast**
- Text contrast ratio meets WCAG AA (4.5:1 for normal text, 3:1 for large text)
- Interactive elements have visible focus indicators
- Touch targets are at least 44x44px

### Step 3 — Produce Verdict

Compile findings into the structured output format below. Each dimension gets a PASS or NEEDS_FIX rating. Include specific element references for any issues found.

## Output Format

```markdown
## Visual Verdict: {page/component}

**Scope:** {what was reviewed — page URL, component name, viewport size}

### Screenshots
- Current: {screenshot path}
- Reference: {design spec or previous version path, if applicable}

### Dimension Scores

| Dimension | Verdict | Notes |
|-----------|---------|-------|
| Layout Alignment | PASS / NEEDS_FIX | {brief finding} |
| Spacing Consistency | PASS / NEEDS_FIX | {brief finding} |
| Color Accuracy | PASS / NEEDS_FIX | {brief finding} |
| Responsive Behavior | PASS / NEEDS_FIX | {brief finding} |
| Accessibility Contrast | PASS / NEEDS_FIX | {brief finding} |

### Findings

#### {NEEDS_FIX}: {issue title}
**Element:** `{CSS selector or element description}`
**Expected:** {what it should look like}
**Actual:** {what it looks like}
**Suggestion:** {how to fix}

### Overall Verdict: APPROVED / NEEDS_FIX
{1-line summary}
```

## Rules

- If ALL dimensions pass, say "APPROVED" and move on. Don't invent problems.
- Every finding must reference a specific element (selector, coordinates, or description)
- Include a concrete fix suggestion for every NEEDS_FIX finding
- On CLIs without vision/image support, degrade gracefully: save screenshot to a path and ask the user to review it visually
- Maximum 8 findings per review. Prioritize by user impact.
- Take screenshots at 1x scale unless the user requests otherwise

## Not Responsible For

- Code quality of CSS/HTML (see review skill)
- Performance of rendering (see perf-audit skill)
- Writing CSS fixes (suggest what to fix, but implementation is a separate task)
- Design decisions — only check compliance with existing specs
