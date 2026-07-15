@echo off
chcp 65001 >nul
title Loop fix images + restart server
cd /d D:\Projects\loop-blog

echo [1] Copy images from Obsidian assets...
if not exist "source\images" mkdir "source\images"
copy /Y "D:\Notes\Loop-Vault\assets\Pasted image 20260715085308.png" "source\images\Pasted-image-20260715085308.png"
copy /Y "D:\Notes\Loop-Vault\assets\Pasted image 20260715113146.png" "source\images\Pasted-image-20260715113146.png"

if not exist "source\images\Pasted-image-20260715085308.png" (
  echo FAILED: cannot find assets images. Open D:\Notes\Loop-Vault\assets and check filenames.
  pause
  exit /b 1
)

echo [2] Rebuild...
call npx hexo clean
call npx hexo generate

echo [3] Restart server on 4000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
start "Loop Hexo" cmd /k "cd /d D:\Projects\loop-blog && npx hexo server -p 4000"
timeout /t 3 >nul
start http://localhost:4000/2026/07/15/1.2-PWM/

echo Done. Check images and formulas.
pause
