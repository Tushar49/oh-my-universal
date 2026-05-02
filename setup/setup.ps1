<#
.SYNOPSIS
    oh-my-universal Setup — Install/Uninstall skills into AI coding CLIs.

.DESCRIPTION
    Interactive installer for oh-my-universal skills across supported CLIs.
    Supports: Copilot (VS Code + CLI), Claude Code, Gemini CLI, Cursor, Windsurf, Codex, OpenCode.

    - Install: Creates wrapper SKILL.md files, junctions, hardlinks/copies.
    - Uninstall: Surgically removes ONLY oh-my-universal content. Never deletes user content.
    - Status: Detects where oh-my-universal is currently installed.
    - Project mode: Use -Project <path> to install/uninstall per-project (Gemini, Codex, OpenCode, Windsurf).

.PARAMETER Action
    install | uninstall | status (default: interactive menu)

.PARAMETER Target
    Comma-separated CLI names: copilot, claude, gemini, cursor, windsurf, codex, opencode, all

.PARAMETER Project
    Project root directory for per-project installs (Gemini, Codex, OpenCode, Windsurf).
    Adds a marker-bracketed section to AGENTS.md / GEMINI.md / .windsurfrules.

.EXAMPLE
    # Interactive menu
    .\setup.ps1

    # Direct install into Copilot
    .\setup.ps1 -Action install -Target copilot

    # Uninstall from everywhere
    .\setup.ps1 -Action uninstall -Target all

    # Check what's installed
    .\setup.ps1 -Action status

    # Install Gemini skills into a specific project
    .\setup.ps1 -Action install -Target gemini -Project C:\code\my-app
#>

[CmdletBinding()]
param(
    [ValidateSet('install', 'uninstall', 'status', '')]
    [string]$Action = '',

    [string]$Target = '',

    [string]$Project = ''
)

# ── Constants ──────────────────────────────────────────────────────────────────
$ErrorActionPreference = 'Stop'
# Script lives in setup/ — repo root is one level up
$OmuRoot = Split-Path $PSScriptRoot
if (-not (Test-Path (Join-Path $OmuRoot 'skills'))) {
    # Fallback: try script's own directory (if someone copies it to repo root)
    if (Test-Path (Join-Path $PSScriptRoot 'skills')) { $OmuRoot = $PSScriptRoot }
    else { Write-Error "Cannot find oh-my-universal repo root. Run from setup/ directory."; exit 1 }
}

$SkillsDir       = Join-Path $OmuRoot 'skills'
$GhSkillsDir     = Join-Path $OmuRoot '.github\skills'
$GhInstructDir   = Join-Path $OmuRoot '.github\instructions'
$GhPromptsDir    = Join-Path $OmuRoot '.github\prompts'
$ClaudeSkillsDir = Join-Path $OmuRoot '.claude\skills'
$CursorRulesDir  = Join-Path $OmuRoot '.cursor\rules'
$WindsurfRules   = Join-Path $OmuRoot '.windsurfrules'

# Sanity: refuse to operate if the repo path has shell-meaningful control characters.
# Our marker injections include this path verbatim — newlines / carriage returns
# in the path could forge a fake marker boundary in user files.
if ($OmuRoot -match "[`r`n`0]") {
    Write-Error "Repo path contains control characters (newline/CR/null) — refusing to run. Path: $OmuRoot"
    exit 1
}

# Marker used to identify our content in shared files
$Marker = '# [oh-my-universal]'
$MarkerStart = '# >>> oh-my-universal START >>>'
$MarkerEnd   = '# <<< oh-my-universal END <<<'

# Detect VS Code portable or standard paths
$VscodePromptsDir = $null
if ($env:VSCODE_PORTABLE) {
    $VscodePromptsDir = Join-Path $env:VSCODE_PORTABLE 'user-data\User\prompts'
} else {
    $candidate = Join-Path $env:APPDATA 'Code\User\prompts'
    if (Test-Path $candidate) { $VscodePromptsDir = $candidate }
}

# ── Helpers ────────────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Write-OK   { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip { param($msg) Write-Host "  [SKIP] $msg" -ForegroundColor DarkGray }
function Write-Warn { param($msg) Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "  $msg" -ForegroundColor Cyan }

function Get-SkillNames {
    (Get-ChildItem "$SkillsDir\*.md" -ErrorAction SilentlyContinue).BaseName | Sort-Object
}

function Get-SkillDescription {
    param([string]$SkillFile)
    $lines = Get-Content $SkillFile -TotalCount 6 -ErrorAction SilentlyContinue
    $desc = ($lines | Where-Object { $_ -match '^\>' } | Select-Object -First 1) -replace '^\>\s*', ''
    if (-not $desc) { $desc = "oh-my-universal skill" }
    if ($desc.Length -gt 120) { $desc = $desc.Substring(0, 117) + '...' }
    return $desc
}

function New-Junction {
    param([string]$Target, [string]$Source)
    cmd /c "mklink /J `"$Target`" `"$Source`"" 2>&1 | Out-Null
    return $LASTEXITCODE -eq 0
}

function New-Hardlink {
    param([string]$Target, [string]$Source)
    cmd /c "mklink /H `"$Target`" `"$Source`" 2>nul" 2>&1 | Out-Null
    return $LASTEXITCODE -eq 0
}

