# claw-code Research

> Source: https://github.com/ultraworkers/claw-code

## What It Is
Rust CLI agent harness - standalone alternative to Claude Code. Has its own
REPL, tool system, session management, and plugin architecture.

## Relevance to oh-my-universal
LOW - this is a standalone CLI binary, not a config/skills layer.
We can reference its patterns but won't port its code.

## Notable Patterns (REFERENCE ONLY)

| Pattern | What it does | Useful as reference? |
|---------|-------------|---------------------|
| Config hierarchy | user + repo + local settings | YES - good pattern |
| Permission modes | fine-grained tool permissions | YES |
| Session persistence | workspace-scoped sessions | YES |
| Model aliases | short names for models | NICE TO HAVE |
| Doctor command | health check | YES (we have this) |
| Sandbox mode | isolated execution | REFERENCE |

## Dependencies
- Rust toolchain, Anthropic API key
