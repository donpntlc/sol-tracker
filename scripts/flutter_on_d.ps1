# Ruft `flutter` / `dart` / `pub` so auf, dass temporäre Dateien und Pub-Cache
# unter D: landen (statt C: AppData/Temp) — sinnvoll bei wenig Platz auf C:.
#
# Beispiel (im Projektroot, PowerShell):
#   .\scripts\flutter_on_d.ps1 run -d chrome
#   .\scripts\flutter_on_d.ps1 pub get
#   .\scripts\flutter_on_d.ps1 build web
#
# Dauerhaft fürs System: In Windows "Umgebungsvariablen" mindestens TEMP, TMP,
# PUB_CACHE (und optional GRADLE_USER_HOME) auf Pfade unter D: setzen, dann
# neu anmelden oder IDE/Cursor neu starten.

$ErrorActionPreference = "Stop"
$Base = "D:\DevCache\flutter"
$TempDir = Join-Path $Base "temp"
$PubDir = Join-Path $Base "pub-cache"
$GradleDir = Join-Path $Base "gradle"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
New-Item -ItemType Directory -Force -Path $PubDir | Out-Null
New-Item -ItemType Directory -Force -Path $GradleDir | Out-Null
$env:TEMP = $TempDir
$env:TMP = $TempDir
$env:PUB_CACHE = $PubDir
$env:GRADLE_USER_HOME = $GradleDir
Write-Host "TEMP/TMP  -> $TempDir" -ForegroundColor DarkGray
Write-Host "PUB_CACHE -> $PubDir" -ForegroundColor DarkGray
Write-Host "GRADLE_USER_HOME -> $GradleDir" -ForegroundColor DarkGray
if ($args.Count -eq 0) {
  Write-Host "Usage: flutter_on_d.ps1 <flutter-args...>" -ForegroundColor Yellow
  exit 1
}
& flutter @args
exit $LASTEXITCODE
