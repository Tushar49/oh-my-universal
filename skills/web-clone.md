# Skill: web-clone

> URL-driven website cloning with visual + functional verification.
> Inspired by: oh-my-codex (web-clone)

## When to Trigger

- User says "clone site", "clone website", "copy this webpage", "web-clone", "replicate this page"
- User provides a target URL and wants it replicated as working code
- Task requires both visual fidelity AND functional parity with the original
- Reference is a live URL (not a static screenshot)

## Do NOT Trigger When

- User only has screenshot references without a live URL (use `visual-verdict` directly)
- User wants to modify, redesign, or "improve" the site (use standard implementation)
- Target requires authentication, payment flows, or backend API parity
- Multi-page deep cloning (v1 handles single-page scope only)

## Scope Limits

**Included:**
- Layout structure (header, nav, content areas, sidebar, footer)
- Typography (font families, sizes, weights, line heights)
- Colors, spacing, borders, border-radius
- Core interactions: navigation links, buttons, form elements, dropdowns, modals, toggles
- Responsive layout patterns (flexbox/grid)

**Excluded:**
- Backend API integration or data fetching
- Authentication flows or protected content
- Dynamic/personalized content
- Multi-page crawling or route graph cloning
- Third-party widget functionality (maps, embeds, chat widgets)
- Image/asset replication (use placeholders)

**Legal notice:** Only clone sites you own or have explicit permission to replicate.

## Workflow

### Pass 1 - Extract

Capture the target page's structure, styles, interactions, and visual baseline:

1. **Navigate** to target URL using browser automation
2. **Wait for render** (network idle or 5s timeout) for lazy-loaded content
3. **Accessibility snapshot** - captures semantic tree (roles, names, values, interactive states)
4. **Full-page screenshot** - save as reference baseline `target-full.png`
5. **DOM + computed styles** - extract tag hierarchy with computed CSS properties:
   - display, position, width, height, padding, margin
   - fontSize, fontFamily, fontWeight, lineHeight
   - color, backgroundColor, border, borderRadius
   - flexDirection, justifyContent, alignItems, gap, gridTemplateColumns
6. **Interactive elements catalog** - all buttons, links, inputs, selects, modals, accordions
7. **Network patterns** (optional) - note XHR/fetch calls for reference only

### Pass 2 - Build Plan

Analyze extraction and decompose into components:

1. **Identify page regions** from DOM + accessibility snapshot:
   - Navigation/header, hero/banner, main content, sidebar, footer, overlays
2. **Map components** per region:
   - Component name, key styles, content summary, children
3. **Create interaction map:**
   - Nav links -> anchors with href
   - Forms -> proper `<form>` with inputs, labels, validation
   - Buttons -> click handlers (toggle, submit, navigate)
   - Dropdowns/modals -> show/hide with transitions
4. **Extract design tokens:**
   - Color palette, font stack, spacing scale, border-radius values
5. **Define file structure** adapted to project tech stack

### Pass 3 - Implement

Generate the clone code:

1. Create project structure (files, folders)
2. Build component by component, top-down
3. Apply exact design tokens from extraction
4. Wire up interactions from the interaction map
5. Use semantic HTML with proper ARIA attributes
6. Add responsive layout from observed flexbox/grid patterns
7. Use placeholder images where external assets were found

### Pass 4 - Verify

Compare clone against original:

1. **Serve locally** - start a dev server for the clone
2. **Screenshot comparison** - take full-page screenshot of clone
3. **Visual diff** - compare clone screenshot with `target-full.png`
4. **Score visual fidelity** on these dimensions:
   - Layout accuracy (regions match original positioning)
   - Typography accuracy (fonts, sizes, weights match)
   - Color accuracy (palette matches within tolerance)
   - Spacing accuracy (padding/margin/gaps match)
   - Interactive element completeness (all buttons/forms present)
5. **If score < 85%**, iterate: identify worst mismatches, fix, re-screenshot, re-score
6. **If score >= 85%**, declare success

### Pass 5 - Report

```markdown
## Web Clone: {target_url}

### Extraction Summary
- Landmarks: {count}
- Interactive elements: {count}
- Design tokens extracted: {count}

### Visual Fidelity Score: {score}%
| Dimension | Score | Notes |
|-----------|-------|-------|
| Layout | {n}% | {notes} |
| Typography | {n}% | {notes} |
| Colors | {n}% | {notes} |
| Spacing | {n}% | {notes} |
| Interactions | {n}% | {notes} |

### Files Generated
{file tree}

### Known Gaps
- {gap}: {reason}
```

## Context Budget

Extraction can produce large data. Apply limits:

- **DOM tree:** If > 30KB, reduce depth from 8 to 4
- **Accessibility snapshot:** If > 20KB, summarize key landmarks
- **Interactive elements:** Cap at 50 elements (visible ones only)
- **Total extraction context:** Aim for < 60KB combined
- **Screenshots:** One baseline (Pass 1), one comparison (Pass 4). No screenshots between iterations.

## Output Format

```markdown
## Web Clone: {URL}

### Extracted Assets
- Pages: {N}
- Components: {N}
- Styles: {N lines of CSS}
- Images: {N}

### Generated Files
| File | Purpose |
|------|---------|
| index.html | Main page structure |
| styles.css | Extracted/recreated styles |
| components/ | Reusable components |

### Fidelity Check
- Layout match: {%}
- Color accuracy: {%}
- Responsive: {yes/no}
```

## Rules

- ALWAYS extract before building. Don't guess at layout or styles.
- Use accessibility snapshot as primary structural reference (more token-efficient than screenshots)
- Match the project's tech stack: if the project uses React, generate React components; if plain HTML, generate HTML/CSS/JS
- Design tokens should use CSS custom properties for maintainability
- Every interactive element in the original should have a working counterpart
- Placeholder images should have correct aspect ratios matching originals
- If running within a persistent completion loop, save progress state for resume

## Not Responsible For

- Backend API replication (out of scope)
- Image/asset downloading or mirroring (use placeholders)
- Multi-page site crawling (single page only)
- Improving the design (clone faithfully, don't redesign)
- SEO optimization of the clone
