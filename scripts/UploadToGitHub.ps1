# Alles ins Repo packen und zu GitHub schieben. Auf dem Zweitrechner zuerst: AbholenVonGitHub.ps1
# Erstes Mal auf github.com: leeres Repo anlegen, dann: git remote add origin https://github.com/<du>/<name>.git
# Optional: winget install GitHub.cli, dann: gh auth login, gh repo create ... (siehe gh_create_and_push.sh)
# Aufruf (PowerShell im Projektordner):
#   .\scripts\UploadToGitHub.ps1
#   .\scripts\UploadToGitHub.ps1 -Message "Deine Commit-Nachricht"
param([string]$Message = "")
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$msg = if ($Message) { $Message } else { "Update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }

function Assert-Git {
  $null = & git --version 2>&1
  if ($LASTEXITCODE -ne 0) { throw "Git fehlt. Installiere: https://git-scm.com/download/win" }
}

Assert-Git
if (-not (Test-Path (Join-Path $root ".git"))) {
  & git -C $root init -b main
}

# Cross-Platform: keine falschen Zeilenenden für Skripte
& git -C $root config core.autocrlf true 2>$null

$status = & git -C $root status --porcelain
if ($status) {
  & git -C $root add -A
  & git -C $root commit -m $msg
  if ($LASTEXITCODE -ne 0) {
    $name = & git -C $root config user.name
    $email = & git -C $root config user.email
    if (-not $name -or -not $email) {
      Write-Host "Lege deinen Namen und E-Mail fest, z. B.:" -ForegroundColor Yellow
      Write-Host '  git config --global user.name "Vorname Nachname"' -ForegroundColor Yellow
      Write-Host '  git config --global user.email "deine@email"' -ForegroundColor Yellow
    }
    throw "Commit abgebrochen (siehe Meldung oben)."
  }
} else {
  Write-Host "Keine offenen Änderungen – entweder schon alles committet oder leer. Push folgt, falls sinnvoll."
}

$remotes = @(& git -C $root remote 2>$null)
$hasOrigin = $remotes -contains "origin"
if (-not $hasOrigin) {
  Write-Host "Noch kein origin. Beispiel:" -ForegroundColor Yellow
  Write-Host '  git remote add origin https://github.com/DEIN-USER/macro_tracker.git' -ForegroundColor Cyan
  Write-Host "Dann erneut: .\scripts\UploadToGitHub.ps1" -ForegroundColor Yellow
  exit 0
}

$branch = (& git -C $root rev-parse --abbrev-ref HEAD).Trim()
& git -C $root push -u origin $branch
if ($LASTEXITCODE -ne 0) {
  throw "git push fehlgeschlagen (Remote-URL pruefen, GitHub-Login/Token, oder Branch $branch)."
}
Write-Host "Fertig. Auf anderem Gerät: git pull oder AbholenVonGitHub.ps1" -ForegroundColor Green
