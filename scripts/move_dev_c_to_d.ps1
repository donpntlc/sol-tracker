# Einmalig: Entwicklungs-SDK/Caches von C: nach D: (wenig Platz auf C:).
# Erfordert PowerShell (ggf. als normaler User). Nach Abschluss: neues Terminal / Cursor.
#
# Was passiert (idempotent, wo sinnvoll):
#  1) Flutter: C:\dev\flutter  ->  D:\Dev\flutter  (wenn Ziel leer, robocopy)
#  2) Pub-Cache: %LOCALAPPDATA%\Pub\Cache  ->  D:\DevCache\flutter\pub-cache
#  3) User-Umgebungsvariablen: Path (flutter\bin), PUB_CACHE, GRADLE_USER_HOME, TEMP, TMP
#
# Alte C:\dev\flutter wird NICHT automatisch gelöscht — nach Test manuell umbenennen/löschen.

$ErrorActionPreference = "Stop"
$FlutterSrc = "C:\dev\flutter"
$FlutterDst = "D:\Dev\flutter"
$Base = "D:\DevCache\flutter"
$PubDst = Join-Path $Base "pub-cache"
$GradleDst = Join-Path $Base "gradle"
$TempDst = Join-Path $Base "temp"
$PubSrc = Join-Path $env:LOCALAPPDATA "Pub\Cache"

function Invoke-RobocopyOk {
  param([string[]]$Args)
  $p = Start-Process -FilePath "robocopy" -ArgumentList $Args -Wait -PassThru -NoNewWindow
  if ($p.ExitCode -le 7) { return }  # 0-7: robocopy success/partial
  throw "robocopy failed exit $($p.ExitCode)"
}

New-Item -ItemType Directory -Force -Path $Base, $PubDst, $GradleDst, $TempDst | Out-Null

if (Test-Path $FlutterSrc) {
  if (-not (Test-Path (Join-Path $FlutterDst "bin\flutter.bat"))) {
    New-Item -ItemType Directory -Force -Path $FlutterDst | Out-Null
    Write-Host "Kopiere Flutter: $FlutterSrc -> $FlutterDst" -ForegroundColor Cyan
    Invoke-RobocopyOk @($FlutterSrc, $FlutterDst, "/E", "/COPY:DAT", "/R:2", "/W:2", "/MT:8")
  } else { Write-Host "Flutter liegt schon auf D: (übersprungen)." -ForegroundColor DarkGray }
} else { Write-Host "Hinweis: $FlutterSrc nicht gefunden (übersprungen)." -ForegroundColor Yellow }

if (Test-Path $PubSrc) {
  if ((Get-ChildItem $PubDst -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
    Write-Host "Kopiere Pub-Cache: $PubSrc -> $PubDst" -ForegroundColor Cyan
    Invoke-RobocopyOk @($PubSrc, $PubDst, "/E", "/COPY:DAT", "/R:2", "/W:2", "/MT:8")
  } else { Write-Host "Pub-Cache Ziel hat schon Inhalt (übersprungen)." -ForegroundColor DarkGray }
}

$flutterBin = Join-Path $FlutterDst "bin"
$flutterExe = Join-Path $flutterBin "flutter.bat"
if (-not (Test-Path $flutterExe)) { throw "Erwartet: $flutterExe fehlt — Flutter-Kopie prüfen." }

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = $userPath -split ";" | Where-Object { $_ -and $_ -ne "C:\dev\flutter\bin" -and $_ -ne $flutterBin }
$parts = @($parts + $flutterBin) | Select-Object -Unique
[Environment]::SetEnvironmentVariable("Path", ($parts -join ";"), "User")

[Environment]::SetEnvironmentVariable("PUB_CACHE", $PubDst, "User")
[Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", $GradleDst, "User")
[Environment]::SetEnvironmentVariable("TEMP", $TempDst, "User")
[Environment]::SetEnvironmentVariable("TMP", $TempDst, "User")

$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
$env:PUB_CACHE = $PubDst
$env:GRADLE_USER_HOME = $GradleDst
$env:TEMP = $TempDst
$env:TMP = $TempDst

Write-Host "OK. User-PATH und TEMP/TMP/PUB_CACHE/GRADLE_USER_HOME auf D: gesetzt." -ForegroundColor Green
Write-Host "  Flutter:  $flutterExe" -ForegroundColor DarkGray
Write-Host "  PUB_CACHE: $PubDst" -ForegroundColor DarkGray
Write-Host "  TEMP/TMP:  $TempDst" -ForegroundColor DarkGray
Write-Host "Neues Terminal oeffnen, dann: flutter doctor" -ForegroundColor Yellow

$log = Join-Path $Base "last_migrate_log.txt"
@(
  "move_dev_c_to_d $(Get-Date -Format o)"
  "PUB_CACHE (User) = $([Environment]::GetEnvironmentVariable('PUB_CACHE', 'User'))"
  "Flutter bin in User-PATH: $((@(([Environment]::GetEnvironmentVariable('Path', 'User') -split ';') | Where-Object { $_ -and ($_ -match 'flutter') })) -join ', ')"
) | Set-Content -Path $log -Encoding utf8

& $flutterExe --version
exit 0