function Add-OmuMarkedSection {
    # Append (or update) the oh-my-universal section in a shared file.
    # Preserves any user content above and below the markers.
    # Refuses to touch malformed files (start marker without end) — silent
    # data loss is worse than a clear error message.
    param([string]$Path, [string]$Body)
    $existing = ''
    if (Test-Path $Path) { $existing = Get-Content $Path -Raw }
    $section = "$MarkerStart`n$Body`n$MarkerEnd"
    if ($existing -match [regex]::Escape($MarkerStart)) {
        # Replace existing block. Use index-based splice to avoid regex backref escaping.
        $startIdx = $existing.IndexOf($MarkerStart)
        $endIdx = $existing.IndexOf($MarkerEnd, $startIdx)
        if ($endIdx -lt 0) {
            Write-Err "Malformed marker in ${Path}: '$MarkerStart' without matching '$MarkerEnd'."
            Write-Err "Refusing to modify — fix the file manually (close the marker block) and re-run."
            return
        }
        $endOfBlock = $endIdx + $MarkerEnd.Length
        $before = $existing.Substring(0, $startIdx).TrimEnd()
        $after = $existing.Substring($endOfBlock).TrimStart("`r","`n")
        $newContent = if ($before) { "$before`n`n$section" } else { $section }
        if ($after) { $newContent = "$newContent`n`n$after" }
        $newContent = $newContent.TrimEnd() + "`n"
    } elseif ($existing.Trim()) {
        $newContent = $existing.TrimEnd() + "`n`n" + $section + "`n"
    } else {
        $newContent = $section + "`n"
    }
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $Path -Value $newContent -NoNewline -Encoding UTF8
}

function Remove-OmuMarkedSection {
    # Remove only the oh-my-universal section, leaving everything else intact.
    # Returns $true if a section was removed, $false otherwise.
    # Refuses to touch malformed files (start marker without end).
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    $content = Get-Content $Path -Raw
    $startIdx = $content.IndexOf($MarkerStart)
    if ($startIdx -lt 0) { return $false }
    $endIdx = $content.IndexOf($MarkerEnd, $startIdx)
    if ($endIdx -lt 0) {
        Write-Err "Malformed marker in ${Path}: '$MarkerStart' without matching '$MarkerEnd'."
        Write-Err "Refusing to modify — fix the file manually and re-run uninstall."
        return $false
    }
    $endOfBlock = $endIdx + $MarkerEnd.Length
    $before = $content.Substring(0, $startIdx).TrimEnd()
    $after = $content.Substring($endOfBlock).TrimStart("`r","`n")
    $newContent = if ($before -and $after) { "$before`n`n$after`n" }
                  elseif ($before)         { "$before`n" }
                  elseif ($after)          { "$after`n" }
                  else                     { '' }
    if ($newContent.Trim() -eq '') {
        # File only contained our section — remove it entirely.
        Remove-Item $Path -Force
    } else {
        Set-Content -Path $Path -Value $newContent -NoNewline -Encoding UTF8
    }
    return $true
}

function Get-OmuProjectBody {
    # Body content injected into per-project shared files.
    return @"
# Skills available via oh-my-universal (read these files for full workflows):
#   Repo:   $OmuRoot
#   Skills: $SkillsDir
#
# Common skills: plan, ultrawork, autopilot, verify, build-fix, tdd, ralph,
#                review, security-review, deep-dive, trace, ask, doctor,
#                release, doc-maintainer, refactor, team. (69 total.)
#
# To invoke: 'plan this refactoring', 'review my changes', 'ultrawork: <task>',
# 'fix the build', 'deep-dive into <bug>', etc.
"@
}

function Test-IsGroupRouter {
    # A "group router" SKILL.md uses relative refs like `skills/team.md` to other skill files.
    # When installed via junction, those relative refs can't resolve because the source dir
    # has no co-located `skills/` subfolder. We must patch the content to use absolute paths.
    param([string]$SkillFile)
    if (-not (Test-Path $SkillFile)) { return $false }
    $content = Get-Content $SkillFile -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    return $content -match 'skills/[a-z-]+\.md'
}

function Get-PatchedRouterContent {
    # Read a router SKILL.md and rewrite relative `skills/<name>.md` refs to absolute paths.
    # Adds a marker so uninstall can identify our installed copies unambiguously.
    param([string]$SourcePath)
    $content = Get-Content $SourcePath -Raw
    $skillsRefPattern = 'skills/([a-z-]+)\.md'
    $patched = $content -replace $skillsRefPattern, "$SkillsDir\`$1.md"
    $marker = "<!-- $Marker (installed copy with absolute paths to $SkillsDir) -->"
    if ($patched -match '(?s)^(---\r?\n.*?\r?\n---\r?\n)') {
        $patched = $patched -replace '(?s)^(---\r?\n.*?\r?\n---\r?\n)', "`${1}$marker`n"
    } else {
        $patched = "$marker`n$patched"
    }
    return $patched
}

