<#
.SYNOPSIS
    Smoke tests for oh-my-universal setup scripts.

.DESCRIPTION
    Verifies parse + status + per-project safety on Windows.
    Per-project safety = "user content above and below our marker block is preserved exactly".
    Exit code 0 = pass; non-zero = something failed.
#>

$ErrorActionPreference = 'Continue'
$here = Split-Path $MyInvocation.MyCommand.Path
$ps1  = Join-Path $here 'setup.ps1'
$sh   = Join-Path $here 'setup.sh'
$py   = Join-Path $here 'setup.py'

$script:pass = 0
$script:fail = 0

function _Pass($msg) { Write-Host "  [PASS] $msg" -ForegroundColor Green; $script:pass++ }
function _Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red;   $script:fail++ }
function _Skip($msg) { Write-Host "  [SKIP] $msg" -ForegroundColor DarkGray }

Write-Host ''
Write-Host '  oh-my-universal setup -- smoke tests' -ForegroundColor Cyan
Write-Host '  ------------------------------------' -ForegroundColor DarkGray

# ── Test 1: scripts exist ────────────────────────────────────────────────────
foreach ($p in @($ps1, $sh, $py)) {
    if (Test-Path $p) { _Pass "exists: $(Split-Path $p -Leaf)" }
    else              { _Fail "missing: $p" }
}

# ── Test 2: setup.ps1 parses in Windows PowerShell 5.x ───────────────────────
$ps5script = @"
try {
    `$null = [scriptblock]::Create((Get-Content -Raw '$ps1'))
    exit 0
} catch {
    Write-Error `$_.Exception.Message
    exit 1
}
"@
$ps5tmp = "$env:TEMP\omu-parse-ps5.ps1"
$ps5script | Set-Content $ps5tmp -Encoding UTF8
$null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps5tmp 2>$null
if ($LASTEXITCODE -eq 0) { _Pass 'setup.ps1 parses in Windows PowerShell 5.x' }
else                     { _Fail 'setup.ps1 fails to parse in Windows PowerShell 5.x (BOM missing?)' }
Remove-Item $ps5tmp -Force -ErrorAction SilentlyContinue

# ── Test 3: setup.ps1 parses in PowerShell 7 ─────────────────────────────────
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    $ps7tmp = "$env:TEMP\omu-parse-ps7.ps1"
    $ps5script | Set-Content $ps7tmp -Encoding UTF8
    $null = & pwsh -NoProfile -ExecutionPolicy Bypass -File $ps7tmp 2>$null
    if ($LASTEXITCODE -eq 0) { _Pass 'setup.ps1 parses in PowerShell 7' }
    else                     { _Fail 'setup.ps1 fails to parse in PowerShell 7' }
    Remove-Item $ps7tmp -Force -ErrorAction SilentlyContinue
} else {
    _Skip 'pwsh not installed'
}

# ── Test 4: setup.ps1 -Action status runs cleanly ────────────────────────────
$out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps1 -Action status 2>&1
$ok = ($LASTEXITCODE -eq 0) -and ($out -match 'oh-my-universal Status')
if ($ok) { _Pass 'setup.ps1 -Action status runs cleanly' }
else     { _Fail 'setup.ps1 -Action status failed' }

# ── Test 5: per-project install/uninstall preserves user content ─────────────
function Test-PerProject {
    param([string]$Tool, [string]$FileName)

    $proj = Join-Path $env:TEMP "omu-smoke-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
    New-Item -ItemType Directory -Path $proj -Force | Out-Null
    $original = "# My Project`n`nUser content here.`n`n## Section`n- item one`n"
    Set-Content -Path (Join-Path $proj $FileName) -Value $original -Encoding UTF8 -NoNewline

    $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps1 -Action install -Target $Tool -Project $proj 2>&1
    if ($LASTEXITCODE -ne 0) { _Fail "install ${Tool} returned non-zero"; Remove-Item $proj -Recurse -Force; return }

    $afterInstall = Get-Content (Join-Path $proj $FileName) -Raw
    if ($afterInstall -match 'oh-my-universal START' -and $afterInstall -match 'User content here') {
        _Pass "install ${Tool}: marker added, user content preserved"
    } else {
        _Fail "install ${Tool}: marker missing or user content lost"
        Remove-Item $proj -Recurse -Force; return
    }

    $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps1 -Action uninstall -Target $Tool -Project $proj 2>&1
    if (-not (Test-Path (Join-Path $proj $FileName))) {
        _Fail "uninstall ${Tool}: deleted the user file"
        Remove-Item $proj -Recurse -Force; return
    }
    $restored = (Get-Content (Join-Path $proj $FileName) -Raw).TrimEnd()
    if ($restored -eq $original.TrimEnd()) {
        _Pass "uninstall ${Tool}: user content restored exactly"
    } else {
        _Fail "uninstall ${Tool}: user content was modified"
        Write-Host "    BEFORE: $($original.TrimEnd())" -ForegroundColor DarkGray
        Write-Host "    AFTER:  $restored"               -ForegroundColor DarkGray
    }

    Remove-Item $proj -Recurse -Force
}

Test-PerProject -Tool 'codex'    -FileName 'AGENTS.md'
Test-PerProject -Tool 'gemini'   -FileName 'GEMINI.md'
Test-PerProject -Tool 'windsurf' -FileName '.windsurfrules'
Test-PerProject -Tool 'opencode' -FileName 'AGENTS.md'

# ── Test 6: delegate to test.py for full cross-platform coverage ─────────────
if (Get-Command python -ErrorAction SilentlyContinue) {
    $env:PYTHONIOENCODING = 'utf-8'
    Write-Host ''
    Write-Host '  --- delegating to test.py for cross-runtime checks ---' -ForegroundColor DarkGray
    & python (Join-Path $here 'test.py')
    if ($LASTEXITCODE -eq 0) { _Pass 'test.py reports all green' }
    else                     { _Fail 'test.py reported failures' }
} else {
    _Skip 'python not installed -- skipping cross-runtime delegation'
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host ''
Write-Host '  --- Summary ---' -ForegroundColor Cyan
Write-Host "  PASS: $script:pass" -ForegroundColor Green
$failColor = 'DarkGray'
if ($script:fail -gt 0) { $failColor = 'Red' }
Write-Host "  FAIL: $script:fail" -ForegroundColor $failColor
Write-Host ''

if ($script:fail -gt 0) { exit 1 } else { exit 0 }
