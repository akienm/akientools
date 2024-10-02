@echo off
:: publishpythonenv.bat
:: Orig Akien Maciain 10/1/24
:: 
:: Usage
if %1.==/?. goto usage
if %1.==-?. goto usage
if %1.==-h. goto usage
if %1.==-H. goto usage
if %1.==/h. goto usage
if %1.==/H. goto usage
if %1.==/help. goto usage
if %1.==/Help. goto usage
if %1.==/HELP. goto usage
if %1.==--help. goto usage
if %1.==--Help. goto usage
if %1.==--HELP. goto usage
:: and if it matches none of those, then the default is to get started
goto main

:usage
    echo.
    echo fetchpthonvenvs.bat
    ehco.
    echo Hello friendly person!
    echo.
    echo My job is to fetch venvs to the shared space on the network.
    echo.
    echo -Akien
    echo.
    echo.
    goto close
:: Note that usage does not allow the user to do anything else.
:: This is to keep the flow of control simple.

:: AkienSez: Here be subroutines ---------------------------------------------------------------------------

:delete_more_than_10_days_old
:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will delete all the subfolders in the current folder more than 11 days old
forfiles /p %1 /s /d -11 /c "cmd /c if @isdir==TRUE rd /s /q @path"
exit /b


:: AkienSez: This is where the meat of it begins. Now we fix the local everythings
:: AkienSez: On jenkins, we can create a hard link to the same foldername on D:
:: Before running the companion 


:: AkienSez: Here be main ---------------------------------------------------------------------------
:main
:: AkienSez: First and most important default (can be overridden)
:: VENV_UPSTREAM can be set from outside (for testing!)
if %VENV_UPSTREAM%.==. set VENV_UPSTREAM=\\sacappautp34\software\VENV_UPSTREAM

if %VENV_STORE%.==. set if exist D:\ENV_STORE set VENV_STORE=D:\VENV_STORE
if %VENV_STORE%.==. set if exist C:\ENV_STORE set VENV_STORE=C:\VENV_STORE

if not exist %VENV_STORE% mkdir %VENV_STORE%
if not exist %VENV_STORE%\cache mkdir %VENV_STORE%\cache

if not %VENV_CONFIG%.==. set VENV_CONFIG=%VENV_STORE%\VENV_CONFIG.ini
if not exist %VENV_CONFIG% (
    if exist %VENV_UPSTREAM%\config.ini (
        copy %VENV_UPSTREAM%\config.ini %local_root%
    ) else (
        echo [main] > %VENV_CONFIG%
        echo VENV_UPSTREAM=%VENV_UPSTREAM% >> %VENV_CONFIG%
    )
)

:: AkienSez: Now we have a config.ini one way or another
:: AkienSez: Now we read it out

:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will read a value out c:\publishpythonvenv\config.ini, for section [main], key "VENV_UPSTREAM", and put
:: the value into env var server_root
setlocal enabledelayedexpansion
:: Read the value from the config file
for /f "tokens=1,2 delims==" %%A in ('findstr /i "VENV_UPSTREAM" "%VENV_CONFIG%"') do (
    if "%%A"=="VENV_UPSTREAM" (
        set "VENV_UPSTREAM=%%B"
    )
)
:: Remove any leading or trailing spaces
set "VENV_UPSTREAM=%VENV_UPSTREAM:~1,-1%"

:: Display the value (for verification)
:: echo VENV_UPSTREAM=%VENV_UPSTREAM%
:: End of script


:: AkienSez: Now we noclobber xcopy the whole folder down (skip already present)
xcopy "%VENV_UPSTREAM%\cache\*" "%VENV_STORE%\cache" /E /I /Y /D

:: AkienSez: Now we delete more than 11 days old local
call delete_more_than_10_days_old %VENV_STORE%\cache

if exist 

:close
endlocal
