param(
    [ValidateSet("auto", "codex", "openclaw")]
    [string]$Tool = "auto",
    [string]$Dest = "",
    [string]$Branch = "main",
    [switch]$Yes,
    [string]$RoleRepoDest = "$HOME\.agency\vendor\agency-agents-zh",
    [string]$RoleRepoUrl = "https://github.com/jnMetaCode/agency-agents-zh.git",
    [string]$RoleRepoRef = "main",
    [switch]$SkipRoleRepo,
    [switch]$UpdateRoleRepo
)

$ErrorActionPreference = "Stop"

$RepoOwner = "dengqixing"
$RepoName = "agency-agents-zh-manage"
$SkillSlug = "agency-agents-zh-manage"
$SkillSourcePath = "skills\$SkillSlug"

function Resolve-Tool {
    param([string]$RequestedTool)

    if ($RequestedTool -ne "auto") {
        return $RequestedTool
    }

    if ((Test-Path "$HOME\.codex") -or (Test-Path "$HOME\.codex\skills")) {
        return "codex"
    }

    if ((Test-Path "$HOME\.openclaw") -or (Test-Path "$HOME\.openclaw\skills")) {
        return "openclaw"
    }

    throw "Unable to detect the target tool automatically. Pass -Tool codex or -Tool openclaw."
}

function Resolve-Dest {
    param(
        [string]$TargetTool,
        [string]$RequestedDest
    )

    if ($RequestedDest) {
        return $RequestedDest
    }

    switch ($TargetTool) {
        "codex" { return "$HOME\.codex\skills\$SkillSlug" }
        "openclaw" { return "$HOME\.openclaw\skills\$SkillSlug" }
        default { throw "Unsupported tool: $TargetTool" }
    }
}

function Confirm-Install {
    param(
        [string]$TargetTool,
        [string]$TargetDest
    )

    if ($Yes -or -not $Host.UI.RawUI) {
        return
    }

    $reply = Read-Host "Install $SkillSlug to $TargetDest for $TargetTool? [Y/n]"
    if ([string]::IsNullOrWhiteSpace($reply) -or $reply -match '^(y|yes)$') {
        return
    }

    throw "Installation cancelled."
}

function Normalize-GitHubUrl {
    param([string]$Url)
    if ($Url.EndsWith(".git")) {
        return $Url.Substring(0, $Url.Length - 4)
    }
    return $Url
}

function Get-GitHubArchiveUrl {
    param(
        [string]$Url,
        [string]$Ref
    )

    $normalized = Normalize-GitHubUrl $Url
    if ($normalized -match '^https://github.com/(?<path>[^/]+/[^/]+)$') {
        return "https://github.com/$($Matches['path'])/archive/refs/heads/$Ref.zip"
    }

    throw "Unsupported GitHub repository URL: $Url"
}

function Replace-Directory {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not $Destination -or $Destination -eq "\") {
        throw "Refusing to overwrite an invalid destination."
    }

    $parent = Split-Path -Parent $Destination
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    Move-Item -LiteralPath $Source -Destination $Destination
}

function Download-RepoSnapshot {
    param(
        [string]$RepoUrl,
        [string]$RepoRef,
        [string]$Destination
    )

    $tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    $zipPath = Join-Path $tmpRoot "repo.zip"
    New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

    Invoke-WebRequest -Uri (Get-GitHubArchiveUrl -Url $RepoUrl -Ref $RepoRef) -OutFile $zipPath
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpRoot -Force

    $repoBaseName = Split-Path -Leaf (Normalize-GitHubUrl $RepoUrl)
    $unpackedRoot = Join-Path $tmpRoot "$repoBaseName-$RepoRef"
    if (-not (Test-Path -LiteralPath $unpackedRoot)) {
        throw "Unable to unpack $RepoUrl@$RepoRef"
    }

    Replace-Directory -Source $unpackedRoot -Destination $Destination
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
}

function Install-OrUpdateRoleRepo {
    param(
        [string]$Destination,
        [string]$RepoUrl,
        [string]$RepoRef
    )

    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if (-not (Test-Path -LiteralPath $Destination)) {
        if ($gitCmd) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
            & $gitCmd.Source clone --depth 1 --branch $RepoRef $RepoUrl $Destination | Out-Null
        } else {
            Download-RepoSnapshot -RepoUrl $RepoUrl -RepoRef $RepoRef -Destination $Destination
        }
        return
    }

    if (-not $UpdateRoleRepo) {
        return
    }

    if ((Test-Path -LiteralPath (Join-Path $Destination ".git")) -and $gitCmd) {
        & $gitCmd.Source -C $Destination remote set-url origin $RepoUrl | Out-Null
        & $gitCmd.Source -C $Destination fetch --depth 1 origin $RepoRef | Out-Null
        & $gitCmd.Source -C $Destination checkout -B $RepoRef FETCH_HEAD | Out-Null
    } else {
        Download-RepoSnapshot -RepoUrl $RepoUrl -RepoRef $RepoRef -Destination $Destination
    }
}

function Download-AndInstallSkill {
    param(
        [string]$TargetTool,
        [string]$TargetDest
    )

    $tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    $zipPath = Join-Path $tmpRoot "repo.zip"
    New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

    $archiveUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"
    Invoke-WebRequest -Uri $archiveUrl -OutFile $zipPath
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpRoot -Force

    $sourceDir = Join-Path $tmpRoot "$RepoName-$Branch\$SkillSourcePath"
    if (-not (Test-Path -LiteralPath $sourceDir)) {
        throw "Skill source not found in archive: $SkillSourcePath"
    }

    $parent = Split-Path -Parent $TargetDest
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    if (Test-Path -LiteralPath $TargetDest) {
        Remove-Item -LiteralPath $TargetDest -Recurse -Force
    }

    Copy-Item -LiteralPath $sourceDir -Destination $TargetDest -Recurse
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
}

$Tool = Resolve-Tool -RequestedTool $Tool
$Dest = Resolve-Dest -TargetTool $Tool -RequestedDest $Dest
Confirm-Install -TargetTool $Tool -TargetDest $Dest
Download-AndInstallSkill -TargetTool $Tool -TargetDest $Dest

if (-not $SkipRoleRepo) {
    Install-OrUpdateRoleRepo -Destination $RoleRepoDest -RepoUrl $RoleRepoUrl -RepoRef $RoleRepoRef
}

$wrapperPath = Join-Path $Dest "scripts\agency-agents-zh-manage.cmd"
if (Test-Path -LiteralPath $wrapperPath) {
    [Environment]::SetEnvironmentVariable("AGENCY_AGENTS_ZH_MANAGE_SCRIPT", $wrapperPath, "User")
}

if (-not $SkipRoleRepo) {
    [Environment]::SetEnvironmentVariable("AGENCY_AGENTS_REPO", $RoleRepoDest, "User")
}

Write-Output "Installed $SkillSlug to $Dest"
Write-Output "Target tool: $Tool"
if (-not $SkipRoleRepo) {
    Write-Output "Dependency repo: $RoleRepoDest"
}
if (Test-Path -LiteralPath $wrapperPath) {
    Write-Output "Windows wrapper: $wrapperPath"
}
