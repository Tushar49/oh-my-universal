#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# oh-my-universal Setup — Install/Uninstall skills into AI coding CLIs.
#
# Supports: Copilot (VS Code + CLI), Claude Code, Gemini CLI, Cursor,
#           Windsurf, Codex, OpenCode.
#
# Usage:
#   ./setup.sh                                        # Interactive menu
#   ./setup.sh install copilot                        # Direct install
#   ./setup.sh install all                            # Install into all detected CLIs
#   ./setup.sh uninstall copilot                      # Remove from Copilot
#   ./setup.sh status                                 # Show what's installed
#   ./setup.sh install gemini --project /path/to/p    # Per-project install
#   ./setup.sh uninstall codex --project /path/to/p   # Per-project uninstall
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# bash 4+ required (we use associative arrays via `declare -A`).
# macOS ships bash 3.2 by default — point users at Homebrew if so.
if [ -z "${BASH_VERSINFO[0]:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "ERROR: oh-my-universal setup requires bash 4 or newer." >&2
    echo "  Detected: bash ${BASH_VERSION:-unknown}" >&2
    if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
        echo "  macOS: brew install bash; then run via /usr/local/bin/bash or /opt/homebrew/bin/bash" >&2
    else
        echo "  Install bash >= 4.0 from your package manager." >&2
    fi
    exit 1
fi

# ── Constants ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMU_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$OMU_ROOT/skills" ]; then
    echo "ERROR: Cannot find oh-my-universal repo root at $OMU_ROOT"
    exit 1
fi

SKILLS_DIR="$OMU_ROOT/skills"
GH_SKILLS_DIR="$OMU_ROOT/.github/skills"
GH_INSTRUCT_DIR="$OMU_ROOT/.github/instructions"
GH_PROMPTS_DIR="$OMU_ROOT/.github/prompts"
CLAUDE_SKILLS_DIR="$OMU_ROOT/.claude/skills"
CURSOR_RULES_DIR="$OMU_ROOT/.cursor/rules"
WINDSURF_RULES="$OMU_ROOT/.windsurfrules"

# Sanity: refuse to operate if the repo path has shell-meaningful control characters.
# Our marker injections include this path verbatim — newlines/CR in the path
# could forge a fake marker boundary in user files. (Bash strings cannot contain
# null bytes, so no need to check for those.)
case "$OMU_ROOT" in
    *$'\n'*|*$'\r'*)
        echo "ERROR: Repo path contains control characters (newline/CR) — refusing to run." >&2
        echo "  Path: $OMU_ROOT" >&2
        exit 1
        ;;
esac

MARKER='# [oh-my-universal]'
MARKER_START='# >>> oh-my-universal START >>>'
MARKER_END='# <<< oh-my-universal END <<<'

HOME_DIR="${HOME:-$HOME}"

# Detect OS
case "$(uname -s)" in
    Darwin*) OS="macos" ;;
    Linux*)  OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    *)       OS="unknown" ;;
esac

# ── Colors ───────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    DIM='\033[2m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' CYAN='' DIM='' BOLD='' NC=''
fi

ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; }
skip() { echo -e "  ${DIM}[SKIP]${NC} $1"; }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "  ${RED}[FAIL]${NC} $1"; }
info() { echo -e "  ${CYAN}$1${NC}"; }

# ── Helpers ──────────────────────────────────────────────────────────────────

get_skill_description() {
    local file="$1"
    local desc
    desc=$(head -6 "$file" | grep -m1 '^>' | sed 's/^>\s*//')
    [ -z "$desc" ] && desc="oh-my-universal skill"
    echo "${desc:0:120}"
}

# VS Code prompts directory
find_vscode_prompts_dir() {
    local candidates=()
    case "$OS" in
        macos)
            candidates=(
                "$HOME_DIR/Library/Application Support/Code/User/prompts"
                "$HOME_DIR/Library/Application Support/Code - Insiders/User/prompts"
            )
            ;;
        linux)
            candidates=(
                "$HOME_DIR/.config/Code/User/prompts"
                "$HOME_DIR/.config/Code - Insiders/User/prompts"
            )
            ;;
    esac
    # Check VSCODE_PORTABLE first
    if [ -n "${VSCODE_PORTABLE:-}" ]; then
        local portable="$VSCODE_PORTABLE/user-data/User/prompts"
        if [ -d "$portable" ] || [ -d "$(dirname "$portable")" ]; then
            echo "$portable"
            return
        fi
    fi
    for d in "${candidates[@]}"; do
        if [ -d "$d" ] || [ -d "$(dirname "$d")" ]; then
            echo "$d"
            return
        fi
    done
    echo ""
}

VSCODE_PROMPTS_DIR="$(find_vscode_prompts_dir)"

# Project root (set by --project flag in main()) for per-project install/uninstall.
PROJECT_PATH=""

# ── Per-project marker section helpers ───────────────────────────────────────

get_omu_project_body() {
    cat <<EOF
# Skills available via oh-my-universal (read these files for full workflows):
#   Repo:   $OMU_ROOT
#   Skills: $SKILLS_DIR
#
# Common skills: plan, ultrawork, autopilot, verify, build-fix, tdd, ralph,
#                review, security-review, deep-dive, trace, ask, doctor,
#                release, doc-maintainer, refactor, team. (69 total.)
#
# To invoke: 'plan this refactoring', 'review my changes', 'ultrawork: <task>',
# 'fix the build', 'deep-dive into <bug>', etc.
EOF
}

