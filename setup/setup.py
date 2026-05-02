#!/usr/bin/env python3
"""
oh-my-universal Setup — Cross-platform installer for AI coding CLI skills.

Supports: Copilot (VS Code + CLI), Claude Code, Gemini CLI, Cursor,
          Windsurf, Codex, OpenCode.

Usage:
    python setup.py                                           # Interactive menu
    python setup.py install copilot                           # Direct install
    python setup.py install all                               # Install into all detected CLIs
    python setup.py uninstall copilot                         # Remove from Copilot
    python setup.py status                                    # Show what's installed
    python setup.py install gemini --project /path/to/proj    # Per-project install
    python setup.py uninstall codex --project /path/to/proj   # Per-project uninstall
"""

import hashlib
import os
import platform
import re
import shutil
import sys
from pathlib import Path
from typing import Optional

# Python 3.9+ required (PEP 585 generics: dict[str, bool], list[str])
if sys.version_info < (3, 9):
    print("ERROR: oh-my-universal setup requires Python 3.9 or newer.")
    print(f"  Detected: Python {sys.version_info.major}.{sys.version_info.minor}")
    sys.exit(1)

# Ensure stdout/stderr emit UTF-8 — required for box-drawing chars in the UI.
# On Windows the default is often cp1252 which can't encode U+2500 etc.
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        try:
            _stream.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass

# ── Constants ────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).resolve().parent
OMU_ROOT = SCRIPT_DIR.parent

if not (OMU_ROOT / "skills").is_dir():
    print(f"ERROR: Cannot find oh-my-universal repo root at {OMU_ROOT}")
    sys.exit(1)

SKILLS_DIR = OMU_ROOT / "skills"
GH_SKILLS_DIR = OMU_ROOT / ".github" / "skills"
GH_INSTRUCT_DIR = OMU_ROOT / ".github" / "instructions"
GH_PROMPTS_DIR = OMU_ROOT / ".github" / "prompts"
CLAUDE_SKILLS_DIR = OMU_ROOT / ".claude" / "skills"
CURSOR_RULES_DIR = OMU_ROOT / ".cursor" / "rules"
WINDSURF_RULES = OMU_ROOT / ".windsurfrules"

MARKER = "# [oh-my-universal]"
MARKER_START = "# >>> oh-my-universal START >>>"
MARKER_END = "# <<< oh-my-universal END <<<"

HOME = Path.home()
IS_WINDOWS = platform.system() == "Windows"
IS_MACOS = platform.system() == "Darwin"

CLI_ORDER = ["copilot", "claude", "gemini", "cursor", "windsurf", "codex", "opencode"]
CLI_NAMES = {
    "copilot": "Copilot (VS Code + CLI)",
    "claude": "Claude Code",
    "gemini": "Gemini CLI",
    "cursor": "Cursor",
    "windsurf": "Windsurf",
    "codex": "OpenAI Codex",
    "opencode": "OpenCode",
}
CLI_INSTALL_TYPE = {
    "copilot": "global",
    "claude": "global",
    "gemini": "per-project",
    "cursor": "global",
    "windsurf": "per-project",
    "codex": "per-project",
    "opencode": "per-project",
}


# ── Colors ───────────────────────────────────────────────────────────────────

def _supports_color():
    if not hasattr(sys.stdout, "isatty") or not sys.stdout.isatty():
        return False
    if IS_WINDOWS:
        try:
            import ctypes
            kernel32 = ctypes.windll.kernel32
            kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            return True
        except Exception:
            return os.environ.get("TERM") is not None
    return True


USE_COLOR = _supports_color()


def _c(code, text):
    return f"\033[{code}m{text}\033[0m" if USE_COLOR else text


def ok(msg):
    print(f"  {_c('32', '[OK]')} {msg}")


def skip(msg):
    print(f"  {_c('2', '[SKIP]')} {msg}")


def warn(msg):
    print(f"  {_c('33', '[WARN]')} {msg}")


def err(msg):
    print(f"  {_c('31', '[FAIL]')} {msg}")


def info(msg):
    print(f"  {_c('36', msg)}")


# ── Helpers ──────────────────────────────────────────────────────────────────

def get_skill_description(skill_file: Path) -> str:
    try:
        lines = skill_file.read_text(encoding="utf-8").splitlines()[:6]
        for line in lines:
            if line.startswith(">"):
                desc = line.lstrip("> ").strip()
                return desc[:120]
    except Exception:
        pass
    return "oh-my-universal skill"


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def has_command(name: str) -> bool:
    return shutil.which(name) is not None


def is_junction_or_symlink(path: Path) -> bool:
    """Detect Windows junctions (which Path.is_symlink() misses on Python <3.12) AND symlinks."""
    if path.is_symlink():
        return True
    if not IS_WINDOWS:
        return False
    # Windows junction probe: stat with FILE_ATTRIBUTE_REPARSE_POINT (0x400).
    try:
        attrs = os.stat(path, follow_symlinks=False).st_file_attributes
        return bool(attrs & 0x400)  # FILE_ATTRIBUTE_REPARSE_POINT
    except (AttributeError, OSError):
        pass
    # Fallback: try os.readlink — succeeds for junctions on Python 3.8+.
    try:
        os.readlink(path)
        return True
    except OSError:
        return False


