@echo off
chcp 65001 >nul
cd /d D:\Projects\loop-blog
call npx hexo clean
call npx hexo generate
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
start "Loop Hexo" cmd /k "cd /d D:\Projects\loop-blog && npx hexo server -p 4000"
timeout /t 4 >nul
start http://localhost:4000/2026/07/15/1.2-PWM/
echo Restarted. Soft-refresh the page (Ctrl+F5).
pause
