@echo off
chcp 65001 >nul
title Loop - Publish PWM
cd /d D:\Projects\loop-blog

echo [1/4] Clean old demo posts (keep 1.2-PWM.md only)...
if exist "source\_posts\hello-loop.md" del /f /q "source\_posts\hello-loop.md"
if exist "source\_posts\1-7can.md" del /f /q "source\_posts\1-7can.md"
if exist "source\_posts\rm-1-0-welcome.md" del /f /q "source\_posts\rm-1-0-welcome.md"
if exist "source\_posts\cpp-1-0-welcome.md" del /f /q "source\_posts\cpp-1-0-welcome.md"

echo [2/4] Copy images from Obsidian assets...
if not exist "source\images" mkdir "source\images"
copy /Y "D:\Notes\Loop-Vault\assets\Pasted image 20260715085308.png" "source\images\Pasted-image-20260715085308.png" >nul
copy /Y "D:\Notes\Loop-Vault\assets\Pasted image 20260715113146.png" "source\images\Pasted-image-20260715113146.png" >nul
if not exist "source\images\Pasted-image-20260715085308.png" (
  echo ERROR: image 1 missing. Check Obsidian assets folder.
  pause
  exit /b 1
)
if not exist "source\images\Pasted-image-20260715113146.png" (
  echo ERROR: image 2 missing. Check Obsidian assets folder.
  pause
  exit /b 1
)

echo [3/4] Build site...
call npx hexo clean
call npx hexo generate
if errorlevel 1 (
  echo ERROR: hexo generate failed
  pause
  exit /b 1
)

echo [4/4] Start preview server...
start http://localhost:4000/
start "Loop Hexo" cmd /k "cd /d D:\Projects\loop-blog && npx hexo server -p 4000"

echo.
echo OK. Open: http://localhost:4000/
echo Article: PWM呼吸灯  (tag: RM电控)
echo.
pause
