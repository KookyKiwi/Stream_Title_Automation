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


:: Checks if page is working
if /I "%STATUS_CODE%" neq "200" (
	echo %SAB_DATE%
	set "NO_SLL=no page"
	goto :skip_date
)

:: Splits date
set "YYYY=%SAB_DATE:~0,4%"
set "MM=%SAB_DATE:~5,2%"
set "DD=%SAB_DATE:~8,2%"

goto :skip_error_date


:skip_date


:: Gives date in case sabbath school page gives error
for /f "tokens=1-3 delims=/" %%a in ('powershell -NoProfile -Command "(Get-Date).AddDays((6 - [int](Get-Date).DayOfWeek + 7) %% 7).ToString('MM/dd/yyyy')"') do (
    set MM=%%a
    set DD=%%b
    set YYYY=%%c
)


:skip_error_date

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


:: Pipes month and day into morning devotional title finder and outputs status code and the morning devotional title
set i=0
for /f "usebackq delims=" %%A in (`python3 Scripts\MD_Title_Finder.py "%MM% %DD% %YYYY%"`) do (
	set /a i+=1
	if !i! equ 1 set "STATUS_CODE=%%A"
	if !i! equ 2 set "MD_TITLE=%%A"
)


:: Checks if page is working
if /I "%STATUS_CODE%" neq "200" (
	echo %MD_TITLE%
	set "MD_TITLE="
	set "NO_MD=no page"
) 


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

:: Dev log
echo couldnt find %DESKTOP%\*Stream Titles.txt

:found

if defined NO_SLL set "SKIP=1"
if defined NO_MD set "SKIP=1"

:: Will only overwrite previous stream title if both titles are present
if defined SKIP (
	if "%FOUND_FILE%"=="%MM%.%DD% - Stream Titles.txt" (
		echo %FOUND_FILE% has already been made
		goto :skip_file_creation
	)
)


if defined FOUND_FILE (
	del /Q "%DESKTOP%\%FOUND_FILE%"
)


:: Pipes the variables into a text file
(
    echo %MD%
    echo %SSL%
    echo %DS%
) > "%DESKTOP%\%MM%.%DD% - Stream Titles.txt"


:skip_file_creation

:: TEST
echo %MD%
echo %SSL%
echo %DS%


pause
