# Ein Befehl: Git-Pfad, safe.directory, Remote, Commit (falls nötig), push master -> main
# PowerShell:  .\scripts\PushToGitHubQuick.ps1
# Bei "Repository not found": Windows Anmeldeinformationsverwaltung -> github-Einträge löschen, erneut pushen, Passwort = PAT (scope repo)
$ErrorActionPreference = "Stop"
$env:Path = "C:\Users\Don NQ\AppData\Local\Programs\Git\bin;" + $env:Path
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root ".git"))) { throw "Kein .git in $root" }

& git --version | Out-Null
$dir = $root -replace "\\", "/"
$null = & git config --global --add safe.directory $dir 2>$null

Set-Location $root
$rem = @(& git remote 2>$null)
if ($rem -contains "origin") { & git remote set-url origin "https://github.com/donpntlc/macro_tracker.git" }
else { & git remote add origin "https://github.com/donpntlc/macro_tracker.git" }

$s = & git status --porcelain
if ($s) { & git add -A; & git commit -m "quick $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }

& git push -u origin master:main
if ($LASTEXITCODE -ne 0) {
  Write-Host "Push fehlgeschlagen. Remote-URL in diesem Skript pruefen, GitHub-Login/Token, branch (master existiert?)" -ForegroundColor Yellow
  exit 1
}
Write-Host "Fertig." -ForegroundColor Green
