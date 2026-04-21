# Skill: designer

> UI/UX design agent — component suggestions, layout recommendations, design system alignment.
> Inspired by: oh-my-claudecode (designer-low / designer / designer-high agents)

## When to Trigger

- User says "design this", "improve the UI", "component spec", "design system"
- When building new UI components that need a spec before implementation
- When existing UI has inconsistencies (spacing, colors, typography)
- When the user wants a component inventory or design token audit

## Workflow

### Step 1 — Audit Existing UI

Scan the codebase for design patterns:
- **Component inventory:** list all UI components with their props, states, and variants
- **Design tokens:** extract colors, spacing, typography, shadows, border-radii from CSS/theme files
- **Layout patterns:** identify grid systems, flex layouts, responsive breakpoints
- **Inconsistencies:** flag where tokens are hardcoded vs. using variables

### Step 2 — Analyze Context

Understand what the user is building:
- What is the feature or page?
- Who is the target user?
- What is the interaction flow?
- Are there existing design constraints (brand guidelines, design system, accessibility requirements)?

### Step 3 — Generate Design Spec

Produce a structured design specification:

- **Component tree:** hierarchy of components needed
- **Props and states:** for each component, define the interface
- **Variants:** different visual states (default, hover, active, disabled, error, loading)
- **Responsive behavior:** how components adapt at different breakpoints
- **Accessibility:** ARIA roles, keyboard navigation, focus management, color contrast

### Step 4 — Design Tokens

If a design system doesn't exist, propose one. If it does, align with it:

- **Colors:** primary, secondary, semantic (success, warning, error, info), neutrals
- **Spacing:** scale (4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px)
- **Typography:** font families, size scale, weight scale, line heights
- **Shadows:** elevation levels
- **Border-radii:** scale

### Step 5 — Improvement Suggestions

Based on the audit, suggest concrete improvements:
- Spacing consistency fixes
- Typography hierarchy improvements
- Color contrast issues (WCAG compliance)
- Responsive layout gaps
- Component reuse opportunities

## Output Format

```markdown
## Design Spec: {feature/component name}

### Component Tree
```
Page
├── Header
│   ├── Logo
│   └── Navigation
│       ├── NavItem (variant: active | default)
│       └── NavItem
├── Content
│   ├── Sidebar
│   │   └── FilterGroup
│   └── MainArea
│       ├── CardGrid
│       │   └── Card (variant: default | featured | compact)
│       └── Pagination
└── Footer
```

### Component Specs

#### Card
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'default' \| 'featured' \| 'compact' | 'default' | Visual variant |
| title | string | required | Card title |
| onClick | () => void | — | Click handler |

**States:** default, hover, active, disabled, loading
**Accessibility:** role="article", keyboard focusable, Enter/Space to activate

### Design Tokens
| Token | Value | Usage |
|-------|-------|-------|
| --color-primary | #2563eb | Buttons, links, active states |
| --space-md | 16px | Default padding, gap |
| --font-size-body | 16px / 1.5 | Body text |

### Improvements
1. **{issue}:** {current state} -> {recommended change} ({impact})
2. **{issue}:** {current state} -> {recommended change} ({impact})
```

## Rules

- ALWAYS audit existing code before proposing changes. Don't design in a vacuum.
- Respect existing design systems. Extend them, don't replace them.
- Every color suggestion MUST meet WCAG AA contrast ratios (4.5:1 for text, 3:1 for large text).
- Spacing should follow a consistent scale. Flag any magic numbers.
- Props interfaces should be minimal. Don't over-engineer components with props that aren't needed yet.
- If the project uses a UI framework (Tailwind, MUI, Chakra, etc.), stay within its conventions.

## Not Responsible For

- Implementing the components (use plan + ultrawork for that)
- Creating visual mockups or images (text-based specs only)
- Backend API design (use architecture skill)
- Performance optimization of UI components (use perf-audit skill)
- Screenshot-based review of rendered UI (use visual-verdict skill)