def get_junction_target(path: Path) -> str:
    """Get the target of a junction or symlink as a string."""
    try:
        return str(os.readlink(path))
    except OSError:
        return ""


def make_symlink(target: Path, source: Path, is_dir: bool = False):
    """Create symlink/junction. On Windows without admin, uses junction for dirs."""
    try:
        if IS_WINDOWS and is_dir:
            # Try junction first (works without admin)
            import subprocess
            result = subprocess.run(
                ["cmd", "/c", "mklink", "/J", str(target), str(source)],
                capture_output=True, text=True
            )
            return result.returncode == 0
        else:
            target.symlink_to(source, target_is_directory=is_dir)
            return True
    except OSError:
        return False


def remove_junction(path: Path):
    """Remove a junction/symlink directory without deleting contents."""
    if IS_WINDOWS:
        import subprocess
        subprocess.run(["cmd", "/c", "rmdir", str(path)], capture_output=True)
    else:
        path.unlink()


def find_vscode_prompts_dir() -> Optional[Path]:
    portable = os.environ.get("VSCODE_PORTABLE")
    if portable:
        p = Path(portable) / "user-data" / "User" / "prompts"
        if p.parent.exists():
            return p

    if IS_WINDOWS:
        candidates = [
            Path(os.environ.get("APPDATA", "")) / "Code" / "User" / "prompts",
            Path(os.environ.get("APPDATA", "")) / "Code - Insiders" / "User" / "prompts",
        ]
    elif IS_MACOS:
        candidates = [
            HOME / "Library" / "Application Support" / "Code" / "User" / "prompts",
            HOME / "Library" / "Application Support" / "Code - Insiders" / "User" / "prompts",
        ]
    else:
        candidates = [
            HOME / ".config" / "Code" / "User" / "prompts",
            HOME / ".config" / "Code - Insiders" / "User" / "prompts",
        ]

    for c in candidates:
        if c.exists() or c.parent.exists():
            return c
    return None


VSCODE_PROMPTS_DIR = find_vscode_prompts_dir()


# ── Detection ────────────────────────────────────────────────────────────────

cli_available: dict[str, bool] = {}
cli_omu_installed: dict[str, bool] = {}
cli_omu_count: dict[str, int] = {}
cli_omu_supported: dict[str, bool] = {}


def detect_omu_support():
    """Detect which CLIs have adapter files in the repo."""
    cli_omu_supported["copilot"] = (
        (GH_INSTRUCT_DIR / "skills.instructions.md").is_file()
        or GH_SKILLS_DIR.is_dir()
        or GH_PROMPTS_DIR.is_dir()
    )
    cli_omu_supported["claude"] = (
        (OMU_ROOT / "CLAUDE.md").is_file() or CLAUDE_SKILLS_DIR.is_dir()
    )
    cli_omu_supported["gemini"] = (OMU_ROOT / "GEMINI.md").is_file()
    cli_omu_supported["cursor"] = (CURSOR_RULES_DIR / "skills.mdc").is_file()
    cli_omu_supported["windsurf"] = WINDSURF_RULES.is_file()
    cli_omu_supported["codex"] = (OMU_ROOT / "AGENTS.md").is_file()
    cli_omu_supported["opencode"] = (OMU_ROOT / "AGENTS.md").is_file()


def count_omu_skills(skills_dir: Path) -> int:
    """Count SKILL.md files containing our marker under a directory."""
    if not skills_dir.is_dir():
        return 0
    count = 0
    for d in skills_dir.iterdir():
        if not d.is_dir():
            continue
        sf = d / "SKILL.md"
        if sf.is_file():
            try:
                if "oh-my-universal" in sf.read_text(encoding="utf-8", errors="ignore"):
                    count += 1
            except OSError:
                pass
    return count


def detect_clis():
    copilot_dir = HOME / ".copilot"
    cli_available["copilot"] = copilot_dir.is_dir()
    omu_count = count_omu_skills(copilot_dir / "skills")
    cli_omu_count["copilot"] = omu_count
    cli_omu_installed["copilot"] = omu_count > 0

    cli_available["claude"] = has_command("claude")
    claude_skills = HOME / ".claude" / "skills"
    claude_count = 0
    if claude_skills.is_dir():
        for d in claude_skills.iterdir():
            if not d.is_dir():
                continue
            if d.is_symlink():
                try:
                    if "oh-my-universal" in str(os.readlink(d)):
                        claude_count += 1
                except OSError:
                    pass
            elif IS_WINDOWS:
                # Junction detection: read the reparse target via cmd dir /AL
                import subprocess
                try:
                    res = subprocess.run(
                        ["cmd", "/c", "dir", "/AL", str(claude_skills)],
                        capture_output=True, text=True, timeout=5
                    )
                    if d.name in res.stdout and "oh-my-universal" in res.stdout:
                        claude_count += 1
                except Exception:
                    pass
    cli_omu_count["claude"] = claude_count
    cli_omu_installed["claude"] = claude_count > 0

    cli_available["gemini"] = has_command("gemini")
    cli_omu_count["gemini"] = 0
    cli_omu_installed["gemini"] = False

    cursor_dir = HOME / ".cursor"
    cli_available["cursor"] = cursor_dir.is_dir()
    rules_file = cursor_dir / "rules" / "omu-skills.mdc"
    cursor_installed = False
    if rules_file.is_file():
        try:
            cursor_installed = "oh-my-universal" in rules_file.read_text(
                encoding="utf-8", errors="ignore"
            )
        except OSError:
            pass
    cli_omu_count["cursor"] = 1 if cursor_installed else 0
    cli_omu_installed["cursor"] = cursor_installed

    cli_available["windsurf"] = has_command("windsurf")
    cli_omu_count["windsurf"] = 0
    cli_omu_installed["windsurf"] = False

    cli_available["codex"] = has_command("codex")
    cli_omu_count["codex"] = 0
    cli_omu_installed["codex"] = False

    cli_available["opencode"] = has_command("opencode")
    cli_omu_count["opencode"] = 0
    cli_omu_installed["opencode"] = False


