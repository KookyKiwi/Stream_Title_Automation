@echo off

:: Puts the lesson number in the sabbath school title if equal to TRUE
set "DO_LESSON_NUMBER=TRUE"

setlocal enabledelayedexpansion

:: Gets the lesson number and the lesson name
set i=0
for /f "usebackq delims=" %%A in (`python3 Scripts\SSL_Title_Finder.py`) do (
    set /a i+=1
	if !i! equ 1 set "STATUS_CODE=%%A"
    if !i! equ 2 set "SAB_DATE=%%A"
    if !i! equ 3 set "LESSON_NUM=%%A"
    if !i! equ 4 set "LESSON_TITLE=%%A"
)

:: Checks if page exists or is working
if /I "%STATUS_CODE%"=="404" (
	echo Couldn't find sabbath school page :(
	pause
)

if /I "%STATUS_CODE%" neq 200 (
	echo There is a problem for the sabbath school page :(
	pause
	set "NO_SLL=no page"
)

:: Split by space
set "YYYY=%SAB_DATE:~0,4%"
set "MM=%SAB_DATE:~5,2%"
set "DD=%SAB_DATE:~8,2%"


:: Pipes month and day into morning devotional title finder and outputs the morning devotional for that date
for /f "delims=" %%i in ('python3 Scripts\MD_Title_Finder.py "%MM% %DD% %YYYY%"') do set "MD_TITLE=%%i"

if /I "%MD_TITLE%"=="404" (
	echo couldn't find morning devotional page :(
	pause
)

if /I "%MD_TITLE%" neq 200 (
	echo there is a problem for the morning devotional page :(
	pause
	set "NO_MD=no page"
)

if defined NO_MD if defined NO_SLL exit /b

:: Map month numbers to short names
if "%MM%"=="01" set "MON=Jan."
if "%MM%"=="02" set "MON=Feb."
if "%MM%"=="03" set "MON=Mar."
if "%MM%"=="04" set "MON=Apr."
if "%MM%"=="05" set "MON=May"
if "%MM%"=="06" set "MON=Jun."
if "%MM%"=="07" set "MON=Jul."
if "%MM%"=="08" set "MON=Aug."
if "%MM%"=="09" set "MON=Sept."
if "%MM%"=="10" set "MON=Oct."
if "%MM%"=="11" set "MON=Nov."
if "%MM%"=="12" set "MON=Dec."


:: Sets the titles to variables
set "MD=%MON% %DD% ^| Morning Devotional - "%MD_TITLE%""
if /I "%DO_LESSON_NUMBER%"=="true" (
    set "SSL=%MON% %DD% ^| Sabbath School Lesson #%LESSON_NUM% - "%LESSON_TITLE%""
) else (
    set "SSL=%MON% %DD% ^| Sabbath School - "%LESSON_TITLE%""
)
set "DS=%MON% %DD% ^| Divine Service - """


:: Finds the absolute path to desktop
for /f "delims=" %%a in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%a"


:: Finds previous stream titles txt file
for /f "delims=" %%f in ('dir /b "%DESKTOP%\*Stream Titles.txt" 2^>nul') do (
    set "FOUND_FILE=%%f"
    goto :found
)

:: Dev log for Testing
echo couldnt find %DESKTOP%\*Stream Titles.txt

:found

if defined FOUND_FILE (
	del /Q "%DESKTOP%\%FOUND_FILE%"
)

:: Pipes the variables into a text file
(
    echo %MD%
    echo %SSL%
    echo %DS%
) > "%DESKTOP%\%MM%.%DD% - Stream Titles.txt"

:: TEST
echo %MD%
echo %SSL%
echo %DS%


pause
