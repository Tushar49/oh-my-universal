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

## Key Patterns to Adopt

1. **From planning-with-files**: persistent plan.md with phase tracking - we already do this
2. **From caveman**: ultra-compact skill files that minimize token usage
3. **From claude-forge**: hook-based safety gates (review before commit)
4. **From everything-claude-code**: skill taxonomy with categories
5. **From ok-skills**: portable skills that work across Codex/Claude/Cursor - our core approach
