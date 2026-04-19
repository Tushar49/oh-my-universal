# clawhip Research

> Source: https://github.com/Yeachan-Heo/clawhip

## What It Is
Daemon-first Discord notification gateway. Routes events from GitHub, tmux,
and custom sources to Discord channels. Filesystem-based memory offload.

## Key Features (PORT THESE)

| Feature | What it does | Port priority |
|---------|-------------|---------------|
| Discord notifications | Notify when tasks complete | HIGH |
| GitHub event routing | PR status, issue opened, commits | MEDIUM |
| tmux session monitoring | Watch for keywords, stale sessions | MEDIUM |
| Memory offload | Persist context to filesystem | HIGH |
| Plugin bridges | Connect to Codex/Claude Code | HIGH |

## Configuration
- `~/.clawhip/config.toml` - daemon config
- `~/.clawhip/plugins/` - plugin directory
- Plugin manifests: `plugins/codex/plugin.toml`, `plugins/claude-code/plugin.toml`

## Architecture
- Daemon runs at `http://127.0.0.1:25294`
- Typed event pipeline -> renderer -> delivery sink
- Multi-delivery router (Discord, file, custom)
- Bridges connect to Codex/Claude via shell scripts

## Dependencies
- Rust/Cargo, Discord bot token/webhook, tmux (optional), systemd (optional)
