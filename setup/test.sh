#!/usr/bin/env bash
# Smoke tests for the oh-my-universal setup scripts (POSIX shell).
# Verifies parse + status + per-project safety.
# Exit code 0 = pass; non-zero = something failed.

set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS1_FILE="$HERE/setup.ps1"
SH_FILE="$HERE/setup.sh"
PY_FILE="$HERE/setup.py"

PASS=0
FAIL=0
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
DIM=$'\033[2m'
NC=$'\033[0m'

pass() { printf "  %s[PASS]%s %s\n" "$GREEN" "$NC" "$1"; PASS=$((PASS+1)); }
fail() { printf "  %s[FAIL]%s %s\n" "$RED" "$NC" "$1"; FAIL=$((FAIL+1)); }
skip() { printf "  %s[SKIP] %s%s\n" "$DIM" "$1" "$NC"; }

echo
printf "  %soh-my-universal setup -- smoke tests%s\n" "$CYAN" "$NC"
echo "  ------------------------------------"

# Test 1: scripts exist
for f in "$PS1_FILE" "$SH_FILE" "$PY_FILE"; do
    if [ -f "$f" ]; then pass "exists: $(basename "$f")"
    else                 fail "missing: $f"
    fi
done

# Test 2: bash parses setup.sh
if bash -n "$SH_FILE" 2>/dev/null; then
    pass "setup.sh parses (bash -n)"
else
    fail "setup.sh syntax error"
fi

# Test 3: python parses setup.py
PY=""
if command -v python3 >/dev/null 2>&1; then PY=python3
elif command -v python >/dev/null 2>&1; then PY=python
fi
if [ -n "$PY" ]; then
    if "$PY" -c "import ast; ast.parse(open('$PY_FILE', encoding='utf-8').read())" 2>/dev/null; then
        pass "setup.py parses"
    else
        fail "setup.py syntax error"
    fi
else
    skip "python not installed"
fi

# Test 4: pwsh parses setup.ps1 (if present)
if command -v pwsh >/dev/null 2>&1; then
    if pwsh -NoProfile -Command "[scriptblock]::Create((Get-Content -Raw '$PS1_FILE')) | Out-Null" 2>/dev/null; then
        pass "setup.ps1 parses in pwsh"
    else
        fail "setup.ps1 fails to parse in pwsh"
    fi
else
    skip "pwsh not installed"
fi

# Test 5: status mode runs
out=$(bash "$SH_FILE" status 2>&1)
if echo "$out" | grep -q 'oh-my-universal Status'; then
    pass "setup.sh status runs cleanly"
else
    fail "setup.sh status failed"
fi
if [ -n "$PY" ]; then
    out=$(PYTHONIOENCODING=utf-8 "$PY" "$PY_FILE" status 2>&1)
    if echo "$out" | grep -q 'oh-my-universal Status'; then
        pass "setup.py status runs cleanly"
    else
        fail "setup.py status failed"
    fi
fi

# Test 6: per-project install/uninstall preserves user content
test_per_project() {
    local script="$1" tool="$2" file="$3" runner="$4"

    local proj
    proj=$(mktemp -d)
    local original
    original="# My Project

User content here.

## Section
- item one
"
    printf '%s' "$original" > "$proj/$file"

    eval "$runner '$script' install '$tool' --project '$proj'" >/dev/null 2>&1
    if grep -q 'oh-my-universal START' "$proj/$file" && grep -q 'User content here' "$proj/$file"; then
        pass "$(basename "$script") install $tool preserves user content"
    else
        fail "$(basename "$script") install $tool failed"
        rm -rf "$proj"
        return
    fi

    eval "$runner '$script' uninstall '$tool' --project '$proj'" >/dev/null 2>&1
    if [ ! -f "$proj/$file" ]; then
        fail "$(basename "$script") uninstall $tool deleted the user file"
        rm -rf "$proj"
        return
    fi
    local restored before
    restored=$(cat "$proj/$file" | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}')
    before=$(printf '%s' "$original" | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}')
    if [ "$restored" = "$before" ]; then
        pass "$(basename "$script") uninstall $tool restores user content"
    else
        fail "$(basename "$script") uninstall $tool altered user content"
    fi
    rm -rf "$proj"
}

test_per_project "$SH_FILE" codex    AGENTS.md      bash
test_per_project "$SH_FILE" gemini   GEMINI.md      bash
test_per_project "$SH_FILE" windsurf .windsurfrules bash
test_per_project "$SH_FILE" opencode AGENTS.md      bash

if [ -n "$PY" ]; then
    test_per_project "$PY_FILE" codex  AGENTS.md "PYTHONIOENCODING=utf-8 $PY"
    test_per_project "$PY_FILE" gemini GEMINI.md "PYTHONIOENCODING=utf-8 $PY"
fi

# Summary
echo
printf "  %s--- Summary ---%s\n" "$CYAN" "$NC"
printf "  %sPASS:%s %d\n" "$GREEN" "$NC" "$PASS"
if [ "$FAIL" -gt 0 ]; then
    printf "  %sFAIL:%s %d\n" "$RED" "$NC" "$FAIL"
    exit 1
fi
printf "  %sFAIL:%s 0\n" "$DIM" "$NC"
echo
exit 0