@echo off
chcp 65001 >nul
title Loop - first push to GitHub Pages
cd /d D:\Projects\loop-blog

echo.
echo ========================================
echo  Before running this:
echo  1) Create empty repo on GitHub named: loop-blog
echo  2) Edit _config.yml url to:
echo     https://YOUR_USERNAME.github.io/loop-blog
echo  3) Replace YOUR_USERNAME below in this script if needed
echo ========================================
echo.

set /p GHUSER=Your GitHub username: 
if "%GHUSER%"=="" (
  echo Username required.
  pause
  exit /b 1
)

git init
git branch -M main
git add .
git status
echo.
set /p OK=Commit and push now? (y/n): 
if /i not "%OK%"=="y" exit /b 0

git commit -m "Initial Loop blog for GitHub Pages"
git remote remove origin 2>nul
git remote add origin https://github.com/%GHUSER%/loop-blog.git
git push -u origin main

echo.
echo Done. Next on GitHub website:
echo  Settings -^> Pages -^> Source = GitHub Actions
echo  Then open Actions tab, wait for green check.
echo  Site: https://%GHUSER%.github.io/loop-blog/
echo.
pause