# ── Install ──────────────────────────────────────────────────────────────────

def is_inside_repo(path: Path) -> bool:
    """Check whether path resolves (after following any junctions/symlinks) to a
    location inside OMU_ROOT. Catches the case where a parent like ~/.copilot/skills
    is a junction pointing back into the repo."""
    try:
        resolved_root = OMU_ROOT.resolve()
    except OSError:
        resolved_root = OMU_ROOT

    # Direct resolve: follows symlinks AND junctions on Windows (Python 3.6+).
    try:
        resolved = path.resolve()
        if resolved == resolved_root or resolved_root in resolved.parents:
            return True
    except OSError:
        pass

    # Walk up: if any existing ancestor is a symlink/junction into the repo, refuse.
    candidate = path
    while candidate != candidate.parent:
        if candidate.exists():
            try:
                target_str = str(candidate.resolve())
                root_str = str(resolved_root)
                if IS_WINDOWS:
                    target_str, root_str = target_str.lower(), root_str.lower()
                if target_str == root_str or target_str.startswith(root_str + os.sep):
                    return True
            except OSError:
                pass
            break
        candidate = candidate.parent
    return False


def install_copilot():
    print(f"\n  {_c('1', 'Installing into Copilot...')}")
    copilot_dir = HOME / ".copilot"
    skills_target = copilot_dir / "skills"
    instr_target = copilot_dir / "instructions"

    # Safety: never install inside the source repo. Catches direct paths AND
    # paths that resolve into the repo via a parent junction/symlink.
    if is_inside_repo(skills_target):
        err(f"REFUSING to install: {skills_target} resolves inside source repo {OMU_ROOT}")
        err("Likely cause: ~/.copilot/skills (or a parent) is a junction pointing into the repo.")
        if IS_WINDOWS:
            err(f'Fix: cmd /c rmdir "{skills_target}" — then re-run install.')
        else:
            err(f'Fix: rm "{skills_target}" — then re-run install.')
        return

    skills_target.mkdir(parents=True, exist_ok=True)
    instr_target.mkdir(parents=True, exist_ok=True)

    # 1. Create individual skill wrappers
    created = skipped = 0
    for skill_file in sorted(SKILLS_DIR.glob("*.md")):
        name = skill_file.stem
        target_dir = skills_target / name
        target_file = target_dir / "SKILL.md"

        if target_file.is_file():
            content = target_file.read_text(encoding="utf-8", errors="ignore")
            if "oh-my-universal" in content:
                skipped += 1
                continue
            warn(f"Skipping {name} — SKILL.md exists but isn't ours")
            skipped += 1
            continue

        desc = get_skill_description(skill_file)
        target_dir.mkdir(parents=True, exist_ok=True)

        wrapper = f"""---
name: {name}
description: "{desc}"
---
{MARKER}
# {name}

Read and execute the full skill workflow from:

{skill_file}

Use read_file to load the instructions from that absolute path, then follow them.
"""
        target_file.write_text(wrapper, encoding="utf-8")
        created += 1
    ok(f"Skills: {created} created, {skipped} already present")

    # 2. Symlink/junction skill groups (or copy+patch routers)
    gjc = gjs = gjp = 0
    if GH_SKILLS_DIR.is_dir():
        for group_dir in sorted(GH_SKILLS_DIR.iterdir()):
            if not group_dir.is_dir():
                continue
            target = skills_target / group_dir.name
            result = install_group_dir(group_dir, target)
            if result == "junctioned":
                gjc += 1
            elif result == "patched":
                gjp += 1
            elif result == "kept":
                gjs += 1
            else:
                warn(f"Failed to link group: {group_dir.name}")
    ok(f"Skill groups: {gjc} linked, {gjp} routers patched, {gjs} already present")

    # 3. Instructions file
    instr_src = GH_INSTRUCT_DIR / "skills.instructions.md"
    instr_dst = instr_target / "oh-my-universal-skills.instructions.md"
    if instr_src.is_file():
        content = instr_src.read_text(encoding="utf-8")
        content = re.sub(
            r"skills/([a-z-]+)\.md",
            lambda m: str(SKILLS_DIR / f"{m.group(1)}.md"),
            content,
        )
        instr_dst.write_text(
            f"{MARKER_START}\n{content}\n{MARKER_END}\n", encoding="utf-8"
        )
        ok("Instructions file installed")

    # 4. VS Code prompts
    if VSCODE_PROMPTS_DIR and GH_PROMPTS_DIR.is_dir():
        VSCODE_PROMPTS_DIR.mkdir(parents=True, exist_ok=True)
        pc = ps = 0
        for prompt_file in sorted(GH_PROMPTS_DIR.glob("*.prompt.md")):
            target = VSCODE_PROMPTS_DIR / prompt_file.name
            if target.exists():
                ps += 1
                continue
            # Symlink on unix, copy on Windows (hardlinks may fail cross-volume)
            if not IS_WINDOWS:
                try:
                    target.symlink_to(prompt_file)
                    pc += 1
                    continue
                except OSError:
                    pass
            shutil.copy2(prompt_file, target)
            pc += 1
        ok(f"VS Code prompts: {pc} installed, {ps} already present")
    else:
        skip("VS Code prompts folder not found")

    ok("Copilot installation complete")


