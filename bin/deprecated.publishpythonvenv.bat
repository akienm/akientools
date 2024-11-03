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
    echo To run this batch successfully... 
    echo.
    echo Normally all you have to do is run it. It sorts everything itself.
    echo there are no additional command line arguments except for those seeking
    echo help.
    echo.
    echo Sorry, but at the moment, the only way to know all is to read the code.
    echo But here's a sumation of important parts. You can pre-create any of the 
    echo folders or variables (makes for easy testing):
    echo.
    echo VENV_UPSTREAM  - file store on the server
    echo                  defaults to: \\sacappautp34\software\VENV_UPSTREAM
    echo VENV_STORE     - file store locally. Can be either:
    echo                  D:\ENV_STORE (checked for first)
    echo                  C:\ENV_STORE (checked for second)
    echo VENV_CONFIG    - local config file after execution and setup
    echo                  Usually VENV_STORE\VENV_CONFIG.ini
    echo VENV_REPO_ROOT - The root folder path of the repo to be published. Should 
    echo                  contain a venv to publish. Identified by the file because 
    echo                  it contains a file of any length called PUBLISHABLE.VENV.READY
    echo VENV_REPO_NAME - Folder name for the root of the repo.
    echo.
    echo Resulting zip is called:
    echo venv_yymmdd.hhmmss.msms_USERNAME_gitbranch_VENV_REPO_NAME.zip
    echo.
    echo Then it's copied up and a directory file created:
    echo VENV_UPSTREAM\cache.list.txt
    echo This is so Jenkins can read the available venvs.
    echo.
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
:: Akiensez: And we should now be in that folder

:: prompt:
:: Using only CMD.EXE, I want
:: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%

:: Akiensez: Included Module. See github/AkienTools
@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   getgitbranch
::
:: Purpose:
::   if you're in a folder that's a gitrepo, returns the name of the active
::   branch. called from many scripts.
::
:: Arguments:
::   /q means set the variable, but be quiet
::
:: Returns:
::   via the console, the branch or nothing
::   Leaves found branch in getgitbranch
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set myname=%temp%\getgitbranch
set raw=%myname%_raw.tmp
set found_branch=%myname%_found_branch.tmp
if exist %myname%*.tmp del %myname%*.tmp

git branch > %raw%
type %raw% | find "*" > %found_branch%
<%found_branch% set /p getgitbranch=
set getgitbranch=%getgitbranch:~2,2000%
if not %1.==/q echo %getgitbranch%

del %myname%*.tmp
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Akiensez: now we have branch in getgitbranch env var
set final_venv_name=venv_%datetime%_%USERNAME%_%getgitbranch%_%VENV_REPO_NAME%

:: Akiensez: Do we have to uninstall and reinstall the repo we're in?
:: pip uninstall ???
:: Need to know:
::   * What does this repo install itself as?
::   * Is it installed as writable?
::     Y: We should prolly uninstall it, but note we have to put it back
::   * We need to install it into the venv, from this location, but not as writable

:: AkienSez: Now we zip it up
:: prompt:
:: Using only CMD.EXE, I want
:: A batch file fragment that will take .\venv and compress a copy of it it in to %final_venv_name%.zip
powershell -command "Compress-Archive -Path .\venv -DestinationPath %VENV_STORE%\cache\%final_venv_name%.zip"

:: Akiensez: Here, if we uninstalled this repo from writable, then 
:: We need to reinstall it here.

:: AkienSez: Now we delete more than 11 days old local
call delete_more_than_10_days_old %VENV_STORE%\cache

:: AkienSez: Now we delete more than 11 days old on server
call delete_more_than_10_days_old %VENV_UPSTREAM%\cache

:: AkienSez: Now we copy the zip up
copy %VENV_STORE%\cache\%final_venv_name%.zip %VENV_UPSTREAM%\cache

:: AkienSez: Now we noclobber xcopy the whole folder down (skip already present)
xcopy "%VENV_UPSTREAM%\cache\*" "%VENV_STORE%\cache" /E /I /Y /D

:: AkienSez: Now we need to produce the output for jenkins to read
:: Prompt: I have a batch file, it produces a list in this way: dir /B /O:-N > output.txt
:: All the files in this folder are .zip files.
:: I want to show the list in the way the dir command does, except without the .zip extensions.
:: how?
> %VENV_UPSTREAM%\cache.list.txt (
    for /f "delims=" %%i in ('dir /B /O:-N %VENV_UPSTREAM%\cache\*.zip') do (
        set "filename=%%~ni"
        echo !filename!
    )
)
:close
endlocal
