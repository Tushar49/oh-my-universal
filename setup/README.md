# oh-my-universal — Setup

Cross-platform installers for the oh-my-universal skill ecosystem.
Three equivalent scripts; pick the one that matches your shell:

| Script        | Best for                              |
|---------------|---------------------------------------|
| `setup.ps1`   | Windows (PowerShell 5.1 or 7+)        |
| `setup.sh`    | macOS / Linux / WSL / Git Bash        |
| `setup.py`    | Anywhere with Python 3.9+ installed   |

All three implement the **same** install / uninstall / status workflow.
You only need one.

---

## Quick start

### Windows (PowerShell, recommended: run as admin for symlink rights)

```powershell
cd E:\Projects\oh-my-universal\setup
# Interactive menu
.\setup.ps1

# Or non-interactive
.\setup.ps1 -Action status
.\setup.ps1 -Action install -Target copilot
.\setup.ps1 -Action uninstall -Target all
```

If execution policy blocks the script, either run with bypass:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```
or for the current user (one-time):
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### macOS / Linux / WSL

```bash
cd ~/oh-my-universal/setup
chmod +x setup.sh
./setup.sh                                # Interactive menu
./setup.sh status
./setup.sh install copilot
./setup.sh uninstall all
```

### Cross-platform Python

```bash
python setup.py                # Interactive menu
python setup.py status
python setup.py install copilot
python setup.py uninstall all
```

---

## What gets installed where

| CLI                       | Install type | What we put down                                                                  |
|---------------------------|--------------|-----------------------------------------------------------------------------------|
| Copilot (VS Code + CLI)   | global       | Per-skill `SKILL.md` wrappers in `~/.copilot/skills/<name>/`, plus group junctions, an instructions file at `~/.copilot/instructions/oh-my-universal-skills.instructions.md`, and VS Code prompts. |
| Claude Code               | global       | Junction(s) for skill groups under `~/.claude/skills/`.                           |
| Cursor                    | global       | Marker-bracketed rules file at `~/.cursor/rules/omu-skills.mdc`.                  |
| Gemini CLI                | per-project  | Marker section appended to `<project>/GEMINI.md`.                                 |
| Windsurf                  | per-project  | Marker section appended to `<project>/.windsurfrules`.                            |
| OpenAI Codex              | per-project  | Marker section appended to `<project>/AGENTS.md`.                                 |
| OpenCode                  | per-project  | Marker section appended to `<project>/AGENTS.md`.                                 |

Per-project CLIs require `--project <path>` (bash / python) or `-Project <path>` (PowerShell).

---

## Per-project install / uninstall

For Gemini, Windsurf, Codex, and OpenCode, the script writes a clearly-marked
section to the project's shared file:

```text
# >>> oh-my-universal START >>>
# Skills available via oh-my-universal ...
# <<< oh-my-universal END <<<
```

Only this block is added/removed. **Everything else in the file is preserved
byte-for-byte.** If you have a hand-written AGENTS.md, your content is safe.

```powershell
# Windows: install into a project
.\setup.ps1 -Action install -Target codex -Project C:\code\my-app

# Uninstall — removes only the marked block
.\setup.ps1 -Action uninstall -Target codex -Project C:\code\my-app
```

```bash
# macOS / Linux / Python (works the same way)
./setup.sh install codex --project ~/code/my-app
./setup.sh uninstall codex --project ~/code/my-app

python setup.py install codex --project ~/code/my-app
python setup.py uninstall codex --project ~/code/my-app
```

---

## Uninstall safety guarantees

The uninstaller will **never**:

- Delete a `SKILL.md` that doesn't contain our `oh-my-universal` marker.
- Delete an instruction or rules file that doesn't contain our marker.
- Delete a junction/symlink that doesn't point inside `oh-my-universal`.
- Delete or modify a VS Code prompt whose content has been edited by the user
  (we hash-compare against the original first; modified prompts are kept).
- Touch any content above or below our marker block in shared files
  (`AGENTS.md`, `GEMINI.md`, `.windsurfrules`).

If the per-project file becomes empty after removing our block, it is deleted
(otherwise the user is left with an empty file they didn't create).

---

## Status output

```text
  oh-my-universal Status
  ---------------------
  Repo: E:\Projects\oh-my-universal
  Skills: 69

  CLI                        Found      Supported  Installed      Type
  ---                        -----      ---------  ---------      ----
  Copilot (VS Code + CLI)    Yes        Yes        Yes (69)       global
  Claude Code                Yes        Yes        Yes (1)        global
  Gemini CLI                 No         Yes        per-project    per-project
  Cursor                     Yes        Yes        Yes (1)        global
  ...
```

- **Found**: the CLI binary or `~/.<cli>/` config dir is present.
- **Supported**: this repo ships an adapter for that CLI.
- **Installed**: number of `oh-my-universal` skill wrappers (or `1` if a
  marker file is in place).

---

## Smoke tests

Run the bundled tests after making changes:

```powershell
# Windows
.\test.ps1
```

```bash
# macOS / Linux
./test.sh

# Cross-platform
python test.py
```

Each test:

1. Parses all three installer scripts.
2. Runs `status` on each.
3. Performs an install + uninstall in a throwaway temp project.
4. Verifies the user's content is preserved exactly.

Exit code `0` = all green. Non-zero = at least one check failed.

---

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `script ... is not digitally signed` | Run with `-ExecutionPolicy Bypass` (above) or set `RemoteSigned` for your user. |
| `Missing ] at end of attribute or type literal` (PS 5.1) | The file lost its UTF-8 BOM. Re-pull the repo or run: `$b=[IO.File]::ReadAllBytes('setup.ps1'); [IO.File]::WriteAllBytes('setup.ps1',[byte[]](0xEF,0xBB,0xBF)+$b)`. |
| `SyntaxError: f-string: expecting '}'` (Python) | You're on Python &lt; 3.9. Upgrade or use `setup.ps1` / `setup.sh` instead. |
| Box drawing chars look like `ΓöÇ` | Console code page is cp437/cp1252. Use Windows Terminal, or set `chcp 65001` first. The output is otherwise correct. |
| Non-admin: junctions fail | Junctions don't actually need admin on modern Windows. If they fail, the script falls back to copies. |

---

## File layout

```
setup/
├── setup.ps1     # Windows installer (UTF-8 with BOM — required for PS 5.1)
├── setup.sh      # POSIX installer (UTF-8 no BOM — required for shebang)
├── setup.py      # Python installer (UTF-8 no BOM)
├── test.ps1      # Windows smoke test
├── test.sh       # POSIX smoke test
├── test.py       # Cross-platform smoke test
└── README.md     # this file
```