def install_claude():
    print(f"\n  {_c('1', 'Installing into Claude Code...')}")
    claude_skills = HOME / ".claude" / "skills"
    claude_skills.mkdir(parents=True, exist_ok=True)

    if CLAUDE_SKILLS_DIR.is_dir():
        gjc = gjs = gjp = 0
        for group_dir in sorted(CLAUDE_SKILLS_DIR.iterdir()):
            if not group_dir.is_dir():
                continue
            target = claude_skills / group_dir.name
            result = install_group_dir(group_dir, target)
            if result == "junctioned":
                gjc += 1
            elif result == "patched":
                gjp += 1
            elif result == "kept":
                gjs += 1
            else:
                warn(f"Failed to link: {group_dir.name}")
        ok(f"Claude skill groups: {gjc} linked, {gjp} routers patched, {gjs} already present")

    ok("Claude Code installation complete")
    info(f'Tip: alias claude=\'claude --plugin-dir "{OMU_ROOT}"\'')


def get_omu_project_body() -> str:
    """Body content injected into per-project shared files."""
    return f"""# Skills available via oh-my-universal (read these files for full workflows):
#   Repo:   {OMU_ROOT}
#   Skills: {SKILLS_DIR}
#
# Common skills: plan, ultrawork, autopilot, verify, build-fix, tdd, ralph,
#                review, security-review, deep-dive, trace, ask, doctor,
#                release, doc-maintainer, refactor, team. (69 total.)
#
# To invoke: 'plan this refactoring', 'review my changes', 'ultrawork: <task>',
# 'fix the build', 'deep-dive into <bug>', etc."""


_SKILLS_REF_RE = re.compile(r"skills/([a-z-]+)\.md")


def is_group_router(skill_file: Path) -> bool:
    """A 'group router' SKILL.md uses relative refs like `skills/team.md`.
    When installed via symlink/junction, those relative refs can't resolve because
    the source dir has no co-located `skills/` subfolder. We must patch the
    content to use absolute paths."""
    if not skill_file.is_file():
        return False
    try:
        content = skill_file.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    return bool(_SKILLS_REF_RE.search(content))


def get_patched_router_content(source_path: Path) -> str:
    """Read a router SKILL.md and rewrite relative skills/<name>.md refs to absolute paths.
    Adds a marker so uninstall can identify our installed copies unambiguously."""
    content = source_path.read_text(encoding="utf-8")
    patched = _SKILLS_REF_RE.sub(lambda m: str(SKILLS_DIR / f"{m.group(1)}.md"), content)
    marker = f"<!-- {MARKER} (installed copy with absolute paths to {SKILLS_DIR}) -->"
    fm = re.match(r"(?s)^(---\r?\n.*?\r?\n---\r?\n)", patched)
    if fm:
        patched = patched[: fm.end()] + marker + "\n" + patched[fm.end():]
    else:
        patched = f"{marker}\n{patched}"
    return patched


def install_group_dir(group_dir: Path, target: Path) -> str:
    """Install a single group skill directory.
    Returns: 'patched' / 'junctioned' (symlink) / 'kept' / 'failed'."""

    if is_inside_repo(target):
        err(f"REFUSING to install inside source repo: {target}")
        return "failed"

    source_skill = group_dir / "SKILL.md"

    if is_group_router(source_skill):
        # Replace any existing junction/symlink with a real dir we can patch into.
        if target.exists() and (target.is_symlink() or (IS_WINDOWS and not (target / "SKILL.md").is_file())):
            try:
                if target.is_symlink():
                    target.unlink()
                else:
                    remove_junction(target)
            except OSError:
                pass
        target.mkdir(parents=True, exist_ok=True)
        target_skill = target / "SKILL.md"

        # Idempotent: skip if already patched and pointing to current repo.
        if target_skill.is_file():
            existing = target_skill.read_text(encoding="utf-8", errors="ignore")
            if str(SKILLS_DIR) in existing and not _SKILLS_REF_RE.search(existing):
                return "kept"
        target_skill.write_text(get_patched_router_content(source_skill), encoding="utf-8")
        return "patched"

    # Non-router: junction/symlink (faster, single source of truth).
    if target.exists():
        return "kept"
    if make_symlink(target, group_dir, is_dir=True):
        return "junctioned"
    return "failed"


