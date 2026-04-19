# Additional Repos Research

> Discovered via GitHub search on 2026-04-19

## Top Repos to Reference

| Repo | Stars | Key takeaway for us |
|------|-------|---------------------|
| affaan-m/everything-claude-code | 160K | Skill taxonomy, memory injection, security hooks, multi-agent |
| OthmanAdi/planning-with-files | 19K | Persistent markdown planning (plan.md + phase tracking) |
| JuliusBrussee/caveman | 38K | Token-light compact skill design pattern |
| CloudAI-X/claude-workflow-v2 | 1.3K | verify-changes, plan, review hooks |
| sangrokjung/claude-forge | 659 | 11 agents, 36 commands, 15 skills, security hooks |
| softaworks/agent-toolkit | 1.6K | Curated reusable skill library pattern |
| levnikolaevich/claude-code-skills | 411 | Multi-model review, codebase audit, verification pipeline |
| mxyhi/ok-skills | 270 | Cross-agent portable skills (Codex/Claude/Cursor) |

## Key Patterns Already Adopted

1. **From planning-with-files**: persistent plan.md with phase tracking -> our `plan` skill
2. **From caveman**: ultra-compact skill files -> our skills are concise markdown
3. **From claude-forge**: hook-based safety gates -> our `pre-commit-check` workflow spec
4. **From everything-claude-code**: skill taxonomy with categories -> our skill organization
5. **From ok-skills**: portable skills across Codex/Claude/Cursor -> our cross-CLI approach

## Features Still Worth Porting (Future Phases)

| Source | Feature | Our target |
|--------|---------|-----------|
| everything-claude-code | Memory injection into system prompts | Enhance `remember` skill |
| everything-claude-code | Multi-model review (use different model for review) | New skill or enhance `review` |
| claude-forge | Refactor agent with auto-detect patterns | New `refactor` skill |
| claude-forge | Performance profiling skill | New `perf-audit` skill |
| claude-workflow-v2 | Diff-aware verify (only verify changed areas) | Enhance `verify` skill |
| agent-toolkit | Skill packaging as npm modules | Future distribution model |
| ok-skills | Cursor/Windsurf adapter format | Expand Phase 4 adapters |
