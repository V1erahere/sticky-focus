@echo off
setlocal
set TOKEN=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
set REPO=sticky-focus
set USER=V1erahere

echo === Sticky Focus :: GitHub Setup ===
echo.

:: 1. Create repo via GitHub API
echo [1/4] Creating repository on GitHub...
curl -s -X POST ^
  -H "Authorization: token %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"%REPO%\",\"description\":\"Pomodoro timer sticky-note widget for Windows\",\"homepage\":\"https://%USER%.github.io/%REPO%\",\"private\":false}" ^
  https://api.github.com/user/repos > nul
echo     Done.

:: 2. Init git
echo [2/4] Initialising git...
git init
git branch -M main
git remote remove origin 2>nul
git remote add origin https://%USER%:%TOKEN%@github.com/%USER%/%REPO%.git
echo     Done.

:: 3. Commit
echo [3/4] Committing files...
git add -A
git commit -m "Initial commit: Sticky Focus app + landing page"
echo     Done.

:: 4. Push
echo [4/4] Pushing to GitHub...
git push -u origin main
echo     Done.

:: 5. Enable GitHub Pages (docs folder)
echo [5/5] Enabling GitHub Pages...
curl -s -X PUT ^
  -H "Authorization: token %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"source\":{\"branch\":\"main\",\"path\":\"/docs\"}}" ^
  https://api.github.com/repos/%USER%/%REPO%/pages > nul
echo     Done.

echo.
echo === All done! ===
echo Repo:    https://github.com/%USER%/%REPO%
echo Landing: https://%USER%.github.io/%REPO%
echo (Landing page takes 1-2 minutes to go live)
echo.
pause