def add_omu_marked_section(path: Path, body: str):
    """Append (or update) the oh-my-universal section in a shared file.

    Preserves any user content above and below the markers.
    """
    section = f"{MARKER_START}\n{body}\n{MARKER_END}"
    existing = path.read_text(encoding="utf-8") if path.is_file() else ""

    if MARKER_START in existing:
        start_idx = existing.index(MARKER_START)
        end_search = existing.find(MARKER_END, start_idx)
        if end_search < 0:
            new_content = existing[:start_idx].rstrip() + "\n\n" + section + "\n"
        else:
            end_of_block = end_search + len(MARKER_END)
            before = existing[:start_idx].rstrip()
            after = existing[end_of_block:].lstrip("\r\n")
            new_content = section if not before else f"{before}\n\n{section}"
            if after:
                new_content = f"{new_content}\n\n{after}"
            new_content = new_content.rstrip() + "\n"
    elif existing.strip():
        new_content = existing.rstrip() + "\n\n" + section + "\n"
    else:
        new_content = section + "\n"

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(new_content, encoding="utf-8")


def remove_omu_marked_section(path: Path) -> bool:
    """Remove only the oh-my-universal section, leaving everything else intact.

    Returns True if a section was removed, False otherwise.
    """
    if not path.is_file():
        return False
    content = path.read_text(encoding="utf-8")
    start_idx = content.find(MARKER_START)
    if start_idx < 0:
        return False
    end_search = content.find(MARKER_END, start_idx)
    if end_search < 0:
        return False
    end_of_block = end_search + len(MARKER_END)
    before = content[:start_idx].rstrip()
    after = content[end_of_block:].lstrip("\r\n")
    if before and after:
        new_content = f"{before}\n\n{after}\n"
    elif before:
        new_content = f"{before}\n"
    elif after:
        new_content = f"{after}\n"
    else:
        new_content = ""

    if not new_content.strip():
        path.unlink()
    else:
        path.write_text(new_content, encoding="utf-8")
    return True


def install_per_project(cli_key: str, project_path: str, file_name: str):
    """Add/refresh the OMU marker section in <project>/<file_name>."""
    proj = Path(project_path).expanduser().resolve()
    if not proj.exists():
        err(f"Project path does not exist: {proj}")
        return
    target = proj / file_name
    add_omu_marked_section(target, get_omu_project_body())
    ok(f"{cli_key} ({file_name}): marker section installed at {target}")


def uninstall_per_project(cli_key: str, project_path: str, file_name: str):
    """Remove the OMU marker section from <project>/<file_name>; preserve everything else."""
    proj = Path(project_path).expanduser().resolve()
    if not proj.exists():
        err(f"Project path does not exist: {proj}")
        return
    target = proj / file_name
    if not target.is_file():
        skip(f"{cli_key} ({file_name}) not present at {target}")
        return
    if remove_omu_marked_section(target):
        ok(f"{cli_key} ({file_name}): marker section removed from {target}")
    else:
        skip(f"{cli_key} ({file_name}): no oh-my-universal section found — left untouched")


# Globally-set project path (set by main() from --project flag).
PROJECT_PATH: Optional[str] = None


def install_gemini():
    print(f"\n  {_c('1', 'Installing into Gemini CLI...')}")
    if PROJECT_PATH:
        install_per_project("gemini", PROJECT_PATH, "GEMINI.md")
        return
    warn("Gemini CLI has no global config — pass --project <path> to install per-project.")
    info("Per-project options without this script:")
    info(f'  1. Shell alias:  alias gemini=\'gemini --plugin-dir "{OMU_ROOT}"\'')
    info(f'  2. Symlink:      ln -s "{SKILLS_DIR}" .omu-skills')
    ok("Gemini guidance provided (no files modified)")


def install_cursor():
    print(f"\n  {_c('1', 'Installing into Cursor...')}")
    rules_dir = HOME / ".cursor" / "rules"
    rules_dir.mkdir(parents=True, exist_ok=True)

    src = CURSOR_RULES_DIR / "skills.mdc"
    dst = rules_dir / "omu-skills.mdc"

    if dst.is_file():
        skip("Cursor rules file already installed")
    elif src.is_file():
        content = src.read_text(encoding="utf-8")
        content = re.sub(
            r"skills/([a-z-]+)\.md",
            lambda m: str(SKILLS_DIR / f"{m.group(1)}.md"),
            content,
        )
        dst.write_text(f"{MARKER_START}\n{content}\n{MARKER_END}\n", encoding="utf-8")
        ok("Cursor rules file installed")
    else:
        err(f"Source cursor rules not found: {src}")
    ok("Cursor installation complete")


def install_windsurf():
    print(f"\n  {_c('1', 'Installing into Windsurf...')}")
    if PROJECT_PATH:
        install_per_project("windsurf", PROJECT_PATH, ".windsurfrules")
        return
    warn("Windsurf reads .windsurfrules from project root only — pass --project <path>.")
    info("Per-project options without this script:")
    info(f'  1. Symlink: ln -s "{WINDSURF_RULES}" .windsurfrules')
    info(f'  2. Copy:    cp "{WINDSURF_RULES}" .windsurfrules')
    ok("Windsurf guidance provided (no files modified)")


