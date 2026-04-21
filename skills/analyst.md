# Skill: analyst

> Requirements analysis and gap detection. Extract, structure, and compare requirements against implementation.
> Inspired by: oh-my-claudecode (analyst agent)

## When to Trigger

- User says "analyze requirements", "what's missing", "gap analysis", "extract requirements"
- When a PRD, issue, or conversation contains implicit requirements that need structuring
- When you need to verify that an implementation covers all stated requirements
- Before starting a large feature — to ensure nothing is missed

## Workflow

### Step 1 — Gather Sources

Collect requirements from all available sources:
- **User conversations:** extract stated and implied needs from chat history
- **PRDs / specs:** parse structured documents for explicit requirements
- **Issue descriptions:** extract acceptance criteria, user stories, edge cases
- **Existing code:** infer requirements from what's already implemented (tests are especially good)
- **Config / schema files:** extract constraints and assumptions

### Step 2 — Structure Requirements

Organize into a structured requirements document:

- **Functional requirements:** what the system must do (features, behaviors, interactions)
- **Non-functional requirements:** how the system must perform (performance, security, accessibility, scalability)
- **Constraints:** technical limitations, dependencies, compatibility requirements
- **Assumptions:** things taken for granted that could be wrong

Assign each requirement a unique ID (e.g., `FR-001`, `NFR-001`, `CON-001`, `ASM-001`).

### Step 3 — Analyze Current Implementation

For each requirement, check the codebase:
- Search for relevant code, tests, and documentation
- Determine implementation status
- Note any deviations from the requirement
- Identify partial implementations that need completion

### Step 4 — Gap Analysis

Compare requirements against implementation:
- **Implemented:** fully covered by existing code and tests
- **Partial:** some aspects implemented, others missing
- **Missing:** no implementation found
- **Unknown:** can't determine status (ambiguous requirement or complex code)

### Step 5 — Risk Assessment

For each gap, assess risk:
- **Impact:** what happens if this gap isn't addressed (HIGH / MEDIUM / LOW)
- **Effort:** estimated work to close the gap (SMALL / MEDIUM / LARGE)
- **Priority:** recommended order to address gaps

## Output Format

```markdown
## Requirements Analysis: {feature/project name}

### Sources
- {source 1: type and description}
- {source 2: type and description}

### Requirements Matrix

| ID | Category | Requirement | Status | Risk | Notes |
|----|----------|-------------|--------|------|-------|
| FR-001 | Functional | {description} | Implemented | — | {file:line} |
| FR-002 | Functional | {description} | Partial | HIGH | {what's missing} |
| FR-003 | Functional | {description} | Missing | MEDIUM | {recommendation} |
| NFR-001 | Non-functional | {description} | Unknown | LOW | {why unknown} |
| CON-001 | Constraint | {description} | Implemented | — | {how it's enforced} |
| ASM-001 | Assumption | {description} | — | HIGH | {risk if wrong} |

### Summary
- **Total requirements:** {count}
- **Implemented:** {count} ({percentage}%)
- **Partial:** {count} ({percentage}%)
- **Missing:** {count} ({percentage}%)
- **Unknown:** {count} ({percentage}%)

### Critical Gaps
1. **{FR-002}:** {description of gap and recommended action}
2. **{FR-003}:** {description of gap and recommended action}

### Assumptions to Validate
1. **{ASM-001}:** {assumption and how to validate it}
```

## Rules

- Every requirement MUST have a unique ID. This enables tracking across sessions.
- Status must be backed by evidence — cite the file:line or test that proves implementation.
- "Unknown" is a valid status. Don't guess — flag it for human review.
- Assumptions are requirements too. List them explicitly so they can be validated.
- Don't conflate "not tested" with "not implemented". Check the code, not just the tests.
- If a requirement is ambiguous, flag it as ambiguous rather than interpreting it.

## Not Responsible For

- Implementing the missing requirements (use plan + ultrawork for that)
- Writing tests for gaps (use tdd skill)
- Designing solutions for missing features (use architecture or designer skill)
- Project management or prioritization (present the data, let the user prioritize)
