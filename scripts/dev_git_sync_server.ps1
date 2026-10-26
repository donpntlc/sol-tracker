# Listens on http://127.0.0.1:18765/git-sync
# Receives POST from the Flutter web app (debug) every 3rd full refresh and runs git add / commit / push in this repo.
# Run in a second terminal while developing:  pwsh -File scripts/dev_git_sync_server.ps1

$ErrorActionPreference = "Stop"
$port = 18765
# PSScriptRoot = .../macro_tracker/scripts  ->  repo = parent folder
$repoRoot = Split-Path $PSScriptRoot -Parent

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$port/")

function Send-CorsResponse {
  param(
    [System.Net.HttpListenerResponse] $res,
    [int] $code,
    [string] $body = ""
  )
  $res.Headers.Add("Access-Control-Allow-Origin", "*")
  $res.Headers.Add("Access-Control-Allow-Methods", "POST, OPTIONS")
  $res.Headers.Add("Access-Control-Allow-Headers", "X-Dev-Git-Sync, Content-Type, Origin")
  $res.StatusCode = $code
  if ($body) {
    $enc = [System.Text.Encoding]::UTF8
    $buf = $enc.GetBytes($body)
    $res.ContentType = "application/json; charset=utf-8"
    $res.ContentLength64 = $buf.Length
    $res.OutputStream.Write($buf, 0, $buf.Length)
  }
  $res.Close()
}

$listener.Start()
Write-Host "Dev git sync server: http://127.0.0.1:$port/git-sync  (repo: $repoRoot)" -ForegroundColor Cyan
Write-Host "Run your app with flutter run -d chrome, refresh 3x to auto-push (debug only). Ctrl+C to stop." -ForegroundColor DarkGray

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  $path = $req.Url.AbsolutePath.TrimEnd("/")

  if ($req.HttpMethod -eq "OPTIONS") {
    Send-CorsResponse -res $res -code 204
    continue
  }

  if ($path -ne "/git-sync" -or $req.HttpMethod -ne "POST") {
    Send-CorsResponse -res $res -code 404 -body '{"ok":false,"err":"use POST /git-sync"}'
    continue
  }

  Push-Location $repoRoot
  try {
    if (-not (Test-Path ".git")) {
      Send-CorsResponse -res $res -code 500 -body '{"ok":false,"err":"not a git repo; run: git init && git remote add origin ... "}'
      continue
    }

    git add -A 2>&1 | Out-Null
    $st = git status --porcelain 2>&1
    if ([string]::IsNullOrWhiteSpace($st)) {
      Send-CorsResponse -res $res -code 200 -body '{"ok":true,"msg":"nothing to commit"}'
      continue
    }

    $msg = "chore: dev auto-sync (every 3rd web refresh) $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    $commitOut = git commit -m $msg 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
      $j = @{ ok = $false; err = "commit failed"; detail = $commitOut.Trim() } | ConvertTo-Json -Compress
      Send-CorsResponse -res $res -code 500 -body $j
      continue
    }

    $pushOut = git push 2>&1 | Out-String
    $pushExit = $LASTEXITCODE
    if ($pushExit -ne 0) {
      $j = @{
        ok = $false
        err = "git push failed"
        detail = $pushOut
      } | ConvertTo-Json -Compress
      Send-CorsResponse -res $res -code 500 -body $j
      continue
    }

    $j = @{
      ok = $true
      commit = $msg
      output = $pushOut.Trim()
    } | ConvertTo-Json -Compress
    Send-CorsResponse -res $res -code 200 -body $j
  } finally {
    Pop-Location
  }
}