def install_codex():
    print(f"\n  {_c('1', 'Installing into Codex...')}")
    if PROJECT_PATH:
        install_per_project("codex", PROJECT_PATH, "AGENTS.md")
        return
    warn("Codex reads AGENTS.md from cwd only — pass --project <path> to install per-project.")
    info("Per-project options without this script:")
    info(f'  1. Symlink: ln -s "{SKILLS_DIR}" .omu-skills')
    info("  2. Add to AGENTS.md: 'Read skills from .omu-skills/{name}.md'")
    ok("Codex guidance provided (no files modified)")


def install_opencode():
    print(f"\n  {_c('1', 'Installing into OpenCode...')}")
    if PROJECT_PATH:
        install_per_project("opencode", PROJECT_PATH, "AGENTS.md")
        return
    warn("OpenCode reads AGENTS.md from cwd — pass --project <path> to install per-project.")
    info("Same options as Codex above.")
    ok("OpenCode guidance provided (no files modified)")


# ── Uninstall ────────────────────────────────────────────────────────────────

def uninstall_copilot():
    print(f"\n  {_c('1', 'Uninstalling from Copilot...')}")
    copilot_dir = HOME / ".copilot"
    skills_target = copilot_dir / "skills"
    instr_target = copilot_dir / "instructions"

    # 1. Remove individual skill wrappers
    removed = kept = 0
    for skill_file in sorted(SKILLS_DIR.glob("*.md")):
        name = skill_file.stem
        target_dir = skills_target / name
        target_file = target_dir / "SKILL.md"

        if not target_file.is_file():
            continue

        content = target_file.read_text(encoding="utf-8", errors="ignore")
        if "oh-my-universal" in content:
            shutil.rmtree(target_dir)
            removed += 1
        else:
            kept += 1
    ok(f"Skills removed: {removed} (kept {kept} non-omu skills)")

    # 2. Remove skill groups: junctions/symlinks pointing to our repo, OR patched-router copies.
    gjr = gpr = 0
    if GH_SKILLS_DIR.is_dir():
        for group_dir in sorted(GH_SKILLS_DIR.iterdir()):
            if not group_dir.is_dir():
                continue
            target = skills_target / group_dir.name
            if not target.exists():
                continue
            if is_junction_or_symlink(target):
                link_target = get_junction_target(target)
                if "oh-my-universal" in link_target:
                    if IS_WINDOWS and not target.is_symlink():
                        remove_junction(target)
                    else:
                        target.unlink()
                    gjr += 1
                continue
            # Real dir: patched-router copy?
            sf = target / "SKILL.md"
            if sf.is_file():
                content = sf.read_text(encoding="utf-8", errors="ignore")
                if MARKER in content or "oh-my-universal" in content:
                    contents = list(target.iterdir())
                    if len(contents) == 1 and contents[0].name == "SKILL.md":
                        shutil.rmtree(target)
                        gpr += 1
                    else:
                        warn(f"Group {group_dir.name}: contains user-added files — kept")
    ok(f"Skill groups removed: {gjr} junctions/symlinks, {gpr} patched-router copies")

    # 3. Remove instructions file
    instr_file = instr_target / "oh-my-universal-skills.instructions.md"
    if instr_file.is_file():
        content = instr_file.read_text(encoding="utf-8", errors="ignore")
        if "oh-my-universal" in content:
            instr_file.unlink()
            ok("Instructions file removed")
        else:
            skip("Instructions file not ours — left untouched")
    else:
        skip("No instructions file to remove")

    # 4. Remove VS Code prompts
    if VSCODE_PROMPTS_DIR and GH_PROMPTS_DIR.is_dir():
        pr = 0
        for prompt_file in sorted(GH_PROMPTS_DIR.glob("*.prompt.md")):
            target = VSCODE_PROMPTS_DIR / prompt_file.name
            if not target.exists():
                continue

            if target.is_symlink():
                link_target = str(os.readlink(target))
                if "oh-my-universal" in link_target:
                    target.unlink()
                    pr += 1
            else:
                src_hash = file_hash(prompt_file)
                dst_hash = file_hash(target)
                if src_hash == dst_hash:
                    target.unlink()
                    pr += 1
                else:
                    skip(f"Prompt '{prompt_file.name}' modified by user — left untouched")
        ok(f"VS Code prompts removed: {pr}")

    ok("Copilot uninstall complete")


def uninstall_claude():
    print(f"\n  {_c('1', 'Uninstalling from Claude Code...')}")
    claude_skills = HOME / ".claude" / "skills"
    jr = pr = 0

    if claude_skills.is_dir():
        for d in sorted(claude_skills.iterdir()):
            if not d.is_dir():
                continue
            if is_junction_or_symlink(d):
                link_target = get_junction_target(d)
                if "oh-my-universal" in link_target:
                    if IS_WINDOWS and not d.is_symlink():
                        remove_junction(d)
                    else:
                        d.unlink()
                    jr += 1
                continue
            # Real dir: patched-router copy?
            sf = d / "SKILL.md"
            if sf.is_file():
                content = sf.read_text(encoding="utf-8", errors="ignore")
                if MARKER in content:
                    contents = list(d.iterdir())
                    if len(contents) == 1 and contents[0].name == "SKILL.md":
                        shutil.rmtree(d)
                        pr += 1
                    else:
                        warn(f"Claude group {d.name}: contains user-added files — kept")
    ok(f"Claude skill groups removed: {jr} junctions/symlinks, {pr} patched-router copies")
    ok("Claude uninstall complete")


