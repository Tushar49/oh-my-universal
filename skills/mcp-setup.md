# Skill: mcp-setup

> Auto-detect project type and configure MCP servers for the current CLI tool.
> Inspired by: oh-my-claudecode (mcp-setup)

## When to Trigger

- User says "setup mcp", "configure mcp servers", "add mcp server"
- When an MCP server is needed but not configured
- As part of initial project setup (after doctor/health check)
- User says "what mcp servers should I use"

## Workflow

### Step 1 — Detect Project Stack

Scan the project root for tech stack indicators:

| File | Stack |
|------|-------|
| package.json | Node.js / JavaScript / TypeScript |
| requirements.txt, pyproject.toml, setup.py | Python |
| go.mod | Go |
| Cargo.toml | Rust |
| pom.xml, build.gradle | Java / Kotlin |
| *.sln, *.csproj | .NET / C# |
| docker-compose.yml | Docker |
| .github/ | GitHub Actions |

Also detect databases (prisma/schema.prisma, .env with DATABASE_URL), cloud providers (serverless.yml, cdk.json, terraform/), and API patterns (openapi.yaml, graphql/).

### Step 2 — Check Existing Config

Look for existing MCP configuration in order:
1. `.mcp.json` (Claude Code project-level)
2. `.vscode/mcp.json` (VS Code / Copilot)
3. `~/.copilot/mcp-config.json` (Copilot CLI global)
4. `~/.claude/mcp.json` (Claude Code global)

List which servers are already configured and their status.

### Step 3 — Suggest MCP Servers

Based on detected stack, recommend servers from the registry:

| Stack | Recommended Server | Package |
|-------|--------------------|---------|
| Any project | filesystem | @anthropic/mcp-server-filesystem |
| GitHub repo | github | @modelcontextprotocol/server-github |
| PostgreSQL | postgres | @modelcontextprotocol/server-postgres |
| SQLite | sqlite | @modelcontextprotocol/server-sqlite |
| Docker | docker | mcp-server-docker |
| Playwright | playwright | @anthropic/mcp-server-playwright |
| Memory/state | memory | @modelcontextprotocol/server-memory |

Present recommendations with rationale. Let user pick which to install.

### Step 4 — Generate Config

Generate the MCP config file for the detected or specified CLI tool:

**Claude Code** (`.mcp.json`):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

**Copilot CLI** (`~/.copilot/mcp-config.json`):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

**VS Code** (`.vscode/mcp.json`):
```json
{
  "servers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

### Step 5 — Handle Auth

For servers that need credentials:
1. Check if the env var already exists (e.g., `GITHUB_TOKEN`).
2. If not, prompt the user for the value.
3. Never write raw secrets into config files - use `${ENV_VAR}` references.
4. Suggest adding secrets to `.env` or the system environment.

### Step 6 — Verify

After config is written:
1. Run the MCP server command to verify it starts.
2. Check for connection errors or missing dependencies.
3. Report status for each configured server.

## Output Format

```
MCP Setup — {project name}
==========================

Detected stack: Node.js, PostgreSQL, GitHub

Existing config: .mcp.json (2 servers configured)

Recommended additions:
  + postgres — @modelcontextprotocol/server-postgres
    Reason: prisma/schema.prisma detected with PostgreSQL provider
  + playwright — @anthropic/mcp-server-playwright
    Reason: playwright.config.ts found

Already configured:
  ✓ github — working
  ✓ filesystem — working

Install recommended servers? (y/n)
```

## Rules

- Never write raw API keys or tokens into config files - always use env var references
- Don't remove existing server configs - only add or update
- Show what will be written before writing (user confirms)
- If the CLI tool can't be detected, ask the user which config format to use
- Install server packages only after user approval
- Keep config minimal - don't add servers the project won't use
- If a server fails verification, report the error but don't remove the config

## Not Responsible For

- MCP server development or debugging
- Managing API key rotation or secrets vaults
- CLI-specific hook/extension installation
- Running MCP servers in production
