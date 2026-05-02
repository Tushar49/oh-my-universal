#!/usr/bin/env python3
"""Smoke tests for the oh-my-universal setup scripts (cross-platform).

Verifies that all three installers parse and that per-project install/uninstall
preserves user content exactly. Returns exit code 0 on success.
"""

import ast
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

if sys.version_info < (3, 9):
    print(f"This test requires Python 3.9+ (found {sys.version_info.major}.{sys.version_info.minor})")
    sys.exit(1)

# Ensure UTF-8 stdout for box-drawing chars
for s in (sys.stdout, sys.stderr):
    if hasattr(s, "reconfigure"):
        try:
            s.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass

HERE = Path(__file__).resolve().parent
PS1 = HERE / "setup.ps1"
SH = HERE / "setup.sh"
PY = HERE / "setup.py"

USE_COLOR = sys.stdout.isatty()


def _c(code: str, txt: str) -> str:
    return f"\033[{code}m{txt}\033[0m" if USE_COLOR else txt


pass_count = 0
fail_count = 0


def passed(msg: str):
    global pass_count
    print(f"  {_c('32', '[PASS]')} {msg}")
    pass_count += 1


def failed(msg: str):
    global fail_count
    print(f"  {_c('31', '[FAIL]')} {msg}")
    fail_count += 1


def skip(msg: str):
    print(f"  {_c('2', '[SKIP] ' + msg)}")


print()
print(f"  {_c('36', 'oh-my-universal setup — smoke tests')}")
print("  -----------------------------------")

# ── Test 1: all three scripts exist ──────────────────────────────────────────
for p in (PS1, SH, PY):
    if p.is_file():
        passed(f"exists: {p.name}")
    else:
        failed(f"missing: {p}")

# ── Test 2: setup.py parses ──────────────────────────────────────────────────
try:
    ast.parse(PY.read_text(encoding="utf-8"))
    passed("setup.py parses")
except SyntaxError as e:
    failed(f"setup.py syntax error: {e}")