def uninstall_cursor():
    print(f"\n  {_c('1', 'Uninstalling from Cursor...')}")
    rules_file = HOME / ".cursor" / "rules" / "omu-skills.mdc"
    if rules_file.is_file():
        content = rules_file.read_text(encoding="utf-8", errors="ignore")
        if "oh-my-universal" in content:
            rules_file.unlink()
            ok("Cursor rules file removed")
        else:
            skip("Cursor rules file not ours — left untouched")
    else:
        skip("No Cursor rules file to remove")
    ok("Cursor uninstall complete")


def uninstall_gemini():
    if PROJECT_PATH:
        uninstall_per_project("gemini", PROJECT_PATH, "GEMINI.md")
        return
    print(f"  {_c('2', 'Gemini: nothing to uninstall globally. Use --project <path> to remove from a project.')}")


def uninstall_windsurf():
    if PROJECT_PATH:
        uninstall_per_project("windsurf", PROJECT_PATH, ".windsurfrules")
        return
    print(f"  {_c('2', 'Windsurf: nothing to uninstall globally. Use --project <path> to remove from a project.')}")


def uninstall_codex():
    if PROJECT_PATH:
        uninstall_per_project("codex", PROJECT_PATH, "AGENTS.md")
        return
    print(f"  {_c('2', 'Codex: nothing to uninstall globally. Use --project <path> to remove from a project.')}")


def uninstall_opencode():
    if PROJECT_PATH:
        uninstall_per_project("opencode", PROJECT_PATH, "AGENTS.md")
        return
    print(f"  {_c('2', 'OpenCode: nothing to uninstall globally. Use --project <path> to remove from a project.')}")


# ── Status ───────────────────────────────────────────────────────────────────

def show_status():
    detect_clis()
    detect_omu_support()
    skill_count = len(list(SKILLS_DIR.glob("*.md")))

    print()
    print(f"  {_c('1', 'oh-my-universal Status')}")
    print("  ─────────────────────")
    print(f"  Repo: {OMU_ROOT}")
    print(f"  Skills: {skill_count}")
    print(f"  OS: {platform.system()} ({platform.machine()})")
    print()

    print(f"  {'CLI':<26} {'Found':<10} {'Supported':<10} {'Installed':<14} {'Type':<12}")
    print(f"  {'───':<26} {'─────':<10} {'─────────':<10} {'─────────':<14} {'────':<12}")

    for key in CLI_ORDER:
        name = CLI_NAMES[key]
        avail = "Yes" if cli_available.get(key) else "No"
        support = "Yes" if cli_omu_supported.get(key) else "No"
        itype = CLI_INSTALL_TYPE[key]
        if itype == "per-project":
            omu = "per-project"
        elif cli_omu_count.get(key, 0) > 0:
            omu = f"Yes ({cli_omu_count[key]})"
        else:
            omu = "No"
        print(f"  {name:<26} {avail:<10} {support:<10} {omu:<14} {itype:<12}")

    print()
    print(f"  {_c('2', 'per-project = use --project <path> to install/uninstall in a specific project.')}")

    # Copilot detail
    copilot_skills = HOME / ".copilot" / "skills"
    if copilot_skills.is_dir():
        omu_count = 0
        link_count = 0
        for d in copilot_skills.iterdir():
            if not d.is_dir():
                continue
            sf = d / "SKILL.md"
            if sf.is_file() and "oh-my-universal" in sf.read_text(encoding="utf-8", errors="ignore"):
                omu_count += 1
            if d.is_symlink() or (IS_WINDOWS and d.is_dir() and not sf.is_file()):
                link_count += 1

        print()
        print(f"  {_c('2', 'Copilot detail:')}")
        print(f"    {_c('36', f'Skill wrappers: {omu_count}')}")
        print(f"    {_c('36', f'Skill groups (links): {link_count}')}")

        instr_file = HOME / ".copilot" / "instructions" / "oh-my-universal-skills.instructions.md"
        status = "Installed" if instr_file.is_file() else "Not found"
        print(f"    {_c('36', f'Instructions file: {status}')}")

        if VSCODE_PROMPTS_DIR and VSCODE_PROMPTS_DIR.is_dir() and GH_PROMPTS_DIR.is_dir():
            prompt_count = sum(
                1
                for pf in GH_PROMPTS_DIR.glob("*.prompt.md")
                if (VSCODE_PROMPTS_DIR / pf.name).exists()
            )
            print(f"    {_c('36', f'VS Code prompts: {prompt_count}')}")

    print()


# ── Dispatch ─────────────────────────────────────────────────────────────────

INSTALL_FNS = {
    "copilot": install_copilot,
    "claude": install_claude,
    "gemini": install_gemini,
    "cursor": install_cursor,
    "windsurf": install_windsurf,
    "codex": install_codex,
    "opencode": install_opencode,
}

UNINSTALL_FNS = {
    "copilot": uninstall_copilot,
    "claude": uninstall_claude,
    "gemini": uninstall_gemini,
    "cursor": uninstall_cursor,
    "windsurf": uninstall_windsurf,
    "codex": uninstall_codex,
    "opencode": uninstall_opencode,
}


def execute_action(action: str, targets: list[str]):
    fns = INSTALL_FNS if action == "install" else UNINSTALL_FNS
    for t in targets:
        t = t.strip().lower()
        if t in fns:
            fns[t]()
        else:
            err(f"Unknown target: {t}")


