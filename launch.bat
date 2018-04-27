::@echo off 
setlocal enabledelayedexpansion
set time_test=1431
set lastOpenedTime=00:00:00.00
set lastOpenedDate=00-00-0000
set defaultTime=00:00:00.00

:loop

:: Reading last opened time
For /F "eol=# tokens=1* delims==" %%A IN (config.properties) DO (
    IF %%A==lastOpenedTime set lastOpenedTime=%%B
	IF %%A==lastOpenedDate set lastOpenedDate=%%B
	IF %%A==defaultTime set defaultTime=%%B
)
:: Removes the escape characters added by java in config.properties
:: Formula is SET varname2=%varname1:stringtoreplace=replacement%
set lastOpenedTime=%lastOpenedTime:\=%
set defaultTime=%defaultTime:\=%

:: Current date in a locale independent manner
:: Go through this link: https://stackoverflow.com/questions/3472631/how-do-i-get-the-day-month-and-year-from-a-windows-cmd-exe-script/33402280#33402280

for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set TodayDay=0%%L
        set TodayMonth=0%%M
        set TodayYear=%%N
    )
)
set TodayDay=%TodayDay:~-2%
set TodayMonth=%TodayMonth:~-2%

IF %TodayYear%-%TodayMonth%-%TodayDay% GTR %lastOpenedDate% (
    ECHO Today is after the last opened date.
) ELSE (
    ECHO Today is on or before the last opened date.
	goto skip
)

IF %time% GEQ %defaultTime% (
	java -jar fbBirthdayPostUI.jar
)
:skip

IF %TodayYear%-%TodayMonth%-%TodayDay% LSS %lastOpenedDate% (	
	set /a "TodayDay=1%TodayDay%-1"
) ELSE (
	goto skipUpdateFile
)

 set "TodayDay=%TodayDay:~-2%"
 type config.properties | findstr /v lastOpenedDate > config1.properties
 type config1.properties > config.properties
 set sha=%TodayYear%-%TodayMonth%-%TodayDay%
 :: echo. is used to append a new line
 echo.lastOpenedDate=%sha% >> config.properties
 del config1.properties

:skipUpdateFile
:: Timeout is used to make the program stop for a specified time.
:: If /NOBREAK is used, no keypress will restart the program else it will.
:: >NUL is used to not to print the waiting status of timeout 

TIMEOUT /T %time_test% /NOBREAK >NUL
goto loop