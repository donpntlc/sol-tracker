@echo off
set PATH=%LOCALAPPDATA%\Programs\Git\bin;%PATH%
cd /d "%~dp0.."
git remote set-url origin "https://github.com/donpntlc/macro_tracker.git"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PushToGitHubQuick.ps1"
pause