# Append (or refresh) the oh-my-universal section in a shared file.
# Preserves any user content above and below the markers.
# Refuses to touch malformed files (start marker without end).
add_omu_marked_section() {
    local target_file="$1"
    local body
    body="$(get_omu_project_body)"

    local section
    section="$(printf '%s\n%s\n%s' "$MARKER_START" "$body" "$MARKER_END")"

    mkdir -p "$(dirname "$target_file")"

    if [ ! -f "$target_file" ]; then
        printf '%s\n' "$section" > "$target_file"
        return
    fi

    # Refuse if marker-start exists without marker-end (malformed).
    if grep -qF "$MARKER_START" "$target_file" && ! grep -qF "$MARKER_END" "$target_file"; then
        err "Malformed marker in $target_file: '$MARKER_START' without matching '$MARKER_END'."
        err "Refusing to modify — fix the file manually (close the marker block) and re-run."
        return 1
    fi

    if grep -qF "$MARKER_START" "$target_file"; then
        # Replace existing block via awk (preserves before/after content exactly)
        awk -v start="$MARKER_START" -v end="$MARKER_END" -v repl="$section" '
            BEGIN { in_block = 0; printed = 0 }
            $0 == start { in_block = 1; if (!printed) { print repl; printed = 1 } next }
            $0 == end { in_block = 0; next }
            !in_block { print }
        ' "$target_file" > "$target_file.omu.tmp" && mv "$target_file.omu.tmp" "$target_file"
    else
        # Append with a blank line separator
        local existing
        existing="$(cat "$target_file")"
        printf '%s\n\n%s\n' "$existing" "$section" > "$target_file"
    fi
}

# Remove only the oh-my-universal section, leaving everything else intact.
# Returns 0 if section was removed, 1 otherwise.
# Refuses to touch malformed files (start marker without end).
remove_omu_marked_section() {
    local target_file="$1"
    [ -f "$target_file" ] || return 1
    if ! grep -qF "$MARKER_START" "$target_file"; then
        return 1
    fi
    if ! grep -qF "$MARKER_END" "$target_file"; then
        err "Malformed marker in $target_file: '$MARKER_START' without matching '$MARKER_END'."
        err "Refusing to modify — fix the file manually and re-run uninstall."
        return 1
    fi
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        BEGIN { in_block = 0 }
        $0 == start { in_block = 1; next }
        $0 == end { in_block = 0; next }
        !in_block { print }
    ' "$target_file" > "$target_file.omu.tmp"

    # Trim trailing whitespace and ensure single trailing newline
    if [ -s "$target_file.omu.tmp" ]; then
        # Strip trailing blank lines, then re-add one final newline
        sed -e :a -e '/^$/{$d;N;ba' -e '}' "$target_file.omu.tmp" > "$target_file"
        rm -f "$target_file.omu.tmp"
    else
        # File became empty — remove it.
        rm -f "$target_file" "$target_file.omu.tmp"
    fi
    return 0
}

install_per_project() {
    local cli_key="$1" project_path="$2" file_name="$3"
    if [ ! -d "$project_path" ]; then
        err "Project path does not exist: $project_path"
        return 1
    fi
    local resolved
    resolved="$(cd "$project_path" && pwd)"
    local target="$resolved/$file_name"
    add_omu_marked_section "$target"
    ok "$cli_key ($file_name): marker section installed at $target"
}

uninstall_per_project() {
    local cli_key="$1" project_path="$2" file_name="$3"
    if [ ! -d "$project_path" ]; then
        err "Project path does not exist: $project_path"
        return 1
    fi
    local resolved
    resolved="$(cd "$project_path" && pwd)"
    local target="$resolved/$file_name"
    if [ ! -f "$target" ]; then
        skip "$cli_key ($file_name) not present at $target"
        return
    fi
    if remove_omu_marked_section "$target"; then
        ok "$cli_key ($file_name): marker section removed from $target"
    else
        skip "$cli_key ($file_name): no oh-my-universal section found — left untouched"
    fi
}

# ── Group-router patching ────────────────────────────────────────────────────
# A "group router" SKILL.md uses relative refs like `skills/team.md` to other skill
# files. When installed via symlink/junction, those relative refs can't resolve
# because the source dir has no co-located `skills/` subfolder. We patch the
# content to use absolute paths.

is_group_router() {
    local skill_file="$1"
    [ -f "$skill_file" ] || return 1
    grep -qE 'skills/[a-z-]+\.md' "$skill_file" 2>/dev/null
}

write_patched_router() {
    local source_skill="$1" target_skill="$2"
    local marker="<!-- $MARKER (installed copy with absolute paths to $SKILLS_DIR) -->"
    # 1) sed-replace relative skills/<name>.md with absolute path
    # 2) inject marker after frontmatter if present, else at top
    awk -v skills_dir="$SKILLS_DIR" -v marker="$marker" '
        BEGIN { in_fm = 0; fm_seen = 0; injected = 0 }
        NR == 1 && $0 == "---" { in_fm = 1; print; next }
        in_fm && $0 == "---" { in_fm = 0; fm_seen = 1; print; print marker; injected = 1; next }
        in_fm { print; next }
        {
            line = $0
            while (match(line, /skills\/[a-z-]+\.md/)) {
                name_part = substr(line, RSTART + 7, RLENGTH - 10)
                replacement = skills_dir "/" name_part ".md"
                line = substr(line, 1, RSTART - 1) replacement substr(line, RSTART + RLENGTH)
            }
            print line
        }
        END { if (!injected) print marker }
    ' "$source_skill" > "$target_skill"
}

