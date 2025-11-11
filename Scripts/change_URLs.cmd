@echo off
setlocal enabledelayedexpansion

echo Press ENTER for no change
echo New Morning Devotional URL:
set /p MD_URL=

if "%MD_URL%"=="" (
    echo No change
) else (
    echo.
    set /p CONFIRMATION=Enter [Y,n] for confirmation: 
    echo.
    if /I "!CONFIRMATION!"=="y" (
        echo %MD_URL% > ".MD_URL"
        echo Saved: %MD_URL%
    ) else (
        echo Change canceled
    )
)

echo.
echo Press ENTER for no change
echo New Sabbath School URL:
set /p SSL_URL=

if "%SSL_URL%"=="" (
    echo No change
) else (
    echo.
    set /p CONFIRMATION=Enter [Y,n] for confirmation: 
    echo.
    if /I "!CONFIRMATION!"=="y" (
        echo %SSL_URL% > ".SSL_URL"
        echo Saved: %SSL_URL%
    ) else (
        echo Change canceled
    )
)

echo.
pause
endlocal
