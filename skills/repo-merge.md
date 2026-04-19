# Skill: repo-merge

> Merge features from an external repository into the current project.
> Structured process: research -> evaluate -> plan -> port -> verify.
> Born from real experience merging santifer/career-ops into JobApplications.

## When to Use

- User says "integrate {repo}", "merge features from {repo}", "port {feature} from {repo}"
- When adopting an open-source project's patterns into your own codebase
- When consolidating multiple repos into one

## Workflow

### Step 1 — Research Source Repo

Before touching any code, understand the source:

1. **Read the entry files**: README.md, AGENTS.md, CLAUDE.md
2. **Map the architecture**: what directories, what conventions, what tech stack
3. **Identify features**: list every feature/capability the source has
4. **Check the data contract**: what's user data vs system logic?
5. **Save research** to `.research/{source-repo}/findings.md`

### Step 2 — Create Feature Matrix

Map source features to your project:

```markdown
| # | Source feature | Our equivalent | Action | Priority |
|---|--------------|---------------|--------|----------|
| 1 | {feature} | {existing or none} | PORT / SKIP / ADAPT | HIGH |
| 2 | {feature} | {existing, better} | SKIP (ours is better) | - |
| 3 | {feature} | {none} | PORT | MEDIUM |
```

**Action definitions:**
- **PORT**: bring it over (new feature for us)
- **ADAPT**: we have something similar, upgrade it with source's approach
- **SKIP**: not needed, redundant, or incompatible
- **REFERENCE**: good pattern but don't port code, just learn from it

### Step 3 — Plan the Integration

Follow skills/plan.md workflow:
- Identify blast radius (what files change)
- Define batch order (infrastructure first, features second, docs last)
- Identify risks (breaking changes, path conflicts, naming clashes)
- Get user approval on the plan

**Key decisions to resolve:**
- Keep our conventions or adopt theirs?
- Keep our file structure or reorganize?
- Keep both implementations or pick one?
- What about conflicting data formats?

### Step 4 — Port in Batches

For each batch:
1. Implement the changes
2. Run verification (follow skills/verify.md workflow)
3. Update docs
4. Commit with clear message referencing the source
5. Move to next batch

**Batch order (recommended):**
1. Infrastructure (package.json, config, scripts)
2. Core features (the main capabilities being ported)
3. Prompts/instructions (agent behavior changes)
4. Documentation (README, guides, routing tables)
5. Cleanup (remove redundant code, fix inconsistencies)

### Step 5 — Verify Parity

After all batches:
1. Create a parity checklist: every PORT/ADAPT item from the feature matrix
2. Verify each one works in the target project
3. Run full test/verify suite
4. Audit for stale references (old paths, broken links)

### Step 6 — Document Provenance

Add to the project's docs:
- What was ported and from where
- What was skipped and why
- What was adapted and how it differs from the source
- Date of integration for future reference

## Output Format

```markdown
## Repo Merge: {source} -> {target}

**Source:** {repo URL}
**Features ported:** {N} of {total}
**Features skipped:** {N}
**Features adapted:** {N}

### Parity Checklist
| Feature | Status | Notes |
|---------|--------|-------|
| {feature} | ✓ ported | {notes} |
| {feature} | ✗ skipped | {reason} |

### Breaking Changes
- {any changes that affect existing behavior}

### New Capabilities
- {what users can now do that they couldn't before}
```

## Rules

- NEVER blindly copy files. Understand what you're porting and WHY.
- Adopt CONCEPTS, not implementations. Translate to your project's conventions.
- Keep your project's existing architecture unless there's a clear reason to change.
- Port in small batches. Verify after each batch. Don't do everything at once.
- Always document provenance (where features came from).
- Not responsible for: code review of ported code (see review), security audit (see security-review)