install_group_dir() {
    # Install one group dir. Echoes one of: patched|junctioned|kept|failed
    local source_dir="$1" target="$2"

    if is_inside_repo "$target"; then
        err "REFUSING to install inside source repo: $target"
        echo "failed"
        return
    fi

    local source_skill="$source_dir/SKILL.md"

    if is_group_router "$source_skill"; then
        # Need a real dir — replace any existing symlink first.
        if [ -L "$target" ]; then
            rm "$target"
        fi
        mkdir -p "$target"
        local target_skill="$target/SKILL.md"
        # Idempotent: skip if already patched and pointing at current repo.
        if [ -f "$target_skill" ] \
            && grep -qF "$SKILLS_DIR" "$target_skill" \
            && ! grep -qE 'skills/[a-z-]+\.md' "$target_skill"; then
            echo "kept"
            return
        fi
        write_patched_router "$source_skill" "$target_skill"
        echo "patched"
        return
    fi

    if [ -e "$target" ]; then
        echo "kept"
        return
    fi
    if ln -s "$source_dir" "$target" 2>/dev/null; then
        echo "junctioned"
    else
        echo "failed"
    fi
}

# ── Detection ────────────────────────────────────────────────────────────────

declare -A CLI_AVAILABLE CLI_OMU_INSTALLED CLI_OMU_COUNT CLI_NAMES CLI_INSTALL_TYPE CLI_OMU_SUPPORTED
CLI_NAMES=(
    [copilot]="Copilot (VS Code + CLI)"
    [claude]="Claude Code"
    [gemini]="Gemini CLI"
    [cursor]="Cursor"
    [windsurf]="Windsurf"
    [codex]="OpenAI Codex"
    [opencode]="OpenCode"
)
CLI_INSTALL_TYPE=(
    [copilot]="global"
    [claude]="global"
    [gemini]="per-project"
    [cursor]="global"
    [windsurf]="per-project"
    [codex]="per-project"
    [opencode]="per-project"
)
CLI_ORDER="copilot claude gemini cursor windsurf codex opencode"

detect_omu_support() {
    # Detect which CLIs have adapter files in the repo
    CLI_OMU_SUPPORTED[copilot]=$(
        ( [ -f "$GH_INSTRUCT_DIR/skills.instructions.md" ] || [ -d "$GH_SKILLS_DIR" ] || [ -d "$GH_PROMPTS_DIR" ] ) && echo 1 || echo 0
    )
    CLI_OMU_SUPPORTED[claude]=$(
        ( [ -f "$OMU_ROOT/CLAUDE.md" ] || [ -d "$CLAUDE_SKILLS_DIR" ] ) && echo 1 || echo 0
    )
    CLI_OMU_SUPPORTED[gemini]=$( [ -f "$OMU_ROOT/GEMINI.md" ] && echo 1 || echo 0 )
    CLI_OMU_SUPPORTED[cursor]=$( [ -f "$CURSOR_RULES_DIR/skills.mdc" ] && echo 1 || echo 0 )
    CLI_OMU_SUPPORTED[windsurf]=$( [ -f "$WINDSURF_RULES" ] && echo 1 || echo 0 )
    CLI_OMU_SUPPORTED[codex]=$( [ -f "$OMU_ROOT/AGENTS.md" ] && echo 1 || echo 0 )
    CLI_OMU_SUPPORTED[opencode]=$( [ -f "$OMU_ROOT/AGENTS.md" ] && echo 1 || echo 0 )
}

count_omu_skills() {
    # Count SKILL.md files containing our marker under a directory.
    local dir="$1"
    [ -d "$dir" ] || { echo 0; return; }
    local count=0
    for d in "$dir"/*/; do
        [ -d "$d" ] || continue
        local sf="${d}SKILL.md"
        if [ -f "$sf" ] && grep -q 'oh-my-universal' "$sf" 2>/dev/null; then
            count=$((count + 1))
        fi
    done
    echo "$count"
}

detect_clis() {
    local copilot_dir="$HOME_DIR/.copilot"
    CLI_AVAILABLE[copilot]=$( [ -d "$copilot_dir" ] && echo 1 || echo 0 )
    local copilot_count
    copilot_count="$(count_omu_skills "$copilot_dir/skills")"
    CLI_OMU_COUNT[copilot]="$copilot_count"
    CLI_OMU_INSTALLED[copilot]=$( [ "$copilot_count" -gt 0 ] && echo 1 || echo 0 )

    CLI_AVAILABLE[claude]=$( command -v claude &>/dev/null && echo 1 || echo 0 )
    local claude_skills="$HOME_DIR/.claude/skills"
    local claude_count=0
    if [ -d "$claude_skills" ]; then
        for d in "$claude_skills"/*/; do
            [ -d "$d" ] || continue
            local trimmed="${d%/}"
            if [ -L "$trimmed" ]; then
                local lt
                lt="$(readlink "$trimmed")"
                if printf '%s' "$lt" | grep -q 'oh-my-universal'; then
                    claude_count=$((claude_count + 1))
                fi
            fi
        done
    fi
    CLI_OMU_COUNT[claude]="$claude_count"
    CLI_OMU_INSTALLED[claude]=$( [ "$claude_count" -gt 0 ] && echo 1 || echo 0 )

    CLI_AVAILABLE[gemini]=$( command -v gemini &>/dev/null && echo 1 || echo 0 )
    CLI_OMU_COUNT[gemini]=0
    CLI_OMU_INSTALLED[gemini]=0

    local cursor_dir="$HOME_DIR/.cursor"
    CLI_AVAILABLE[cursor]=$( [ -d "$cursor_dir" ] && echo 1 || echo 0 )
    local cursor_rules="$cursor_dir/rules/omu-skills.mdc"
    if [ -f "$cursor_rules" ] && grep -q 'oh-my-universal' "$cursor_rules" 2>/dev/null; then
        CLI_OMU_INSTALLED[cursor]=1
        CLI_OMU_COUNT[cursor]=1
    else
        CLI_OMU_INSTALLED[cursor]=0
        CLI_OMU_COUNT[cursor]=0
    fi

    CLI_AVAILABLE[windsurf]=$( command -v windsurf &>/dev/null && echo 1 || echo 0 )
    CLI_OMU_INSTALLED[windsurf]=0
    CLI_OMU_COUNT[windsurf]=0

    CLI_AVAILABLE[codex]=$( command -v codex &>/dev/null && echo 1 || echo 0 )
    CLI_OMU_INSTALLED[codex]=0
    CLI_OMU_COUNT[codex]=0

    CLI_AVAILABLE[opencode]=$( command -v opencode &>/dev/null && echo 1 || echo 0 )
    CLI_OMU_INSTALLED[opencode]=0
    CLI_OMU_COUNT[opencode]=0
}