function Install-GroupDir {
    # Install a group skill directory.
    # If it's a router (relative `skills/` refs) → copy + patch (so refs resolve).
    # Otherwise → junction (preserves source link, faster).
    # Idempotent: existing broken router installs (relative refs / no marker) get repaired.
    param([System.IO.DirectoryInfo]$Group, [string]$Target)

    if (Test-IsInsideRepo $Target) {
        Write-Err "REFUSING to install inside source repo: $Target"
        return 'failed'
    }

    $sourceSkill = Join-Path $Group.FullName 'SKILL.md'
    $isRouter = Test-IsGroupRouter $sourceSkill

    if ($isRouter) {
        # Need a real dir with patched SKILL.md inside.
        if (Test-Path $Target) {
            $existingItem = Get-Item $Target -Force -ErrorAction SilentlyContinue
            if ($existingItem.LinkType -eq 'Junction') {
                # Replace junction with real dir
                cmd /c "rmdir `"$Target`"" 2>&1 | Out-Null
            }
        }
        if (-not (Test-Path $Target)) {
            New-Item -ItemType Directory -Path $Target -Force | Out-Null
        }
        $targetSkill = Join-Path $Target 'SKILL.md'
        $needWrite = $true
        if (Test-Path $targetSkill) {
            $existing = Get-Content $targetSkill -Raw -ErrorAction SilentlyContinue
            # Already patched and points to current repo? skip.
            if ($existing -and $existing -match [regex]::Escape($SkillsDir) -and $existing -notmatch '\bskills/[a-z-]+\.md\b') {
                $needWrite = $false
            }
        }
        if ($needWrite) {
            $patched = Get-PatchedRouterContent $sourceSkill
            Set-Content -Path $targetSkill -Value $patched -Encoding UTF8
            return 'patched'
        }
        return 'kept'
    } else {
        if (Test-Path $Target) { return 'kept' }
        if (New-Junction $Target $Group.FullName) { return 'junctioned' }
        Write-Warn "Failed to junction group: $($Group.Name)"
        return 'failed'
    }
}

# ── CLI Targets ────────────────────────────────────────────────────────────────

$CLIs = [ordered]@{
    copilot  = @{ Name = 'Copilot (VS Code + CLI)';  Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'global';      OmuCount = 0 }
    claude   = @{ Name = 'Claude Code';               Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'global';      OmuCount = 0 }
    gemini   = @{ Name = 'Gemini CLI';                Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'per-project'; OmuCount = 0 }
    cursor   = @{ Name = 'Cursor';                    Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'global';      OmuCount = 0 }
    windsurf = @{ Name = 'Windsurf';                  Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'per-project'; OmuCount = 0 }
    codex    = @{ Name = 'OpenAI Codex';              Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'per-project'; OmuCount = 0 }
    opencode = @{ Name = 'OpenCode';                  Installed = $false; OmuInstalled = $false; OmuSupported = $false; InstallType = 'per-project'; OmuCount = 0 }
}

# ── Detect repo adapter support per CLI ───────────────────────────────────────

function Detect-OmuSupport {
    # Copilot: needs .github/instructions OR .github/skills OR .github/prompts
    $CLIs['copilot'].OmuSupported = (
        (Test-Path (Join-Path $GhInstructDir 'skills.instructions.md')) -or
        (Test-Path $GhSkillsDir) -or
        (Test-Path $GhPromptsDir)
    )

    # Claude: needs CLAUDE.md OR .claude/skills/
    $CLIs['claude'].OmuSupported = (
        (Test-Path (Join-Path $OmuRoot 'CLAUDE.md')) -or
        (Test-Path $ClaudeSkillsDir)
    )

    # Gemini: needs GEMINI.md
    $CLIs['gemini'].OmuSupported = Test-Path (Join-Path $OmuRoot 'GEMINI.md')

    # Cursor: needs .cursor/rules/skills.mdc
    $CLIs['cursor'].OmuSupported = Test-Path (Join-Path $CursorRulesDir 'skills.mdc')

    # Windsurf: needs .windsurfrules
    $CLIs['windsurf'].OmuSupported = Test-Path $WindsurfRules

    # Codex: needs AGENTS.md
    $CLIs['codex'].OmuSupported = Test-Path (Join-Path $OmuRoot 'AGENTS.md')

    # OpenCode: needs AGENTS.md (same as Codex)
    $CLIs['opencode'].OmuSupported = Test-Path (Join-Path $OmuRoot 'AGENTS.md')
}

# ── Detect CLI installations ──────────────────────────────────────────────────

function Get-OmuSkillCount {
    # Count SKILL.md files containing our marker under a directory.
    param([string]$Dir)
    if (-not (Test-Path $Dir)) { return 0 }
    $count = 0
    foreach ($d in (Get-ChildItem $Dir -Directory -ErrorAction SilentlyContinue)) {
        $sf = Join-Path $d.FullName 'SKILL.md'
        if (Test-Path $sf) {
            $content = Get-Content $sf -Raw -ErrorAction SilentlyContinue
            if ($content -and ($content -match 'oh-my-universal')) { $count++ }
        }
    }
    return $count
}

function Detect-CLIs {
    # Copilot: check for ~/.copilot/ directory; count omu skill wrappers.
    $copilotDir = Join-Path $env:USERPROFILE '.copilot'
    $CLIs['copilot'].Installed = Test-Path $copilotDir
    $CLIs['copilot'].Path = $copilotDir
    $omuCount = Get-OmuSkillCount (Join-Path $copilotDir 'skills')
    $CLIs['copilot'].OmuCount = $omuCount
    $CLIs['copilot'].OmuInstalled = $omuCount -gt 0

    # Claude: check for claude CLI; count omu skill groups in ~/.claude/skills.
    $CLIs['claude'].Installed = $null -ne (Get-Command 'claude' -ErrorAction SilentlyContinue)
    $CLIs['claude'].Path = Join-Path $env:USERPROFILE '.claude'
    $claudeSkillsDir = Join-Path $env:USERPROFILE '.claude\skills'
    $claudeOmuCount = 0
    if (Test-Path $claudeSkillsDir) {
        foreach ($d in (Get-ChildItem $claudeSkillsDir -Directory -ErrorAction SilentlyContinue)) {
            $item = Get-Item $d.FullName -Force -ErrorAction SilentlyContinue
            if ($item.LinkType -eq 'Junction' -and $item.Target -like "*oh-my-universal*") {
                $claudeOmuCount++
            }
        }
    }
    $CLIs['claude'].OmuCount = $claudeOmuCount
    $CLIs['claude'].OmuInstalled = $claudeOmuCount -gt 0

    # Gemini: per-project — global detection N/A.
    $CLIs['gemini'].Installed = $null -ne (Get-Command 'gemini' -ErrorAction SilentlyContinue)
    $CLIs['gemini'].Path = Join-Path $env:USERPROFILE '.gemini'
    $CLIs['gemini'].OmuInstalled = $false

    # Cursor: check for ~/.cursor/ and our rules file.
    $cursorDir = Join-Path $env:USERPROFILE '.cursor'
    $CLIs['cursor'].Installed = Test-Path $cursorDir
    $CLIs['cursor'].Path = $cursorDir
    $cursorRules = "$cursorDir\rules\omu-skills.mdc"
    $cursorInstalled = $false
    if (Test-Path $cursorRules) {
        $c = Get-Content $cursorRules -Raw -ErrorAction SilentlyContinue
        if ($c -and ($c -match 'oh-my-universal')) { $cursorInstalled = $true }
    }
    $CLIs['cursor'].OmuInstalled = $cursorInstalled
    $CLIs['cursor'].OmuCount = if ($cursorInstalled) { 1 } else { 0 }

    # Windsurf, Codex, OpenCode: per-project only — no global detection.
    $CLIs['windsurf'].Installed = $null -ne (Get-Command 'windsurf' -ErrorAction SilentlyContinue)
    $CLIs['windsurf'].Path = Join-Path $env:USERPROFILE '.windsurf'
    $CLIs['windsurf'].OmuInstalled = $false

    $CLIs['codex'].Installed = $null -ne (Get-Command 'codex' -ErrorAction SilentlyContinue)
    $CLIs['codex'].Path = $null
    $CLIs['codex'].OmuInstalled = $false

    $CLIs['opencode'].Installed = $null -ne (Get-Command 'opencode' -ErrorAction SilentlyContinue)
    $CLIs['opencode'].Path = $null
    $CLIs['opencode'].OmuInstalled = $false
}

# ── Install Functions ─────────────────────────────────────────────────────────

function Test-IsInsideRepo {
    # Check whether $Path resolves (after following any junctions/symlinks anywhere
    # in the path) to a location inside $OmuRoot. Catches the case where a parent
    # like ~/.copilot/skills is a junction pointing back into the repo.
    param([string]$Path)
    $resolvedRoot = [System.IO.Path]::GetFullPath($OmuRoot).TrimEnd('\') + '\'

    # Direct comparison via GetFullPath (handles relative bits but doesn't follow links).
    $direct = [System.IO.Path]::GetFullPath($Path).TrimEnd('\') + '\'
    if ($direct.StartsWith($resolvedRoot, [StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    # Walk up the tree checking each existing parent for a junction/symlink that
    # points into the repo. Stops at the first existing ancestor.
    $candidate = $Path
    while ($candidate -and (Split-Path $candidate -Parent)) {
        if (Test-Path $candidate) {
            $item = Get-Item $candidate -Force -ErrorAction SilentlyContinue
            if ($item -and $item.LinkType -in @('Junction','SymbolicLink')) {
                $linkTarget = [System.IO.Path]::GetFullPath($item.Target).TrimEnd('\') + '\'
                if ($linkTarget.StartsWith($resolvedRoot, [StringComparison]::OrdinalIgnoreCase)) {
                    return $true
                }
            }
            break
        }
        $candidate = Split-Path $candidate -Parent
    }
    return $false
}

function Install-Copilot {
    Write-Host "`n  Installing into Copilot..." -ForegroundColor White
    $copilotDir = Join-Path $env:USERPROFILE '.copilot'
    $skillsTarget = Join-Path $copilotDir 'skills'
    $instrTarget = Join-Path $copilotDir 'instructions'

    # Safety: never install inside the source repo. Catches both direct writes
    # (USERPROFILE = repo) AND indirect writes via a junction.
    if (Test-IsInsideRepo $skillsTarget) {
        Write-Err "REFUSING to install: $skillsTarget resolves inside source repo $OmuRoot"
        Write-Err "Likely cause: ~/.copilot/skills (or a parent) is a junction pointing into the repo."
        Write-Err "Fix: cmd /c rmdir `"$skillsTarget`" — then re-run install."
        return
    }

    # Ensure directories exist
    @($skillsTarget, $instrTarget) | ForEach-Object {
        if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
    }

    # 1. Create individual skill wrappers (69 skills)
    $created = 0; $skipped = 0
    foreach ($skillFile in (Get-ChildItem "$SkillsDir\*.md")) {
        $name = $skillFile.BaseName
        $targetDir = Join-Path $skillsTarget $name
        $targetFile = Join-Path $targetDir 'SKILL.md'
        $sourceFile = $skillFile.FullName

        if (Test-Path $targetFile) {
            $existing = Get-Content $targetFile -Raw -ErrorAction SilentlyContinue
            if ($existing -match 'oh-my-universal') { $skipped++; continue }
            # Not ours — don't overwrite
            Write-Warn "Skipping $name — SKILL.md exists but isn't ours"
            $skipped++; continue
        }

        $desc = Get-SkillDescription $sourceFile
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        @"
---
name: $name
description: "$desc"
---
$Marker
# $name

Read and execute the full skill workflow from:

$sourceFile

Use read_file to load the instructions from that absolute path, then follow them.
"@ | Set-Content -Path $targetFile -Encoding UTF8
        $created++
    }
    Write-OK "Skills: $created created, $skipped already present"

    # 2. Junction skill groups (or copy+patch routers) — 8 group routers + 69 single-skill folders
    $gjc = 0; $gjs = 0; $gjp = 0
    foreach ($group in (Get-ChildItem $GhSkillsDir -Directory -ErrorAction SilentlyContinue)) {
        $target = Join-Path $skillsTarget $group.Name
        $result = Install-GroupDir -Group $group -Target $target
        switch ($result) {
            'junctioned' { $gjc++ }
            'patched'    { $gjp++ }
            'kept'       { $gjs++ }
        }
    }
    Write-OK "Skill groups: $gjc junctioned, $gjp routers patched, $gjs already present"

    # 3. Copy instructions file (with markers so we can remove it later)
    $instrSrc = Join-Path $GhInstructDir 'skills.instructions.md'
    $instrDst = Join-Path $instrTarget 'oh-my-universal-skills.instructions.md'
    if (Test-Path $instrSrc) {
        $instrContent = Get-Content $instrSrc -Raw
        # Add our marker and patch relative paths to absolute.
        # Patterns extracted to variables for Windows PowerShell 5.1 parser compatibility.
        $skillsRefPattern = 'skills/([a-z-]+)\.md'
        $skillsNamePattern = 'Read the full skill file from `skills/\{name\}\.md` for detailed workflow\.'
        $instrContent = $instrContent -replace $skillsRefPattern, "$SkillsDir\`$1.md"
        $instrContent = $instrContent -replace $skillsNamePattern, "Read the full skill file using: $SkillsDir\{name}.md"
        @"
$MarkerStart
$instrContent
$MarkerEnd
"@ | Set-Content -Path $instrDst -Encoding UTF8
        Write-OK "Instructions file installed"
    }

    # 4. Install prompts into VS Code user prompts folder
    if ($VscodePromptsDir -and (Test-Path $GhPromptsDir)) {
        if (-not (Test-Path $VscodePromptsDir)) {
            New-Item -ItemType Directory -Path $VscodePromptsDir -Force | Out-Null
        }
        $pc = 0; $ps = 0
        foreach ($prompt in (Get-ChildItem "$GhPromptsDir\*.prompt.md")) {
            $target = Join-Path $VscodePromptsDir $prompt.Name
            if (Test-Path $target) { $ps++; continue }
            # Try hardlink first (same volume), fall back to copy
            if (-not (New-Hardlink $target $prompt.FullName)) {
                Copy-Item $prompt.FullName $target
            }
            $pc++
        }
        Write-OK "VS Code prompts: $pc installed, $ps already present"
    } else {
        Write-Skip "VS Code prompts folder not found"
    }

    Write-OK "Copilot installation complete"
}

function Install-Claude {
    Write-Host "`n  Installing into Claude Code..." -ForegroundColor White
    $claudeDir = Join-Path $env:USERPROFILE '.claude'
    $claudeSkills = Join-Path $claudeDir 'skills'

    if (-not (Test-Path $claudeSkills)) {
        New-Item -ItemType Directory -Path $claudeSkills -Force | Out-Null
    }

    # Install all skill groups from .claude/skills/ — patch routers, junction the rest.
    $gjc = 0; $gjs = 0; $gjp = 0
    foreach ($group in (Get-ChildItem $ClaudeSkillsDir -Directory -ErrorAction SilentlyContinue)) {
        $target = Join-Path $claudeSkills $group.Name
        $result = Install-GroupDir -Group $group -Target $target
        switch ($result) {
            'junctioned' { $gjc++ }
            'patched'    { $gjp++ }
            'kept'       { $gjs++ }
        }
    }
    Write-OK "Claude skill groups: $gjc junctioned, $gjp routers patched, $gjs already present"

    Write-OK "Claude Code installation complete"
    Write-Info "Tip: Add to shell profile: function claude { & claude.exe --plugin-dir '$OmuRoot' @args }"
}

function Install-Gemini {
    Write-Host "`n  Installing into Gemini CLI..." -ForegroundColor White
    if (-not $Project) {
        Write-Warn "Gemini CLI has no global config — pass -Project <path> to install per-project."
        Write-Info "Per-project options without this script:"
        Write-Info "  1. Shell alias:  function gemini { & gemini.exe --plugin-dir '$OmuRoot' @args }"
        Write-Info "  2. Per-project:  cmd /c mklink /J .omu-skills `"$SkillsDir`""
        Write-OK "Gemini guidance provided (no files modified)"
        return
    }
    Install-PerProject -CliKey 'gemini' -ProjectPath $Project -FileName 'GEMINI.md'
}

function Install-Cursor {
    Write-Host "`n  Installing into Cursor..." -ForegroundColor White
    $cursorDir = Join-Path $env:USERPROFILE '.cursor'
    $rulesDir = Join-Path $cursorDir 'rules'

    if (-not (Test-Path $rulesDir)) {
        New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
    }

    $src = Join-Path $CursorRulesDir 'skills.mdc'
    $dst = Join-Path $rulesDir 'omu-skills.mdc'

    if (Test-Path $dst) {
        Write-Skip "Cursor rules file already installed"
    } elseif (Test-Path $src) {
        # Patch relative paths to absolute (variable required for PS 5.1 parser)
        $content = Get-Content $src -Raw
        $skillsRefPattern = 'skills/([a-z-]+)\.md'
        $content = $content -replace $skillsRefPattern, "$SkillsDir\`$1.md"
        @"
$MarkerStart
$content
$MarkerEnd
"@ | Set-Content -Path $dst -Encoding UTF8
        Write-OK "Cursor rules file installed at $dst"
    } else {
        Write-Err "Source cursor rules not found: $src"
    }
    Write-OK "Cursor installation complete"
}

function Install-Windsurf {
    Write-Host "`n  Installing into Windsurf..." -ForegroundColor White
    if (-not $Project) {
        Write-Warn "Windsurf reads .windsurfrules from project root only — pass -Project <path>."
        Write-Info "Per-project options without this script:"
        Write-Info "  1. Junction: cmd /c mklink /J .windsurfrules `"$WindsurfRules`""
        Write-Info "  2. Copy:     Copy-Item '$WindsurfRules' .\.windsurfrules"
        Write-OK "Windsurf guidance provided (no files modified)"
        return
    }
    Install-PerProject -CliKey 'windsurf' -ProjectPath $Project -FileName '.windsurfrules'
}

function Install-Codex {
    Write-Host "`n  Installing into Codex..." -ForegroundColor White
    if (-not $Project) {
        Write-Warn "Codex reads AGENTS.md from cwd only — pass -Project <path> to install per-project."
        Write-Info "Per-project options without this script:"
        Write-Info "  1. Junction: cmd /c mklink /J .omu-skills `"$SkillsDir`""
        Write-Info "  2. Reference in AGENTS.md: 'Read skills from .omu-skills/{name}.md'"
        Write-OK "Codex guidance provided (no files modified)"
        return
    }
    Install-PerProject -CliKey 'codex' -ProjectPath $Project -FileName 'AGENTS.md'
}

function Install-OpenCode {
    Write-Host "`n  Installing into OpenCode..." -ForegroundColor White
    if (-not $Project) {
        Write-Warn "OpenCode reads AGENTS.md from cwd — pass -Project <path> to install per-project."
        Write-Info "Same options as Codex above."
        Write-OK "OpenCode guidance provided (no files modified)"
        return
    }
    Install-PerProject -CliKey 'opencode' -ProjectPath $Project -FileName 'AGENTS.md'
}

function Install-PerProject {
    # Append (or refresh) the oh-my-universal marker section in <project>/<file>.
    # Preserves all existing content; only the marker block is touched.
    param([string]$CliKey, [string]$ProjectPath, [string]$FileName)

    if (-not (Test-Path $ProjectPath)) {
        Write-Err "Project path does not exist: $ProjectPath"
        return
    }
    $resolved = (Resolve-Path $ProjectPath).Path
    $targetFile = Join-Path $resolved $FileName
    $body = Get-OmuProjectBody
    Add-OmuMarkedSection -Path $targetFile -Body $body
    $action = if (Test-Path $targetFile) { 'Updated' } else { 'Created' }
    Write-OK "$CliKey ($FileName): marker section installed at $targetFile"
}

# ── Uninstall Functions ───────────────────────────────────────────────────────

function Uninstall-Copilot {
    Write-Host "`n  Uninstalling from Copilot..." -ForegroundColor White
    $copilotDir = Join-Path $env:USERPROFILE '.copilot'
    $skillsTarget = Join-Path $copilotDir 'skills'
    $instrTarget = Join-Path $copilotDir 'instructions'

    # 1. Remove individual skill wrappers (only if they contain our marker)
    $removed = 0; $kept = 0
    foreach ($skillFile in (Get-ChildItem "$SkillsDir\*.md" -ErrorAction SilentlyContinue)) {
        $name = $skillFile.BaseName
        $targetDir = Join-Path $skillsTarget $name
        $targetFile = Join-Path $targetDir 'SKILL.md'

        if (-not (Test-Path $targetFile)) { continue }

        $content = Get-Content $targetFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'oh-my-universal') {
            Remove-Item $targetDir -Recurse -Force
            $removed++
        } else {
            $kept++
        }
    }
    Write-OK "Skills removed: $removed (kept $kept non-omu skills)"

    # 2. Remove skill groups: junctions pointing to our repo, OR patched-router copies (real dirs).
    $gjr = 0; $gpr = 0
    foreach ($group in (Get-ChildItem $GhSkillsDir -Directory -ErrorAction SilentlyContinue)) {
        $target = Join-Path $skillsTarget $group.Name
        if (-not (Test-Path $target)) { continue }
        $item = Get-Item $target -Force
        if ($item.LinkType -eq 'Junction') {
            $targetPath = $item.Target
            if ($targetPath -like "*oh-my-universal*") {
                cmd /c "rmdir `"$target`"" 2>&1 | Out-Null
                $gjr++
            }
            continue
        }
        # Real dir: only remove if it's a patched router copy (has our marker).
        $sf = Join-Path $target 'SKILL.md'
        if (Test-Path $sf) {
            $c = Get-Content $sf -Raw -ErrorAction SilentlyContinue
            if ($c -and ($c -match [regex]::Escape($Marker) -or $c -match 'oh-my-universal')) {
                # Extra safety: only delete if directory contains ONLY the SKILL.md (no user-added files).
                $contents = Get-ChildItem $target -Force -ErrorAction SilentlyContinue
                if ($contents.Count -eq 1 -and $contents[0].Name -eq 'SKILL.md') {
                    Remove-Item $target -Recurse -Force
                    $gpr++
                } else {
                    Write-Warn "Group $($group.Name): contains user-added files — kept"
                }
            }
        }
    }
    Write-OK "Skill groups removed: $gjr junctions, $gpr patched-router copies"

    # 3. Remove instructions file (only our file, not user's own)
    $instrFile = Join-Path $instrTarget 'oh-my-universal-skills.instructions.md'
    if (Test-Path $instrFile) {
        $content = Get-Content $instrFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'oh-my-universal') {
            Remove-Item $instrFile -Force
            Write-OK "Instructions file removed"
        } else {
            Write-Skip "Instructions file not ours — left untouched"
        }
    } else {
        Write-Skip "No instructions file to remove"
    }

    # 4. Remove VS Code prompts (only ones that match our source names AND content)
    if ($VscodePromptsDir -and (Test-Path $GhPromptsDir)) {
        $pr = 0
        foreach ($prompt in (Get-ChildItem "$GhPromptsDir\*.prompt.md" -ErrorAction SilentlyContinue)) {
            $target = Join-Path $VscodePromptsDir $prompt.Name
            if (Test-Path $target) {
                # Compare content — only remove if it matches our source
                $srcHash = (Get-FileHash $prompt.FullName -Algorithm SHA256).Hash
                $dstHash = (Get-FileHash $target -Algorithm SHA256).Hash
                if ($srcHash -eq $dstHash) {
                    Remove-Item $target -Force
                    $pr++
                } else {
                    Write-Skip "Prompt '$($prompt.Name)' modified by user — left untouched"
                }
            }
        }
        Write-OK "VS Code prompts removed: $pr"
    }

    Write-OK "Copilot uninstall complete"
}

function Uninstall-Claude {
    Write-Host "`n  Uninstalling from Claude Code..." -ForegroundColor White
    $claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'

    $jr = 0; $pr = 0
    foreach ($dir in (Get-ChildItem $claudeSkills -Directory -ErrorAction SilentlyContinue)) {
        $item = Get-Item $dir.FullName -Force
        if ($item.LinkType -eq 'Junction' -and $item.Target -like "*oh-my-universal*") {
            cmd /c "rmdir `"$($dir.FullName)`"" 2>&1 | Out-Null
            $jr++
            continue
        }
        # Real dir: check for patched-router marker
        if ($item.LinkType) { continue }
        $sf = Join-Path $dir.FullName 'SKILL.md'
        if (Test-Path $sf) {
            $c = Get-Content $sf -Raw -ErrorAction SilentlyContinue
            if ($c -and ($c -match [regex]::Escape($Marker))) {
                $contents = Get-ChildItem $dir.FullName -Force -ErrorAction SilentlyContinue
                if ($contents.Count -eq 1 -and $contents[0].Name -eq 'SKILL.md') {
                    Remove-Item $dir.FullName -Recurse -Force
                    $pr++
                } else {
                    Write-Warn "Claude group $($dir.Name): contains user-added files — kept"
                }
            }
        }
    }
    Write-OK "Claude skill groups removed: $jr junctions, $pr patched-router copies"
    Write-OK "Claude uninstall complete"
}

function Uninstall-Cursor {
    Write-Host "`n  Uninstalling from Cursor..." -ForegroundColor White
    $rulesFile = Join-Path $env:USERPROFILE '.cursor\rules\omu-skills.mdc'
    if (Test-Path $rulesFile) {
        $content = Get-Content $rulesFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'oh-my-universal') {
            Remove-Item $rulesFile -Force
            Write-OK "Cursor rules file removed"
        } else {
            Write-Skip "Cursor rules file not ours — left untouched"
        }
    } else {
        Write-Skip "No Cursor rules file to remove"
    }
    Write-OK "Cursor uninstall complete"
}

function Uninstall-Gemini   {
    if ($Project) { Uninstall-PerProject -CliKey 'gemini' -ProjectPath $Project -FileName 'GEMINI.md'; return }
    Write-Host "`n  Gemini: nothing to uninstall globally (per-project only). Use -Project to remove from a project." -ForegroundColor DarkGray
}
function Uninstall-Windsurf {
    if ($Project) { Uninstall-PerProject -CliKey 'windsurf' -ProjectPath $Project -FileName '.windsurfrules'; return }
    Write-Host "`n  Windsurf: nothing to uninstall globally (per-project only). Use -Project to remove from a project." -ForegroundColor DarkGray
}
function Uninstall-Codex    {
    if ($Project) { Uninstall-PerProject -CliKey 'codex' -ProjectPath $Project -FileName 'AGENTS.md'; return }
    Write-Host "`n  Codex: nothing to uninstall globally (per-project only). Use -Project to remove from a project." -ForegroundColor DarkGray
}
function Uninstall-OpenCode {
    if ($Project) { Uninstall-PerProject -CliKey 'opencode' -ProjectPath $Project -FileName 'AGENTS.md'; return }
    Write-Host "`n  OpenCode: nothing to uninstall globally (per-project only). Use -Project to remove from a project." -ForegroundColor DarkGray
}

function Uninstall-PerProject {
    # Remove only the oh-my-universal marker section from the per-project file.
    # Leaves all other content untouched; deletes the file only if it became empty.
    param([string]$CliKey, [string]$ProjectPath, [string]$FileName)

    if (-not (Test-Path $ProjectPath)) {
        Write-Err "Project path does not exist: $ProjectPath"
        return
    }
    $resolved = (Resolve-Path $ProjectPath).Path
    $targetFile = Join-Path $resolved $FileName
    if (-not (Test-Path $targetFile)) {
        Write-Skip "$CliKey ($FileName) not present at $targetFile"
        return
    }
    if (Remove-OmuMarkedSection -Path $targetFile) {
        Write-OK "$CliKey ($FileName): marker section removed from $targetFile"
    } else {
        Write-Skip "$CliKey ($FileName): no oh-my-universal section found — left untouched"
    }
}

# ── Status ────────────────────────────────────────────────────────────────────

function Show-Status {
    Write-Host "`n  oh-my-universal Status" -ForegroundColor White
    Write-Host "  ---------------------" -ForegroundColor DarkGray
    Write-Host "  Repo: $OmuRoot"
    Write-Host "  Skills: $((Get-SkillNames).Count)"
    Write-Host ""

    Detect-CLIs
    Detect-OmuSupport

    $fmt = "  {0,-26} {1,-10} {2,-10} {3,-14} {4,-12}"
    Write-Host ($fmt -f 'CLI', 'Found', 'Supported', 'Installed', 'Type') -ForegroundColor DarkGray
    Write-Host ($fmt -f '---', '-----', '---------', '---------', '----') -ForegroundColor DarkGray

    foreach ($key in $CLIs.Keys) {
        $cli = $CLIs[$key]
        $avail = if ($cli.Installed) { 'Yes' } else { 'No' }
        $availColor = if ($cli.Installed) { 'Green' } else { 'DarkGray' }

        $support = if ($cli.OmuSupported) { 'Yes' } else { 'No' }
        $supportColor = if ($cli.OmuSupported) { 'Green' } else { 'Red' }

        if ($cli.InstallType -eq 'per-project') {
            $omu = 'per-project'
            $omuColor = 'Yellow'
        } elseif ($cli.OmuCount -gt 0) {
            $omu = "Yes ($($cli.OmuCount))"
            $omuColor = 'Green'
        } else {
            $omu = 'No'
            $omuColor = 'DarkGray'
        }

        $type = $cli.InstallType
        $typeColor = if ($type -eq 'global') { 'Cyan' } else { 'Yellow' }

        Write-Host -NoNewline ("  {0,-26} " -f $cli.Name)
        Write-Host -NoNewline $avail.PadRight(10) -ForegroundColor $availColor
        Write-Host -NoNewline $support.PadRight(10) -ForegroundColor $supportColor
        Write-Host -NoNewline $omu.PadRight(14) -ForegroundColor $omuColor
        Write-Host $type -ForegroundColor $typeColor
    }

    Write-Host ""
    Write-Host "  'per-project' = use -Project <path> to install/uninstall in a specific project." -ForegroundColor DarkGray

    # Extra detail for Copilot
    $copilotSkills = Join-Path $env:USERPROFILE '.copilot\skills'
    if (Test-Path $copilotSkills) {
        $omuSkillCount = (Get-ChildItem $copilotSkills -Directory | Where-Object {
            $sf = Join-Path $_.FullName 'SKILL.md'
            if (Test-Path $sf) {
                (Get-Content $sf -Raw -ErrorAction SilentlyContinue) -match 'oh-my-universal'
            } else { $false }
        }).Count
        $junctionCount = (Get-ChildItem $copilotSkills -Directory | Where-Object {
            $_.LinkType -eq 'Junction'
        }).Count
        Write-Host ""
        Write-Host "  Copilot detail:" -ForegroundColor DarkGray
        Write-Host "    Skill wrappers: $omuSkillCount" -ForegroundColor Cyan
        Write-Host "    Skill groups (junctions): $junctionCount" -ForegroundColor Cyan

        $instrFile = Join-Path $env:USERPROFILE '.copilot\instructions\oh-my-universal-skills.instructions.md'
        Write-Host "    Instructions file: $(if (Test-Path $instrFile) { 'Installed' } else { 'Not found' })" -ForegroundColor Cyan

        if ($VscodePromptsDir -and (Test-Path $VscodePromptsDir)) {
            $omuPromptCount = (Get-ChildItem "$VscodePromptsDir\*.prompt.md" -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -in (Get-ChildItem "$GhPromptsDir\*.prompt.md" -ErrorAction SilentlyContinue).Name }).Count
            Write-Host "    VS Code prompts: $omuPromptCount" -ForegroundColor Cyan
        }
    }

    Write-Host ""
}

# ── Interactive Menu ──────────────────────────────────────────────────────────

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║    oh-my-universal Setup                 ║" -ForegroundColor Cyan
    Write-Host "  ║    69 skills · 19 hooks · 4 contracts    ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    if (-not $isAdmin) {
        Write-Host "  NOTE: Not running as Admin. Junctions work, dir symlinks won't." -ForegroundColor Yellow
        Write-Host ""
    }

    Write-Host "  [1] Install        — Install into selected CLIs" -ForegroundColor White
    Write-Host "  [2] Uninstall      — Remove from selected CLIs" -ForegroundColor White
    Write-Host "  [3] Status         — Show what's installed where" -ForegroundColor White
    Write-Host "  [4] Exit" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "  Choose [1-4]"
    return $choice
}

function Select-CLITargets {
    param([string]$ActionLabel)

    Detect-CLIs
    Write-Host ""
    Write-Host "  Select CLI targets to $ActionLabel" -ForegroundColor White
    Write-Host "  ───────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    $i = 1
    $map = @{}
    foreach ($key in $CLIs.Keys) {
        $cli = $CLIs[$key]
        $status = ''
        if ($ActionLabel -eq 'install' -and $cli.OmuInstalled) { $status = ' (already installed)' }
        if ($ActionLabel -eq 'uninstall' -and -not $cli.OmuInstalled) { $status = ' (not installed)' }
        $avail = if ($cli.Installed) { '' } else { ' [not detected]' }
        Write-Host "  [$i] $($cli.Name)$avail$status"
        $map[$i] = $key
        $i++
    }
    Write-Host "  [$i] All" -ForegroundColor Cyan
    $map[$i] = 'all'
    Write-Host "  [0] Cancel" -ForegroundColor DarkGray
    Write-Host ""

    $selection = Read-Host "  Enter numbers (comma-separated, e.g. 1,2,4)"
    if ($selection -eq '0' -or -not $selection) { return @() }

    $selected = @()
    foreach ($num in ($selection -split ',')) {
        $n = $num.Trim() -as [int]
        if ($map.ContainsKey($n)) {
            if ($map[$n] -eq 'all') {
                $selected = $CLIs.Keys | ForEach-Object { $_ }
                break
            }
            $selected += $map[$n]
        }
    }
    return $selected
}

function Execute-Action {
    param([string]$ActionName, [string[]]$Targets)

    foreach ($t in $Targets) {
        switch ($ActionName) {
            'install' {
                switch ($t) {
                    'copilot'  { Install-Copilot }
                    'claude'   { Install-Claude }
                    'gemini'   { Install-Gemini }
                    'cursor'   { Install-Cursor }
                    'windsurf' { Install-Windsurf }
                    'codex'    { Install-Codex }
                    'opencode' { Install-OpenCode }
                }
            }
            'uninstall' {
                switch ($t) {
                    'copilot'  { Uninstall-Copilot }
                    'claude'   { Uninstall-Claude }
                    'gemini'   { Uninstall-Gemini }
                    'cursor'   { Uninstall-Cursor }
                    'windsurf' { Uninstall-Windsurf }
                    'codex'    { Uninstall-Codex }
                    'opencode' { Uninstall-OpenCode }
                }
            }
        }
    }
}

# ── Main ──────────────────────────────────────────────────────────────────────

# Non-interactive mode
if ($Action) {
    Detect-CLIs

    $targets = @()
    if ($Target) {
        if ($Target -eq 'all') {
            $targets = $CLIs.Keys | ForEach-Object { $_ }
        } else {
            $targets = $Target -split ',' | ForEach-Object { $_.Trim().ToLower() }
        }
    }

    switch ($Action) {
        'status' {
            Show-Status
        }
        'install' {
            if (-not $targets) {
                Write-Err "Specify -Target (copilot, claude, gemini, cursor, windsurf, codex, opencode, all)"
                exit 1
            }
            Write-Host "`n  oh-my-universal — Installing..." -ForegroundColor Cyan
            Execute-Action 'install' $targets
            Write-Host "`n  Done!" -ForegroundColor Green
        }
        'uninstall' {
            if (-not $targets) {
                Write-Err "Specify -Target (copilot, claude, cursor, all)"
                exit 1
            }
            Write-Host "`n  oh-my-universal — Uninstalling..." -ForegroundColor Cyan
            Execute-Action 'uninstall' $targets
            Write-Host "`n  Done!" -ForegroundColor Green
        }
    }
    exit 0
}

# Interactive mode
while ($true) {
    $choice = Show-Menu

    switch ($choice) {
        '1' {
            $targets = Select-CLITargets 'install'
            if ($targets.Count -gt 0) {
                Write-Host "`n  Installing into: $($targets -join ', ')" -ForegroundColor Cyan
                Execute-Action 'install' $targets
                Write-Host "`n  Press Enter to continue..."
                Read-Host | Out-Null
            }
        }
        '2' {
            $targets = Select-CLITargets 'uninstall'
            if ($targets.Count -gt 0) {
                Write-Host ""
                Write-Host "  WARNING: This will remove oh-my-universal files ONLY." -ForegroundColor Yellow
                Write-Host "  Your own skills, instructions, and configs will NOT be touched." -ForegroundColor Yellow
                $confirm = Read-Host "  Type 'yes' to confirm"
                if ($confirm -eq 'yes') {
                    Execute-Action 'uninstall' $targets
                } else {
                    Write-Host "  Cancelled." -ForegroundColor DarkGray
                }
                Write-Host "`n  Press Enter to continue..."
                Read-Host | Out-Null
            }
        }
        '3' {
            Show-Status
            Write-Host "  Press Enter to continue..."
            Read-Host | Out-Null
        }
        '4' { exit 0 }
        default {
            Write-Host "  Invalid choice." -ForegroundColor Red
            Start-Sleep -Milliseconds 500
        }
    }
}
