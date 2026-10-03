@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo  *** Sticky Focus ***
echo.

:: Add common Node.js locations to PATH
for %%P in (
  "%ProgramFiles%\nodejs"
  "%LOCALAPPDATA%\Programs\nodejs"
  "%ProgramFiles(x86)%\nodejs"
) do (
  if exist "%%~P\node.exe" set "PATH=%%~P;!PATH!"
)

where node >nul 2>&1
if errorlevel 1 (
  echo  [ERROR] Node.js not found. Install from: https://nodejs.org/
  pause & exit /b 1
)

for /f "tokens=*" %%V in ('node -v 2^>nul') do echo  Node.js: %%V

if not exist node_modules (
  echo  Installing dependencies...
  call npm install
  if errorlevel 1 ( echo  [ERROR] npm install failed. & pause & exit /b 1 )
)

echo  Starting...
echo.

if exist node_modules\.bin\electron.cmd (
  node_modules\.bin\electron.cmd . --enable-logging 2>crash-log.txt
) else (
  npx --no electron . --enable-logging 2>crash-log.txt
)

set EXIT_CODE=%errorlevel%
if %EXIT_CODE% neq 0 (
  echo.
  echo  [App exited with code %EXIT_CODE%]
  echo  ----------------------------------------
  if exist crash-log.txt (
    type crash-log.txt
  )
  echo  ----------------------------------------
  echo  Copy the text above and send it.
  echo.
  pause
)