# ── Install Functions ────────────────────────────────────────────────────────

is_inside_repo() {
    # Check whether $1 resolves (after following any junctions/symlinks anywhere
    # in the path) to a location inside $OMU_ROOT. Catches the case where a
    # parent like ~/.copilot/skills is a symlink pointing back into the repo.
    local path="$1"
    local resolved_root resolved
    resolved_root="$(cd "$OMU_ROOT" && pwd)"

    # If the path itself exists, follow links via cd+pwd.
    if [ -e "$path" ]; then
        resolved="$(cd "$path" 2>/dev/null && pwd)"
        if [ -n "$resolved" ]; then
            case "$resolved" in
                "$resolved_root"|"$resolved_root"/*) return 0 ;;
            esac
        fi
    fi

    # Walk up to the first existing ancestor and follow its links.
    local candidate="$path"
    while [ "$candidate" != "/" ] && [ -n "$candidate" ]; do
        local parent
        parent="$(dirname "$candidate")"
        if [ -e "$parent" ]; then
            local resolved_parent
            resolved_parent="$(cd "$parent" 2>/dev/null && pwd)"
            case "$resolved_parent" in
                "$resolved_root"|"$resolved_root"/*) return 0 ;;
            esac
            return 1
        fi
        candidate="$parent"
    done
    return 1
}

install_copilot() {
    echo -e "\n  ${BOLD}Installing into Copilot...${NC}"
    local copilot_dir="$HOME_DIR/.copilot"
    local skills_target="$copilot_dir/skills"
    local instr_target="$copilot_dir/instructions"

    # Safety: never install inside the source repo. Catches direct paths AND
    # paths that resolve into the repo via a parent symlink.
    if is_inside_repo "$skills_target"; then
        err "REFUSING to install: $skills_target resolves inside source repo $OMU_ROOT"
        err "Likely cause: ~/.copilot/skills (or a parent) is a symlink pointing into the repo."
        err "Fix: rm \"$skills_target\" — then re-run install."
        return 1
    fi

    mkdir -p "$skills_target" "$instr_target"

    # 1. Create individual skill wrappers
    local created=0 skipped=0
    for skill_file in "$SKILLS_DIR"/*.md; do
        local name
        name="$(basename "$skill_file" .md)"
        local target_dir="$skills_target/$name"
        local target_file="$target_dir/SKILL.md"

        if [ -f "$target_file" ]; then
            if grep -q 'oh-my-universal' "$target_file" 2>/dev/null; then
                ((skipped++)) || true
                continue
            fi
            warn "Skipping $name — SKILL.md exists but isn't ours"
            ((skipped++)) || true
            continue
        fi

        local desc
        desc="$(get_skill_description "$skill_file")"
        mkdir -p "$target_dir"

        cat > "$target_file" <<SKILLEOF
---
name: $name
description: "$desc"
---
$MARKER
# $name

Read and execute the full skill workflow from:

$skill_file

Use read_file to load the instructions from that absolute path, then follow them.
SKILLEOF
        ((created++)) || true
    done
    ok "Skills: $created created, $skipped already present"

    # 2. Symlink/install skill groups (patch routers, symlink the rest)
    local gjc=0 gjs=0 gjp=0
    if [ -d "$GH_SKILLS_DIR" ]; then
        for group_dir in "$GH_SKILLS_DIR"/*/; do
            [ -d "$group_dir" ] || continue
            local group_name
            group_name="$(basename "$group_dir")"
            local target="$skills_target/$group_name"
            local result
            result=$(install_group_dir "${group_dir%/}" "$target")
            case "$result" in
                junctioned) gjc=$((gjc + 1)) ;;
                patched)    gjp=$((gjp + 1)) ;;
                kept)       gjs=$((gjs + 1)) ;;
                *)          warn "Failed to link group: $group_name" ;;
            esac
        done
    fi
    ok "Skill groups: $gjc symlinked, $gjp routers patched, $gjs already present"

    # 3. Install instructions file
    local instr_src="$GH_INSTRUCT_DIR/skills.instructions.md"
    local instr_dst="$instr_target/oh-my-universal-skills.instructions.md"
    if [ -f "$instr_src" ]; then
        local content
        content="$(cat "$instr_src")"
        # Patch relative paths to absolute
        content="$(echo "$content" | sed "s|skills/\([a-z-]*\)\.md|$SKILLS_DIR/\1.md|g")"
        {
            echo "$MARKER_START"
            echo "$content"
            echo "$MARKER_END"
        } > "$instr_dst"
        ok "Instructions file installed"
    fi

    # 4. Install VS Code prompts
    if [ -n "$VSCODE_PROMPTS_DIR" ] && [ -d "$GH_PROMPTS_DIR" ]; then
        mkdir -p "$VSCODE_PROMPTS_DIR"
        local pc=0 ps=0
        for prompt_file in "$GH_PROMPTS_DIR"/*.prompt.md; do
            [ -f "$prompt_file" ] || continue
            local target="$VSCODE_PROMPTS_DIR/$(basename "$prompt_file")"
            if [ -e "$target" ]; then
                ((ps++)) || true
                continue
            fi
            # Symlink on unix (hardlinks don't work cross-filesystem)
            ln -s "$prompt_file" "$target" 2>/dev/null || cp "$prompt_file" "$target"
            ((pc++)) || true
        done
        ok "VS Code prompts: $pc installed, $ps already present"
    else
        skip "VS Code prompts folder not found"
    fi

    ok "Copilot installation complete"
}

install_claude() {
    echo -e "\n  ${BOLD}Installing into Claude Code...${NC}"
    local claude_skills="$HOME_DIR/.claude/skills"
    mkdir -p "$claude_skills"

    if [ -d "$CLAUDE_SKILLS_DIR" ]; then
        local gjc=0 gjs=0 gjp=0
        for group_dir in "$CLAUDE_SKILLS_DIR"/*/; do
            [ -d "$group_dir" ] || continue
            local name
            name="$(basename "$group_dir")"
            local target="$claude_skills/$name"
            local result
            result=$(install_group_dir "${group_dir%/}" "$target")
            case "$result" in
                junctioned) gjc=$((gjc + 1)) ;;
                patched)    gjp=$((gjp + 1)) ;;
                kept)       gjs=$((gjs + 1)) ;;
                *)          warn "Failed to link: $name" ;;
            esac
        done
        ok "Claude skill groups: $gjc symlinked, $gjp routers patched, $gjs already present"
    fi

    ok "Claude Code installation complete"
    info "Tip: Add to shell profile: alias claude='claude --plugin-dir \"$OMU_ROOT\"'"
}

