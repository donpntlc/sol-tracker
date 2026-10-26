# Neueste Version von GitHub holen (anderer PC oder vor dem Weiterarbeiten)
#   .\scripts\AbholenVonGitHub.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$null = & git --version 2>&1
if ($LASTEXITCODE -ne 0) { throw "Git fehlt. Installiere: https://git-scm.com/download/win" }
if (-not (Test-Path (Join-Path $root ".git"))) {
  throw "Hier kein Klon. Einmal: git clone <deine-Repo-URL> und Ordner wählen."
}
& git -C $root pull
Write-Host "Aktuell (main)." -ForegroundColor Green
