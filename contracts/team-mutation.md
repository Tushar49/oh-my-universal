# Contract: team-mutation

> Safe shared-state mutation when sub-agents modify shared resources. Claim-and-version protocol prevents data loss.

## Invariants

### 1. Claim-and-Version Protocol

When a sub-agent needs to modify shared state (files, state files, tracker data), it MUST:

1. **Claim** — declare intent to modify the resource before starting
2. **Version** — record the resource's state at claim time (hash, timestamp, or content snapshot)
3. **Modify** — make changes to the claimed resource
4. **Release** — declare modification complete and release the claim

```markdown
## Mutation Claim

| Resource | Claimed by | Version at claim | Status |
|---|---|---|---|
| src/auth.ts | subagent-1 | abc123 (hash) | claimed |
| src/types.ts | subagent-2 | def456 (hash) | claimed |
| package.json | subagent-1 | ghi789 (hash) | released |
```

### 2. No Parallel Writes

Two sub-agents MUST NOT modify the same file simultaneously. This is enforced by the claim system:

- If subagent-2 tries to claim a file already claimed by subagent-1, the claim is DENIED
- Subagent-2 must wait for subagent-1 to release, or request the parent agent to mediate
- The parent agent can force-release a claim if the holding agent is stuck or cancelled

**Scope of "same file":**
- Same file path = conflict (even if editing different lines)
- Files that import each other = potential conflict (flag for review, don't block)
- Files in the same directory but unrelated = no conflict

### 3. Parent Agent is Rule-of-Record

The parent (delegating) agent is the authority for conflict resolution:

- Parent assigns claims during task decomposition (proactive)
- Parent resolves conflicts when two sub-agents need the same resource (reactive)
- Parent validates all sub-agent results before merging into the main branch
- Sub-agents CANNOT overrule the parent's conflict resolution

**Resolution strategies the parent can use:**
| Strategy | When to use |
|---|---|
| **Serialize** | Sub-agent A finishes first, then B works on the file |
| **Partition** | Split the file into sections, each agent owns a section |
| **Merge** | Both agents work on copies, parent merges results |
| **Abort one** | Cancel one sub-agent's changes in favor of the other |

### 4. Validation Before Merge

Sub-agent results MUST be validated before merging into shared state:

1. **Completeness** — did the sub-agent finish its assigned task?
2. **Consistency** — do the changes conflict with other sub-agents' work?
3. **Correctness** — do tests pass with the changes applied?
4. **Versioning** — was the resource modified by someone else since the claim? (stale write check)

**Stale write detection:**
```
version_at_claim = abc123
version_at_merge = abc123  → OK, no conflict
version_at_merge = xyz999  → STALE WRITE — someone else modified the file
```

If a stale write is detected, the parent agent must resolve it (re-apply changes on new version, or ask the user).

## Violations

- Sub-agent modifying a file it did not claim
- Two sub-agents holding claims on the same file simultaneously
- Sub-agent merging its own results without parent validation
- Parent merging results without checking for stale writes
- Force-releasing a claim without notifying the holding agent
- Modifying shared state files (`.state/`, `.memory/`) without going through the claim protocol

## Enforcement

| Component | What it checks |
|---|---|
| `skills/team.md` | Assigns claims during task decomposition (Step 2) |
| `hooks/subagent-start.md` | Records claims when sub-agent begins work |
| `hooks/subagent-end.md` | Validates results and releases claims |
| `skills/worktree-sandbox.md` | Physical isolation via git worktrees (eliminates conflicts by design) |
| `contracts/state-precedence.md` | State layering rules for shared state |

## Examples

**Valid flow:**
```
Parent: decompose task into A (auth.ts) and B (api.ts)
Parent: claim auth.ts for subagent-1, claim api.ts for subagent-2
Subagent-1: modify auth.ts, commit, release claim
Subagent-2: modify api.ts, commit, release claim
Parent: validate both, merge both — no conflicts
```

**Conflict detected:**
```
Parent: claim utils.ts for subagent-1
Subagent-2: tries to claim utils.ts — DENIED
Parent: serialize — subagent-1 finishes first, then subagent-2 gets the claim
```

**Stale write:**
```
Subagent-1: claims config.json (version: v3)
User: manually edits config.json (now version: v4)
Subagent-1: tries to merge — STALE WRITE detected
Parent: re-applies subagent-1's changes on top of v4, or asks user
```

**Worktree shortcut:**
When using `worktree-sandbox`, file conflicts are avoided by design — each agent works in a separate directory with its own branch. The parent merges branches at the end. This is the preferred approach for large parallel tasks.