def _bash_path(p: Path) -> str:
    """Convert path for bash; on Windows, route through wslpath. Defensive against WSL errors."""
    if platform.system() != "Windows":
        return str(p)
    try:
        result = subprocess.run(
            ["bash", "-c", f"wslpath -a '{p}'"],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            return str(p)
        out = result.stdout.replace("\x00", "").strip()
        # WSL sometimes emits "Catastrophic failure" or similar diagnostics on stdout.
        # A valid WSL path starts with /mnt/ or /.
        if out and (out.startswith("/mnt/") or out.startswith("/")):
            return out
        return str(p)
    except (OSError, subprocess.TimeoutExpired, ValueError):
        return str(p)


# ── Test 3: bash parses setup.sh (if bash is available) ──────────────────────
if shutil.which("bash"):
    res = subprocess.run(
        ["bash", "-n", _bash_path(SH)], capture_output=True, text=True
    )
    if res.returncode == 0:
        passed("setup.sh parses (bash -n)")
    else:
        failed(f"setup.sh syntax error: {res.stderr.strip()}")
else:
    skip("bash not installed — skipping sh parse check")

# ── Test 4: PowerShell parses setup.ps1 (if available) ───────────────────────
ps_exe = shutil.which("pwsh") or shutil.which("powershell")
if ps_exe:
    cmd = [
        ps_exe, "-NoProfile", "-Command",
        f"[scriptblock]::Create((Get-Content -Raw '{PS1}')) | Out-Null"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        passed(f"setup.ps1 parses ({Path(ps_exe).name})")
    else:
        failed(f"setup.ps1 fails to parse in {Path(ps_exe).name}")
else:
    skip("powershell/pwsh not installed — skipping ps1 parse check")

# ── Test 5: status mode runs cleanly ─────────────────────────────────────────
env = os.environ.copy()
env["PYTHONIOENCODING"] = "utf-8"

res = subprocess.run([sys.executable, str(PY), "status"], capture_output=True, text=True, env=env)
if res.returncode == 0 and "oh-my-universal Status" in res.stdout:
    passed("setup.py status runs cleanly")
else:
    failed(f"setup.py status failed: {res.stderr.strip()[:200]}")

if shutil.which("bash"):
    res = subprocess.run(["bash", _bash_path(SH), "status"], capture_output=True, text=True)
    if res.returncode == 0 and "oh-my-universal Status" in res.stdout:
        passed("setup.sh status runs cleanly")
    else:
        failed(f"setup.sh status failed")

if ps_exe:
    res = subprocess.run(
        [ps_exe, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(PS1), "-Action", "status"],
        capture_output=True, text=True
    )
    if res.returncode == 0 and "oh-my-universal Status" in res.stdout:
        passed(f"setup.ps1 status runs cleanly ({Path(ps_exe).name})")
    else:
        failed(f"setup.ps1 status failed")


# ── Test 6: per-project install/uninstall preserves user content ─────────────
ORIGINAL = "# My Project\n\nUser content here.\n"


def test_per_project_py(tool: str, file_name: str):
    proj = Path(tempfile.mkdtemp(prefix="omu-smoke-"))
    try:
        target = proj / file_name
        target.write_text(ORIGINAL, encoding="utf-8")

        # install
        res = subprocess.run(
            [sys.executable, str(PY), "install", tool, "--project", str(proj)],
            capture_output=True, text=True, env=env
        )
        if res.returncode != 0:
            failed(f"setup.py install {tool} failed: {res.stderr.strip()[:200]}")
            return
        after = target.read_text(encoding="utf-8")
        if "oh-my-universal START" in after and "User content here" in after:
            passed(f"setup.py per-project install ({tool}) preserves user content")
        else:
            failed(f"setup.py per-project install ({tool}) didn't add marker or lost content")
            return

        # uninstall
        res = subprocess.run(
            [sys.executable, str(PY), "uninstall", tool, "--project", str(proj)],
            capture_output=True, text=True, env=env
        )
        if not target.is_file():
            failed(f"setup.py per-project uninstall ({tool}) deleted the user file")
            return
        restored = target.read_text(encoding="utf-8").rstrip()
        if restored == ORIGINAL.rstrip():
            passed(f"setup.py per-project uninstall ({tool}) restores user content")
        else:
            failed(f"setup.py per-project uninstall ({tool}) altered user content")
            print(f"    BEFORE: {ORIGINAL!r}")
            print(f"    AFTER:  {restored!r}")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


def test_per_project_sh(tool: str, file_name: str):
    if not shutil.which("bash"):
        return
    proj = Path(tempfile.mkdtemp(prefix="omu-smoke-"))
    try:
        target = proj / file_name
        target.write_text(ORIGINAL, encoding="utf-8")
        # On Windows + WSL, mktemp via subprocess gives Windows path; use it directly.
        proj_arg = str(proj)
        # If bash is WSL, convert path
        if platform.system() == "Windows":
            try:
                wpath = subprocess.run(
                    ["bash", "-c", f"wslpath -a '{proj_arg}'"],
                    capture_output=True, text=True
                ).stdout.strip()
                if wpath:
                    proj_arg = wpath
            except Exception:
                pass
            sh_arg = subprocess.run(
                ["bash", "-c", f"wslpath -a '{SH}'"],
                capture_output=True, text=True
            ).stdout.strip() or str(SH)
        else:
            sh_arg = str(SH)

        res = subprocess.run(
            ["bash", sh_arg, "install", tool, "--project", proj_arg],
            capture_output=True, text=True
        )
        if res.returncode != 0:
            failed(f"setup.sh install {tool} failed: {res.stderr.strip()[:200]}")
            return
        after = target.read_text(encoding="utf-8")
        if "oh-my-universal START" in after and "User content here" in after:
            passed(f"setup.sh per-project install ({tool}) preserves user content")
        else:
            failed(f"setup.sh per-project install ({tool}) didn't add marker or lost content")
            return

        res = subprocess.run(
            ["bash", sh_arg, "uninstall", tool, "--project", proj_arg],
            capture_output=True, text=True
        )
        if not target.is_file():
            failed(f"setup.sh per-project uninstall ({tool}) deleted the user file")
            return
        restored = target.read_text(encoding="utf-8").rstrip()
        if restored == ORIGINAL.rstrip():
            passed(f"setup.sh per-project uninstall ({tool}) restores user content")
        else:
            failed(f"setup.sh per-project uninstall ({tool}) altered user content")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


# Run per-project tests against setup.py
test_per_project_py("codex", "AGENTS.md")
test_per_project_py("gemini", "GEMINI.md")
test_per_project_py("windsurf", ".windsurfrules")
test_per_project_py("opencode", "AGENTS.md")

# And against setup.sh if bash exists
test_per_project_sh("codex", "AGENTS.md")
test_per_project_sh("gemini", "GEMINI.md")


# ── Test 7: group-router patching (the bug from session 2) ───────────────────
def test_router_patching():
    """After install, every group router SKILL.md must point to absolute paths
    that actually exist — not relative `skills/<name>.md` refs that don't
    resolve."""
    # Run install into a fake HOME so we don't disturb the user's real install.
    fake_home = Path(tempfile.mkdtemp(prefix="omu-fakehome-"))
    try:
        env_with_home = env.copy()
        if platform.system() == "Windows":
            env_with_home["USERPROFILE"] = str(fake_home)
        else:
            env_with_home["HOME"] = str(fake_home)

        res = subprocess.run(
            [sys.executable, str(PY), "install", "copilot"],
            capture_output=True, text=True, env=env_with_home, timeout=60
        )
        if res.returncode != 0:
            failed(f"install copilot into fake HOME failed: {res.stderr.strip()[:200]}")
            return

        skills_dir = fake_home / ".copilot" / "skills"
        # Find every group-router SKILL.md (they have a `<!-- # [oh-my-universal] (installed copy` marker).
        bad_routers = []
        bad_refs = []
        for d in skills_dir.iterdir():
            if not d.is_dir():
                continue
            sf = d / "SKILL.md"
            if not sf.is_file():
                continue
            content = sf.read_text(encoding="utf-8", errors="ignore")
            if "(installed copy with absolute paths" not in content:
                continue
            # This is a router. Verify it has NO relative `skills/<name>.md` refs.
            if re.search(r"\bskills/[a-z-]+\.md\b", content):
                bad_routers.append(d.name)
                continue
            # And every absolute ref must point at a real file.
            for m in re.finditer(r"`([A-Z]:[\\/][^`]+\.md)`", content):
                if not Path(m.group(1)).is_file():
                    bad_refs.append(f"{d.name} -> {m.group(1)}")

        if bad_routers:
            failed(f"router still has relative refs: {bad_routers}")
            return
        if bad_refs:
            failed(f"router refs don't resolve: {bad_refs[:3]}")
            return
        passed("group routers patched to absolute paths and all refs resolve")

        # Now uninstall and verify routers are removed cleanly.
        res = subprocess.run(
            [sys.executable, str(PY), "uninstall", "copilot"],
            capture_output=True, text=True, env=env_with_home, timeout=60
        )
        if res.returncode != 0:
            failed(f"uninstall copilot failed: {res.stderr.strip()[:200]}")
            return
        leftover = []
        if skills_dir.exists():
            for d in skills_dir.iterdir():
                if d.is_dir() and (d / "SKILL.md").is_file():
                    c = (d / "SKILL.md").read_text(encoding="utf-8", errors="ignore")
                    if "oh-my-universal" in c or MARKER in c:
                        leftover.append(d.name)
        if leftover:
            failed(f"uninstall left oh-my-universal artifacts behind: {leftover}")
        else:
            passed("uninstall removed all routers and wrappers cleanly")
    finally:
        shutil.rmtree(fake_home, ignore_errors=True)


# Need MARKER from setup.py for the above check.
MARKER = "# [oh-my-universal]"
test_router_patching()

# ── Summary ──────────────────────────────────────────────────────────────────
print()
print(f"  {_c('36', '─── Summary ───')}")
print(f"  {_c('32', f'PASS: {pass_count}')}")
print(f"  {_c('31' if fail_count else '2', f'FAIL: {fail_count}')}")
print()

sys.exit(1 if fail_count else 0)
