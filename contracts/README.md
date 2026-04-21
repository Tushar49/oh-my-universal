# Contracts — Formal Behavior Specifications

> Contracts are RULES that are always in effect. Every skill, hook, and agent must respect them.

## What Are Contracts?

Contracts define formal invariants — behavioral guarantees that the system must uphold at all times. They are not optional guidelines or best practices. They are hard rules.

| | Skills | Hooks | Contracts |
|---|---|---|---|
| **Purpose** | Instructions for tasks | Lifecycle event handlers | Rules that are always in effect |
| **Activation** | On-demand (user invokes) | Automatic (event fires) | Always active |
| **Scope** | Single workflow | Single lifecycle moment | All workflows, all moments |
| **Violation** | Incomplete output | Missed event | System integrity failure |
| **Analogy** | Functions | Middleware | Type system / invariants |

## Contracts in This Directory

| Contract | Enforces |
|---|---|
| [state-precedence](state-precedence.md) | State layering, rollback, and forbidden transitions |
| [terminal-handoff](terminal-handoff.md) | Every skill must end in a terminal state with proper handoff |
| [team-mutation](team-mutation.md) | Safe shared-state mutation when sub-agents are involved |
| [quality-gate](quality-gate.md) | Minimum quality bar for all implementations |

## How Contracts Are Enforced

Contracts are enforced through a combination of:

1. **Skills** — read contracts before executing (e.g., workflow-state checks state-precedence)
2. **Hooks** — validate contracts at lifecycle events (e.g., skill-end checks terminal-handoff)
3. **Agent behavior** — agents internalize contracts as hard rules during session-start
4. **Review** — pre-commit-check and verify-deliverables reference quality-gate

Contracts don't execute code. They define expectations that other components enforce. A contract violation means something in the system is broken — it's not a warning, it's a bug.

## Creating a New Contract

1. Create a `.md` file in `contracts/`
2. Follow this structure:
   - **Title and one-line description**
   - **Invariants** — the rules, stated precisely
   - **Violations** — what counts as breaking the contract
   - **Enforcement** — which skills/hooks check this contract
   - **Examples** — concrete scenarios showing valid and invalid behavior
3. Reference the contract from relevant skills and hooks
4. Add it to the table above
