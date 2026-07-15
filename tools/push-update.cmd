@echo off
chcp 65001 >nul
title Loop - push updates to GitHub
cd /d D:\Projects\loop-blog

git add .
git status
echo.
set /p MSG=Commit message (or Enter for default): 
if "%MSG%"=="" set MSG=update blog content

git commit -m "%MSG%"
git push

echo.
echo Pushed. Wait for Actions green, then refresh the site.
echo https://IVY-0bug.github.io/loop-blog/
pause
