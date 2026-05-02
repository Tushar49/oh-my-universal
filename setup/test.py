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
OMU_ROOT = HERE.parent

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
MARKER_START = "# >>> oh-my-universal START >>>"
MARKER_END = "# <<< oh-my-universal END <<<"
test_router_patching()


# ── Test 8: regression test for the rogue-junction bug ──────────────────────
def test_junction_into_repo_refused():
    """Verify installer REFUSES when the install target resolves inside the repo
    (e.g., ~/.copilot/skills is a junction back into the repo). This is the bug
    that shipped — without this test, source-corruption could silently regress."""
    fake_home = Path(tempfile.mkdtemp(prefix="omu-junction-"))
    try:
        copilot_dir = fake_home / ".copilot"
        copilot_dir.mkdir(parents=True)

        # Create a junction (Windows) or symlink (Unix) from the would-be install
        # location back into the repo's .github/skills/.
        skills_link = copilot_dir / "skills"
        repo_skills = OMU_ROOT / ".github" / "skills"

        if platform.system() == "Windows":
            res = subprocess.run(
                ["cmd", "/c", "mklink", "/J", str(skills_link), str(repo_skills)],
                capture_output=True, text=True
            )
            if res.returncode != 0:
                skip(f"cannot create junction for test: {res.stderr.strip()[:120]}")
                return
        else:
            try:
                skills_link.symlink_to(repo_skills, target_is_directory=True)
            except OSError as e:
                skip(f"cannot create symlink for test: {e}")
                return

        # Snapshot a source file that would be corrupted if install proceeded.
        canary = repo_skills / "oh-my-universal" / "SKILL.md"
        if not canary.is_file():
            skip(f"canary file missing: {canary}")
            return
        before_bytes = canary.read_bytes()

        # Try to install with USERPROFILE/HOME pointing at the junction-poisoned home.
        env_bad = env.copy()
        if platform.system() == "Windows":
            env_bad["USERPROFILE"] = str(fake_home)
        else:
            env_bad["HOME"] = str(fake_home)

        res = subprocess.run(
            [sys.executable, str(PY), "install", "copilot"],
            capture_output=True, text=True, env=env_bad, timeout=60
        )
        combined = (res.stdout or "") + (res.stderr or "")

        # 1) The installer must NOT corrupt the canary in source.
        after_bytes = canary.read_bytes()
        if before_bytes != after_bytes:
            failed("install corrupted source file via rogue junction")
            return

        # 2) The installer must say it refused (return code may still be 0
        #    if it printed the refusal and continued past, but the message
        #    must be present so the user is informed).
        if "REFUSING to install" not in combined:
            failed("installer didn't print REFUSING message — silent skip is dangerous")
            return

        passed("installer refuses when ~/.copilot/skills is a junction into repo")
    finally:
        # Clean up junction first (so rmtree doesn't follow it into the repo)
        try:
            link = fake_home / ".copilot" / "skills"
            if link.exists() or link.is_symlink():
                if platform.system() == "Windows":
                    subprocess.run(["cmd", "/c", "rmdir", str(link)], capture_output=True)
                else:
                    link.unlink()
        except OSError:
            pass
        shutil.rmtree(fake_home, ignore_errors=True)


test_junction_into_repo_refused()


# ── Test 9: idempotence — install x2 + uninstall x2 ─────────────────────────
def test_per_project_idempotence():
    """install→install must produce identical state (no duplicate marker block).
    uninstall→uninstall must not delete the user file on second run."""
    proj = Path(tempfile.mkdtemp(prefix="omu-idem-"))
    try:
        target = proj / "AGENTS.md"
        target.write_text(ORIGINAL, encoding="utf-8")

        for _ in range(2):
            subprocess.run(
                [sys.executable, str(PY), "install", "codex", "--project", str(proj)],
                capture_output=True, text=True, env=env, timeout=30
            )
        after = target.read_text(encoding="utf-8")
        if after.count(MARKER_START) != 1:
            failed(f"install x2 produced {after.count(MARKER_START)} markers (expected 1)")
            return
        passed("install x2 keeps exactly one marker block")

        for _ in range(2):
            subprocess.run(
                [sys.executable, str(PY), "uninstall", "codex", "--project", str(proj)],
                capture_output=True, text=True, env=env, timeout=30
            )
        if not target.is_file():
            failed("uninstall x2 deleted the user file")
            return
        if target.read_text(encoding="utf-8").rstrip() != ORIGINAL.rstrip():
            failed("uninstall x2 altered user content")
            return
        passed("uninstall x2 leaves user content intact")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