install_gemini() {
    echo -e "\n  ${BOLD}Installing into Gemini CLI...${NC}"
    if [ -n "$PROJECT_PATH" ]; then
        install_per_project "gemini" "$PROJECT_PATH" "GEMINI.md"
        return
    fi
    warn "Gemini CLI has no global config — pass --project <path> to install per-project."
    info "Per-project options without this script:"
    info "  1. Shell alias:  alias gemini='gemini --plugin-dir \"$OMU_ROOT\"'"
    info "  2. Symlink:      ln -s \"$SKILLS_DIR\" .omu-skills"
    ok "Gemini guidance provided (no files modified)"
}

install_cursor() {
    echo -e "\n  ${BOLD}Installing into Cursor...${NC}"
    local rules_dir="$HOME_DIR/.cursor/rules"
    mkdir -p "$rules_dir"

    local src="$CURSOR_RULES_DIR/skills.mdc"
    local dst="$rules_dir/omu-skills.mdc"

    if [ -f "$dst" ]; then
        skip "Cursor rules file already installed"
    elif [ -f "$src" ]; then
        local content
        content="$(cat "$src")"
        content="$(echo "$content" | sed "s|skills/\([a-z-]*\)\.md|$SKILLS_DIR/\1.md|g")"
        {
            echo "$MARKER_START"
            echo "$content"
            echo "$MARKER_END"
        } > "$dst"
        ok "Cursor rules file installed"
    else
        err "Source cursor rules not found: $src"
    fi
    ok "Cursor installation complete"
}

install_windsurf() {
    echo -e "\n  ${BOLD}Installing into Windsurf...${NC}"
    if [ -n "$PROJECT_PATH" ]; then
        install_per_project "windsurf" "$PROJECT_PATH" ".windsurfrules"
        return
    fi
    warn "Windsurf reads .windsurfrules from project root only — pass --project <path>."
    info "Per-project options without this script:"
    info "  1. Symlink: ln -s \"$WINDSURF_RULES\" .windsurfrules"
    info "  2. Copy:    cp \"$WINDSURF_RULES\" .windsurfrules"
    ok "Windsurf guidance provided (no files modified)"
}

install_codex() {
    echo -e "\n  ${BOLD}Installing into Codex...${NC}"
    if [ -n "$PROJECT_PATH" ]; then
        install_per_project "codex" "$PROJECT_PATH" "AGENTS.md"
        return
    fi
    warn "Codex reads AGENTS.md from cwd only — pass --project <path> to install per-project."
    info "Per-project options without this script:"
    info "  1. Symlink: ln -s \"$SKILLS_DIR\" .omu-skills"
    info "  2. Add to AGENTS.md: 'Read skills from .omu-skills/{name}.md'"
    ok "Codex guidance provided (no files modified)"
}

install_opencode() {
    echo -e "\n  ${BOLD}Installing into OpenCode...${NC}"
    if [ -n "$PROJECT_PATH" ]; then
        install_per_project "opencode" "$PROJECT_PATH" "AGENTS.md"
        return
    fi
    warn "OpenCode reads AGENTS.md from cwd — pass --project <path> to install per-project."
    info "Same options as Codex above."
    ok "OpenCode guidance provided (no files modified)"
}

# ── Uninstall Functions ──────────────────────────────────────────────────────

