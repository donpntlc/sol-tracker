# Einmal: winget install GitHub.cli, dann: gh auth login
# Dann (im Projektordner):  .\scripts\gh_create_and_push.ps1
# Legt privates Repo an und pusht main (nur falls noch kein origin).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path (Join-Path $root ".git"))) {
  & git -C $root init -b main
  & git -C $root add -A
  if (& git -C $root status --porcelain) {
    $null = & git -C $root commit -m "Initial commit" 2>&1
  }
}

$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
  Write-Error "GitHub CLI fehlt. Install: winget install GitHub.cli"
  exit 1
}
$null = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "Zuerst: gh auth login"; exit 1 }

$repo = if ($args[0]) { $args[0] } else { "macro_tracker" }
$remotes = @(& git -C $root remote 2>$null)
if ($remotes -contains "origin") {
  Write-Host "origin existiert – nutze stattdessen: .\scripts\UploadToGitHub.ps1" -ForegroundColor Yellow
  exit 0
}

& gh repo create $repo --private --source $root --remote origin --push
Write-Host "Fertig. Anderen Rechner: git clone (URL vom grünen Code-Button auf GitHub)."