# ── Test 10: per-project install on missing target file ──────────────────────
def test_per_project_creates_missing_file():
    """install into a project with no pre-existing AGENTS.md must create it."""
    proj = Path(tempfile.mkdtemp(prefix="omu-missing-"))
    try:
        target = proj / "AGENTS.md"
        if target.exists():
            target.unlink()
        res = subprocess.run(
            [sys.executable, str(PY), "install", "codex", "--project", str(proj)],
            capture_output=True, text=True, env=env, timeout=30
        )
        if not target.is_file():
            failed(f"install on missing AGENTS.md didn't create the file: {res.stderr.strip()[:120]}")
            return
        if MARKER_START not in target.read_text(encoding="utf-8"):
            failed("created file is missing the marker block")
            return
        passed("install creates AGENTS.md when missing")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


# ── Test 11: uninstall preserves user file that mentions oh-my-universal ────
def test_uninstall_preserves_user_mention():
    """If a user file mentions 'oh-my-universal' but has NO marker block,
    uninstall must leave it completely untouched."""
    proj = Path(tempfile.mkdtemp(prefix="omu-mention-"))
    try:
        target = proj / "AGENTS.md"
        user_content = (
            "# My Project\n\n"
            "I love oh-my-universal but never installed it via the script.\n"
            "These are my own notes about the oh-my-universal repo.\n"
        )
        target.write_text(user_content, encoding="utf-8")

        res = subprocess.run(
            [sys.executable, str(PY), "uninstall", "codex", "--project", str(proj)],
            capture_output=True, text=True, env=env, timeout=30
        )
        if not target.is_file():
            failed("uninstall deleted user file that just mentions 'oh-my-universal'")
            return
        if target.read_text(encoding="utf-8") != user_content:
            failed("uninstall altered user file with no marker block")
            return
        passed("uninstall preserves user file mentioning 'oh-my-universal'")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


# ── Test 12: refuse to operate on malformed marker ──────────────────────────
def test_malformed_marker_refused():
    """If a file has marker-start without marker-end, install/uninstall must
    refuse rather than silently dropping content after the start marker."""
    proj = Path(tempfile.mkdtemp(prefix="omu-malform-"))
    try:
        target = proj / "AGENTS.md"
        malformed = (
            "# My Project\n\n"
            f"{MARKER_START}\n"
            "# user accidentally deleted the end marker\n"
            "# but this content must be preserved\n"
        )
        target.write_text(malformed, encoding="utf-8")
        before = target.read_text(encoding="utf-8")

        for action in ("install", "uninstall"):
            res = subprocess.run(
                [sys.executable, str(PY), action, "codex", "--project", str(proj)],
                capture_output=True, text=True, env=env, timeout=30
            )
            after = target.read_text(encoding="utf-8")
            if after != before:
                failed(f"{action} on malformed marker MUTATED the file (data loss risk)")
                return
            combined = (res.stdout or "") + (res.stderr or "")
            if "Malformed marker" not in combined:
                failed(f"{action} on malformed marker didn't print warning")
                return
        passed("malformed marker file is preserved by both install and uninstall")
    finally:
        shutil.rmtree(proj, ignore_errors=True)


test_per_project_idempotence()
test_per_project_creates_missing_file()
test_uninstall_preserves_user_mention()
test_malformed_marker_refused()

# ── Summary ──────────────────────────────────────────────────────────────────
print()
print(f"  {_c('36', '─── Summary ───')}")
print(f"  {_c('32', f'PASS: {pass_count}')}")
print(f"  {_c('31' if fail_count else '2', f'FAIL: {fail_count}')}")
print()

sys.exit(1 if fail_count else 0)
