@echo off
chcp 65001 >nul
setlocal

if "%~1"=="" (
  echo Usage:
  echo   publish-post.cmd "D:\Notes\Loop-Vault\RM电控\post.md"
  echo.
  echo Or drag an md file onto this cmd.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-post.ps1" -Source "%~1"
echo.
pause
