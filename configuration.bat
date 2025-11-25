@echo off
setlocal

:: =====================================================
::  CHECK PYTHON INSTALLATION
:: =====================================================
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Python is not installed or not added to PATH.
    echo.
    echo Please install Python 3.x from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

:: =====================================================
::  CHECK PIP
:: =====================================================
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] pip not found — attempting to install it...
    python -m ensurepip --default-pip
    if %errorlevel% neq 0 (
        echo [!] Failed to install pip. Please install manually.
        pause
        exit /b 1
    )
)

:: =====================================================
::  INSTALL REQUIRED PACKAGES
:: =====================================================
set "REQ_PACKAGES=requests beautifulsoup4 selenium webdriver-manager"

echo Checking and installing required Python packages...
for %%p in (%REQ_PACKAGES%) do (
    python -m pip show %%p >nul 2>&1
    if errorlevel 1 (
        echo Installing required package: %%p...
        python -m pip install %%p --quiet
    ) else (
        echo %%p is already installed.
    )
)
echo.

echo.
echo [v] Python and required modules are ready.
echo.

:: =====================================================
::  CREATE SHORTCUT
:: =====================================================
setlocal enabledelayedexpansion

:: Get desktop path
for /f "delims=" %%a in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%a"

:: Get script folder
set "SCRIPT_DIR=%~dp0"

:: Check for icon
set "ICON_PATH="
for /f "delims=" %%f in ('dir /b "%SCRIPT_DIR%Icon\*.ico" 2^>nul') do (
    set "ICON_PATH=%SCRIPT_DIR%Icon\%%f"
    goto :found
)

echo [!] Missing icon. Creating shortcut without icon...
goto :create

:found
echo [+] Found icon: %ICON_PATH%

:create
:: Remove old shortcut if it exists
if exist "%DESKTOP%\Create Stream Titles.lnk" del "%DESKTOP%\Create Stream Titles.lnk"

:: Create shortcut (with or without icon)
if defined ICON_PATH (
    powershell -NoProfile -Command ^
      "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\Create Stream Titles.lnk');" ^
      "$s.TargetPath='%SCRIPT_DIR%Name Stream Titles.cmd';" ^
      "$s.WorkingDirectory='%SCRIPT_DIR%';" ^
      "$s.IconLocation='%ICON_PATH%';" ^
      "$s.Save()"
) else (
    powershell -NoProfile -Command ^
      "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\Create Stream Titles.lnk');" ^
      "$s.TargetPath='%SCRIPT_DIR%Name Stream Titles.cmd';" ^
      "$s.WorkingDirectory='%SCRIPT_DIR%';" ^
      "$s.Save()"
)

echo.
echo [v] Shortcut created on: %DESKTOP%
pause
exit /b
