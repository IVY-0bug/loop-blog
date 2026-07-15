@echo off
chcp 65001 >nul
title Loop - push to IVY-0bug/loop-blog
cd /d D:\Projects\loop-blog

echo [1] Init git if needed...
if not exist ".git" git init
git branch -M main

echo [2] Stage all files...
git add .
git status

echo.
echo [3] Commit...
git commit -m "Initial Loop blog for GitHub Pages" 2>nul
if errorlevel 1 (
  git commit -m "Update Loop blog" 2>nul
)

echo [4] Set remote...
git remote remove origin 2>nul
git remote add origin https://github.com/IVY-0bug/loop-blog.git

echo [5] Push (login popup may appear)...
git push -u origin main

echo.
echo ==============================
echo If push succeeded, do this on GitHub:
echo 1. Repo Settings -^> Pages
echo 2. Source = GitHub Actions
echo 3. Open Actions tab, wait for green check
echo 4. Visit: https://IVY-0bug.github.io/loop-blog/
echo ==============================
pause