# ── Interactive Menu ─────────────────────────────────────────────────────────

def select_targets(action_label: str) -> list[str]:
    detect_clis()
    print()
    print(f"  {_c('1', f'Select CLI targets to {action_label}')}")
    print("  ───────────────────────────────")
    print()

    index_map: dict[int, str] = {}
    for i, key in enumerate(CLI_ORDER, 1):
        name = CLI_NAMES[key]
        status = ""
        if action_label == "install" and cli_omu_installed.get(key):
            status = " (already installed)"
        elif action_label == "uninstall" and not cli_omu_installed.get(key):
            status = " (not installed)"
        avail = "" if cli_available.get(key) else " [not detected]"
        print(f"  [{i}] {name}{avail}{status}")
        index_map[i] = key

    all_idx = len(CLI_ORDER) + 1
    print(f"  {_c('36', f'[{all_idx}] All')}")
    print(f"  {_c('2', '[0] Cancel')}")
    print()

    try:
        selection = input("  Enter numbers (comma-separated, e.g. 1,2,4): ").strip()
    except (EOFError, KeyboardInterrupt):
        return []

    if selection == "0" or not selection:
        return []

    selected = []
    for num_str in selection.split(","):
        try:
            n = int(num_str.strip())
        except ValueError:
            continue
        if n == all_idx:
            return list(CLI_ORDER)
        if n in index_map:
            selected.append(index_map[n])
    return selected


def interactive_menu():
    while True:
        try:
            os.system("cls" if IS_WINDOWS else "clear")
        except Exception:
            pass

        print()
        print(f"  {_c('36', '╔══════════════════════════════════════════╗')}")
        print(f"  {_c('36', '║    oh-my-universal Setup                 ║')}")
        print(f"  {_c('36', '║    69 skills · 19 hooks · 4 contracts    ║')}")
        print(f"  {_c('36', '╚══════════════════════════════════════════╝')}")
        print()
        print(f"  {_c('1', '[1]')} Install        — Install into selected CLIs")
        print(f"  {_c('1', '[2]')} Uninstall      — Remove from selected CLIs")
        print(f"  {_c('1', '[3]')} Status         — Show what's installed where")
        print(f"  {_c('2', '[4] Exit')}")
        print()

        try:
            choice = input("  Choose [1-4]: ").strip()
        except (EOFError, KeyboardInterrupt):
            break

        if choice == "1":
            targets = select_targets("install")
            if targets:
                joined = ", ".join(targets)
                print(f"\n  {_c('36', f'Installing into: {joined}')}")
                execute_action("install", targets)
                print()
                input("  Press Enter to continue...")
        elif choice == "2":
            targets = select_targets("uninstall")
            if targets:
                print()
                print(f"  {_c('33', 'WARNING: This will remove oh-my-universal files ONLY.')}")
                print(f"  {_c('33', 'Your own skills, instructions, and configs will NOT be touched.')}")
                try:
                    confirm = input("  Type 'yes' to confirm: ").strip()
                except (EOFError, KeyboardInterrupt):
                    confirm = ""
                if confirm == "yes":
                    execute_action("uninstall", targets)
                else:
                    print("  Cancelled.")
                print()
                input("  Press Enter to continue...")
        elif choice == "3":
            show_status()
            input("  Press Enter to continue...")
        elif choice in ("4", "q", "Q"):
            break
        else:
            print(f"  {_c('31', 'Invalid choice.')}")


# ── Main ─────────────────────────────────────────────────────────────────────

def parse_project_arg(args: list[str]) -> tuple[list[str], Optional[str]]:
    """Strip --project <path> (or --project=<path>) from args; return (args, project)."""
    out: list[str] = []
    project: Optional[str] = None
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--project":
            if i + 1 < len(args):
                project = args[i + 1]
                i += 2
                continue
            err("--project requires a path argument")
            sys.exit(1)
        if a.startswith("--project="):
            project = a.split("=", 1)[1]
            i += 1
            continue
        out.append(a)
        i += 1
    return out, project


def main():
    global PROJECT_PATH
    raw_args = sys.argv[1:]
    args, PROJECT_PATH = parse_project_arg(raw_args)

    if not args:
        interactive_menu()
        return

    action = args[0].lower()
    target = args[1] if len(args) > 1 else ""

    if action == "status":
        show_status()
        return

    if action in ("install", "uninstall"):
        if not target:
            err(f"Specify target: {', '.join(CLI_ORDER)}, all")
            sys.exit(1)

        detect_clis()

        if target == "all":
            targets = list(CLI_ORDER)
        else:
            targets = [t.strip() for t in target.split(",")]

        joined = ", ".join(targets)
        print(f"\n  {_c('36', f'oh-my-universal — {action}ing into: {joined}')}")
        if PROJECT_PATH:
            info(f"Project mode: {PROJECT_PATH}")
        execute_action(action, targets)
        print(f"\n  {_c('32', 'Done!')}")
        return

    print(f"Usage: {sys.argv[0]} [install|uninstall|status] [target] [--project <path>]")
    print(f"Targets: {', '.join(CLI_ORDER)}, all")
    sys.exit(1)


if __name__ == "__main__":
    main()
