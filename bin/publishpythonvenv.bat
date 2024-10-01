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
    echo publishpythonvenv.bat
    ehco.
    echo Hello friendly person!
    echo.
    echo My job is to publish your venv to the shared space on the network. This
    echo network publishing system will both push to jfrog, but also push a venv
    echo that Jenkins can just download and activcate to save pip install time.
    echo.
    echo To run this batch successfully... (this is the long part) it needs config 
    echo info. It can get those thru an INI file, environment variables, or built
    echo in defaults. 
    echo.
    echo Sorry, but at the moment, the only way to know all is to read the code.
    echo But here's a sumation of important parts:
    echo.
    echo VENV_UPSTREAM  - store on the server
    echo                  defaults to: \\sacappautp34\software\VENV_UPSTREAM
    echo VENV_STORE     - store locally. Can be either:
    echo                  D:\ENV_STORE (checked for first)
    echo                  C:\ENV_STORE (checked for second)
    echo VENV_CONFIG    - local config file after execution and setup
    echo                  Usually VENV_STORE+
    echo VENV_REPO_ROOT - The repo to be published
    echo VENV_REPO_NAME - derived from repo folder that has PUBLISHABLE.VENV.READY in it
    echo.
    echo All can be overridden by simply creating them before hand. Same with:
    echo.
    echo.
    echo And
    echo.
    echo \\sacappautp34\software\VENV_UPSTREAM
    echo.
    echo Resulting zip is called:
    echo venv_yymmdd.hhmmss.msms_USERNAME_gitbranch_VENV_REPO_NAME.zip
    echo.
    echo Then it's copied up.
    echo -Akien
    echo.
    echo.
    goto close
:: Note that usage does not allow the user to do anything else.
:: This is to keep the flow of control simple.


:: AkienSez: This is where the meat of it begins. Now we fix the local everythings
:: AkienSez: On jenkins, we can create a hard link to the same foldername on D:
:: Before running the companion 

:: AkienSez: Here be subroutines ---------------------------------------------------------------------------

:delete_more_than_10_days_old
:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will delete all the subfolders in the current folder more than 11 days old
forfiles /p %1 /s /d -11 /c "cmd /c if @isdir==TRUE rd /s /q @path"
exit /b


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


:: AkienSez: So now there is a local config file
:: AkienSez: Whether built from environment variables
:: AkienSez: a server based copy or a preexisting 
:: AkienSez: local copy.
:: AkienSez: What's all this bs for? 
:: AkienSez: Thing the first: Self testing
:: AkienSez: Thing the second: I wanna be able to reuse much of this

:: AkienSez: Now we need to be in the right damn folder!

:: Prompt: Using only CMD.EXE, I want batch file fraagment that will set an environment variable called VENV_REPO_ROOT
:: to either "none" or to the folder containing .gitignore, starting with the current folder, and working our way
:: to the root. No find, VENV_REPO_ROOT=none. Otherwise, it is set to the folder location.
if %VENV_REPO_ROOT%.==. set VENV_REPO_ROOT=none
set "current_dir=%cd%"

:folder_loop
if exist "%current_dir%\PUBLISHABLE.VENV.READY" (
    set "VENV_REPO_ROOT=%current_dir%"
    goto :folder_end
)
cd ..
if "%cd%"=="%current_dir%" goto :end
set "current_dir=%cd%"
goto :folder_loop

:folder_end
:: echo VENV_REPO_ROOT=%VENV_REPO_ROOT%

:: AkienSez: Now we know, check the result!

if %VENV_REPO_ROOT%.==none. (
    echo.
    echo Oh Nos!
    echo I am so sad friendly person, but I can't help you with this but...
    echo.
    echo You're not in a repo folder!
    echo.
    echo ~crying~ Oh, you must be in an actual repo folder when you rubn publishpythonenv!
    echo.
    echo Dispair! Sadness! Please try again!
    echo.
    goto close
)

:: AkienSez: Do we even have a venv?
if not exist %VENV_REPO_ROOT%\venv (
    echo.
    echo Oh Nos!
    echo I am so sad friendly person, but I can't help you with this but...
    echo.
    echo There's no venv here!
    echo.
    echo ~crying~ Oh, you you have to actually have a venv to push up!
    echo.
    echo Dispair! Sadness! Please try again!
    echo.
    goto close
)

:: AkienSez: Now we know where we are!
cd %VENV_REPO_ROOT%
for %%I in (.) do set VENV_REPO_NAME=%%~nxI


:: Akiensez: Now server_root has the location to publish to

:: prompt:
:: Using only CMD.EXE, I want
:: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%


call getgitbranch /q
:: Akiensez: now we have branch in getgitbranch env var
set final_venv_name=venv_%datetime%_%USERNAME%_%getgitbranch%_%VENV_REPO_NAME%

:: AkienSez: Now we zip it up
:: prompt:
:: Using only CMD.EXE, I want
:: A batch file fragment that will take .\venv and compress a copy of it it in to %final_venv_name%.zip
powershell -command "Compress-Archive -Path .\venv -DestinationPath %local_root%\cached\%final_venv_name%.zip"

:: AkienSez: Now we copy the zip up
copy %local_root%\cached\%final_venv_name%.zip %server_root%\cached

:: AkienSez: Now we delete more than 11 days old on server
call delete_more_than_10_days_old %server_root%\cached

:: AkienSez: Now we noclobber xcopy the whole folder down (skip already present)
xcopy "%server_root%\cached\*" "%local_root%\cached" /E /I /Y /D

:: AkienSez: Now we delete more than 11 days old local
call delete_more_than_10_days_old %local_root%\cached

:close
endlocal