uninstall_copilot() {
    echo -e "\n  ${BOLD}Uninstalling from Copilot...${NC}"
    local copilot_dir="$HOME_DIR/.copilot"
    local skills_target="$copilot_dir/skills"
    local instr_target="$copilot_dir/instructions"

    # 1. Remove individual skill wrappers
    local removed=0 kept=0
    for skill_file in "$SKILLS_DIR"/*.md; do
        local name
        name="$(basename "$skill_file" .md)"
        local target_dir="$skills_target/$name"
        local target_file="$target_dir/SKILL.md"

        [ -f "$target_file" ] || continue

        if grep -q 'oh-my-universal' "$target_file" 2>/dev/null; then
            rm -rf "$target_dir"
            ((removed++)) || true
        else
            ((kept++)) || true
        fi
    done
    ok "Skills removed: $removed (kept $kept non-omu skills)"

    # 2. Remove skill groups: symlinks pointing to our repo, OR patched-router copies (real dirs).
    local gjr=0 gpr=0
    if [ -d "$GH_SKILLS_DIR" ]; then
        for group_dir in "$GH_SKILLS_DIR"/*/; do
            [ -d "$group_dir" ] || continue
            local name
            name="$(basename "$group_dir")"
            local target="$skills_target/$name"
            [ -e "$target" ] || continue
            if [ -L "$target" ]; then
                local link_target
                link_target="$(readlink "$target")"
                if echo "$link_target" | grep -q 'oh-my-universal'; then
                    rm "$target"
                    gjr=$((gjr + 1))
                fi
                continue
            fi
            # Real dir: patched-router copy?
            local sf="$target/SKILL.md"
            if [ -f "$sf" ] && grep -qF "$MARKER" "$sf" 2>/dev/null; then
                # Only delete if dir contains ONLY SKILL.md (no user-added files).
                local file_count
                file_count=$(find "$target" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
                if [ "$file_count" = "1" ]; then
                    rm -rf "$target"
                    gpr=$((gpr + 1))
                else
                    warn "Group $name: contains user-added files — kept"
                fi
            fi
        done
    fi
    ok "Skill groups removed: $gjr symlinks, $gpr patched-router copies"

    # 3. Remove instructions file
    local instr_file="$instr_target/oh-my-universal-skills.instructions.md"
    if [ -f "$instr_file" ]; then
        if grep -q 'oh-my-universal' "$instr_file" 2>/dev/null; then
            rm "$instr_file"
            ok "Instructions file removed"
        else
            skip "Instructions file not ours — left untouched"
        fi
    else
        skip "No instructions file to remove"
    fi

    # 4. Remove VS Code prompts
    if [ -n "$VSCODE_PROMPTS_DIR" ] && [ -d "$GH_PROMPTS_DIR" ]; then
        local pr=0
        for prompt_file in "$GH_PROMPTS_DIR"/*.prompt.md; do
            [ -f "$prompt_file" ] || continue
            local target="$VSCODE_PROMPTS_DIR/$(basename "$prompt_file")"
            [ -e "$target" ] || continue

            if [ -L "$target" ]; then
                # It's a symlink — check target
                local lt
                lt="$(readlink "$target")"
                if echo "$lt" | grep -q 'oh-my-universal'; then
                    rm "$target"
                    ((pr++)) || true
                fi
            else
                # Regular file — hash compare
                local src_hash dst_hash
                if command -v shasum &>/dev/null; then
                    src_hash="$(shasum -a 256 "$prompt_file" | cut -d' ' -f1)"
                    dst_hash="$(shasum -a 256 "$target" | cut -d' ' -f1)"
                elif command -v sha256sum &>/dev/null; then
                    src_hash="$(sha256sum "$prompt_file" | cut -d' ' -f1)"
                    dst_hash="$(sha256sum "$target" | cut -d' ' -f1)"
                else
                    src_hash="$(md5sum "$prompt_file" | cut -d' ' -f1)"
                    dst_hash="$(md5sum "$target" | cut -d' ' -f1)"
                fi
                if [ "$src_hash" = "$dst_hash" ]; then
                    rm "$target"
                    ((pr++)) || true
                else
                    skip "Prompt '$(basename "$prompt_file")' modified by user — left untouched"
                fi
            fi
        done
        ok "VS Code prompts removed: $pr"
    fi

    ok "Copilot uninstall complete"
}

uninstall_claude() {
    echo -e "\n  ${BOLD}Uninstalling from Claude Code...${NC}"
    local claude_skills="$HOME_DIR/.claude/skills"
    local jr=0 pr=0

    if [ -d "$claude_skills" ]; then
        for d in "$claude_skills"/*/; do
            [ -d "$d" ] || continue
            local trimmed="${d%/}"
            if [ -L "$trimmed" ]; then
                local lt
                lt="$(readlink "$trimmed")"
                if echo "$lt" | grep -q 'oh-my-universal'; then
                    rm "$trimmed"
                    jr=$((jr + 1))
                fi
                continue
            fi
            local sf="$trimmed/SKILL.md"
            if [ -f "$sf" ] && grep -qF "$MARKER" "$sf" 2>/dev/null; then
                local file_count
                file_count=$(find "$trimmed" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
                if [ "$file_count" = "1" ]; then
                    rm -rf "$trimmed"
                    pr=$((pr + 1))
                else
                    warn "Claude group $(basename "$trimmed"): contains user-added files — kept"
                fi
            fi
        done
    fi
    ok "Claude skill groups removed: $jr symlinks, $pr patched-router copies"
    ok "Claude uninstall complete"
}

uninstall_cursor() {
    echo -e "\n  ${BOLD}Uninstalling from Cursor...${NC}"
    local rules_file="$HOME_DIR/.cursor/rules/omu-skills.mdc"
    if [ -f "$rules_file" ]; then
        if grep -q 'oh-my-universal' "$rules_file" 2>/dev/null; then
            rm "$rules_file"
            ok "Cursor rules file removed"
        else
            skip "Cursor rules file not ours — left untouched"
        fi
    else
        skip "No Cursor rules file to remove"
    fi
    ok "Cursor uninstall complete"
}

uninstall_gemini() {
    if [ -n "$PROJECT_PATH" ]; then
        uninstall_per_project "gemini" "$PROJECT_PATH" "GEMINI.md"
        return
    fi
    echo -e "\n  ${DIM}Gemini: nothing to uninstall globally. Use --project <path> to remove from a project.${NC}"
}
uninstall_windsurf() {
    if [ -n "$PROJECT_PATH" ]; then
        uninstall_per_project "windsurf" "$PROJECT_PATH" ".windsurfrules"
        return
    fi
    echo -e "\n  ${DIM}Windsurf: nothing to uninstall globally. Use --project <path> to remove from a project.${NC}"
}
uninstall_codex() {
    if [ -n "$PROJECT_PATH" ]; then
        uninstall_per_project "codex" "$PROJECT_PATH" "AGENTS.md"
        return
    fi
    echo -e "\n  ${DIM}Codex: nothing to uninstall globally. Use --project <path> to remove from a project.${NC}"
}
uninstall_opencode() {
    if [ -n "$PROJECT_PATH" ]; then
        uninstall_per_project "opencode" "$PROJECT_PATH" "AGENTS.md"
        return
    fi
    echo -e "\n  ${DIM}OpenCode: nothing to uninstall globally. Use --project <path> to remove from a project.${NC}"
}

# ── Status ───────────────────────────────────────────────────────────────────

show_status() {
    detect_clis
    detect_omu_support
    echo ""
    echo -e "  ${BOLD}oh-my-universal Status${NC}"
    echo "  ─────────────────────"
    echo "  Repo: $OMU_ROOT"
    echo "  Skills: $(ls "$SKILLS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')"
    echo "  OS: $OS"
    echo ""

    printf "  %-26s %-10s %-10s %-14s %-12s\n" "CLI" "Found" "Supported" "Installed" "Type"
    printf "  %-26s %-10s %-10s %-14s %-12s\n" "───" "─────" "─────────" "─────────" "────"

    for key in $CLI_ORDER; do
        local name="${CLI_NAMES[$key]}"
        local avail="No" support="No" omu="No" itype="${CLI_INSTALL_TYPE[$key]}"
        [ "${CLI_AVAILABLE[$key]}" = "1" ] && avail="Yes"
        [ "${CLI_OMU_SUPPORTED[$key]}" = "1" ] && support="Yes"
        if [ "$itype" = "per-project" ]; then
            omu="per-project"
        elif [ "${CLI_OMU_COUNT[$key]:-0}" -gt 0 ]; then
            omu="Yes (${CLI_OMU_COUNT[$key]})"
        fi
        printf "  %-26s %-10s %-10s %-14s %-12s\n" "$name" "$avail" "$support" "$omu" "$itype"
    done

    echo ""
    echo -e "  ${DIM}per-project = use --project <path> to install/uninstall in a specific project.${NC}"

    # Copilot detail
    local copilot_skills="$HOME_DIR/.copilot/skills"
    if [ -d "$copilot_skills" ]; then
        local omu_count=0 link_count=0
        for d in "$copilot_skills"/*/; do
            [ -d "$d" ] || continue
            if [ -f "${d}SKILL.md" ] && grep -q 'oh-my-universal' "${d}SKILL.md" 2>/dev/null; then
                ((omu_count++)) || true
            fi
            if [ -L "${d%/}" ]; then
                ((link_count++)) || true
            fi
        done
        echo ""
        echo -e "  ${DIM}Copilot detail:${NC}"
        echo -e "    ${CYAN}Skill wrappers: $omu_count${NC}"
        echo -e "    ${CYAN}Skill groups (symlinks): $link_count${NC}"

        local instr_file="$HOME_DIR/.copilot/instructions/oh-my-universal-skills.instructions.md"
        echo -e "    ${CYAN}Instructions file: $([ -f "$instr_file" ] && echo 'Installed' || echo 'Not found')${NC}"

        if [ -n "$VSCODE_PROMPTS_DIR" ] && [ -d "$VSCODE_PROMPTS_DIR" ] && [ -d "$GH_PROMPTS_DIR" ]; then
            local prompt_count=0
            for pf in "$GH_PROMPTS_DIR"/*.prompt.md; do
                [ -f "$pf" ] || continue
                local bn
                bn="$(basename "$pf")"
                [ -e "$VSCODE_PROMPTS_DIR/$bn" ] && ((prompt_count++)) || true
            done
            echo -e "    ${CYAN}VS Code prompts: $prompt_count${NC}"
        fi
    fi
    echo ""
}

# ── Execute Action ───────────────────────────────────────────────────────────

execute_action() {
    local action="$1"
    shift
    for target in "$@"; do
        case "$action" in
            install)
                case "$target" in
                    copilot)  install_copilot ;;
                    claude)   install_claude ;;
                    gemini)   install_gemini ;;
                    cursor)   install_cursor ;;
                    windsurf) install_windsurf ;;
                    codex)    install_codex ;;
                    opencode) install_opencode ;;
                    *) err "Unknown target: $target" ;;
                esac
                ;;
            uninstall)
                case "$target" in
                    copilot)  uninstall_copilot ;;
                    claude)   uninstall_claude ;;
                    gemini)   uninstall_gemini ;;
                    cursor)   uninstall_cursor ;;
                    windsurf) uninstall_windsurf ;;
                    codex)    uninstall_codex ;;
                    opencode) uninstall_opencode ;;
                    *) err "Unknown target: $target" ;;
                esac
                ;;
        esac
    done
}

# ── Interactive Menu ─────────────────────────────────────────────────────────

select_targets() {
    local action_label="$1"
    detect_clis
    echo ""
    echo -e "  ${BOLD}Select CLI targets to $action_label${NC}"
    echo "  ───────────────────────────────"
    echo ""

    local i=1
    declare -A target_map
    for key in $CLI_ORDER; do
        local name="${CLI_NAMES[$key]}"
        local status=""
        if [ "$action_label" = "install" ] && [ "${CLI_OMU_INSTALLED[$key]}" = "1" ]; then
            status=" (already installed)"
        fi
        if [ "$action_label" = "uninstall" ] && [ "${CLI_OMU_INSTALLED[$key]}" = "0" ]; then
            status=" (not installed)"
        fi
        local avail=""
        [ "${CLI_AVAILABLE[$key]}" = "0" ] && avail=" [not detected]"
        echo "  [$i] $name$avail$status"
        target_map[$i]="$key"
        ((i++)) || true
    done
    echo -e "  ${CYAN}[$i] All${NC}"
    target_map[$i]="all"
    echo -e "  ${DIM}[0] Cancel${NC}"
    echo ""

    read -rp "  Enter numbers (comma-separated, e.g. 1,2,4): " selection

    [ "$selection" = "0" ] || [ -z "$selection" ] && return

    local selected=()
    IFS=',' read -ra nums <<< "$selection"
    for num in "${nums[@]}"; do
        num="$(echo "$num" | tr -d ' ')"
        if [ "${target_map[$num]:-}" = "all" ]; then
            selected=($CLI_ORDER)
            break
        elif [ -n "${target_map[$num]:-}" ]; then
            selected+=("${target_map[$num]}")
        fi
    done

    if [ ${#selected[@]} -gt 0 ]; then
        echo "${selected[@]}"
    fi
}

interactive_menu() {
    while true; do
        clear 2>/dev/null || true
        echo ""
        echo -e "  ${CYAN}╔══════════════════════════════════════════╗${NC}"
        echo -e "  ${CYAN}║    oh-my-universal Setup                 ║${NC}"
        echo -e "  ${CYAN}║    69 skills · 19 hooks · 4 contracts    ║${NC}"
        echo -e "  ${CYAN}╚══════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${BOLD}[1]${NC} Install        — Install into selected CLIs"
        echo -e "  ${BOLD}[2]${NC} Uninstall      — Remove from selected CLIs"
        echo -e "  ${BOLD}[3]${NC} Status         — Show what's installed where"
        echo -e "  ${DIM}[4] Exit${NC}"
        echo ""

        read -rp "  Choose [1-4]: " choice

        case "$choice" in
            1)
                local targets
                targets="$(select_targets install)"
                if [ -n "$targets" ]; then
                    echo -e "\n  ${CYAN}Installing into: $targets${NC}"
                    execute_action install $targets
                    echo ""
                    read -rp "  Press Enter to continue..."
                fi
                ;;
            2)
                local targets
                targets="$(select_targets uninstall)"
                if [ -n "$targets" ]; then
                    echo ""
                    echo -e "  ${YELLOW}WARNING: This will remove oh-my-universal files ONLY.${NC}"
                    echo -e "  ${YELLOW}Your own skills, instructions, and configs will NOT be touched.${NC}"
                    read -rp "  Type 'yes' to confirm: " confirm
                    if [ "$confirm" = "yes" ]; then
                        execute_action uninstall $targets
                    else
                        echo "  Cancelled."
                    fi
                    echo ""
                    read -rp "  Press Enter to continue..."
                fi
                ;;
            3)
                show_status
                read -rp "  Press Enter to continue..."
                ;;
            4|q|Q)
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid choice.${NC}"
                ;;
        esac
    done
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    # Strip --project <path> / --project=<path> from args
    local positional=()
    while [ $# -gt 0 ]; do
        case "$1" in
            --project)
                if [ $# -lt 2 ]; then
                    err "--project requires a path argument"
                    exit 1
                fi
                PROJECT_PATH="$2"
                shift 2
                ;;
            --project=*)
                PROJECT_PATH="${1#--project=}"
                shift
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    local action="${1:-}"
    local target="${2:-}"

    if [ -z "$action" ]; then
        interactive_menu
        return
    fi

    detect_clis

    case "$action" in
        status)
            show_status
            ;;
        install|uninstall)
            if [ -z "$target" ]; then
                err "Specify target: copilot, claude, gemini, cursor, windsurf, codex, opencode, all"
                exit 1
            fi
            local targets
            if [ "$target" = "all" ]; then
                targets="$CLI_ORDER"
            else
                targets="$(echo "$target" | tr ',' ' ')"
            fi
            echo -e "\n  ${CYAN}oh-my-universal — ${action}ing into: $targets${NC}"
            [ -n "$PROJECT_PATH" ] && info "Project mode: $PROJECT_PATH"
            execute_action "$action" $targets
            echo -e "\n  ${GREEN}Done!${NC}"
            ;;
        *)
            echo "Usage: $0 [install|uninstall|status] [target] [--project <path>]"
            echo "Targets: copilot, claude, gemini, cursor, windsurf, codex, opencode, all"
            exit 1
            ;;
    esac
}

main "$@"
