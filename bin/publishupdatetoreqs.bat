@echo off

:: AkienSez: Here be main ---------------------------------------------------------------------------
:main

:: AkienSez: First and most important work out where the things we need are
if %VENV_UPSTREAM%.==. set VENV_UPSTREAM=\\sacappautp34\software\VENV_UPSTREAM

if %VENV_STORE%.==. set if exist D:\*.* set VENV_STORE=D:\VENV_STORE
if %VENV_STORE%.==. set if exist C:\ENV_STORE set VENV_STORE=C:\VENV_STORE

if not exist %VENV_STORE% mkdir %VENV_STORE%
if not exist %VENV_STORE%\cache mkdir %VENV_STORE%\cache


:: AkienSez: Now we need to be in the right damn folder!

:: Prompt: Using only CMD.EXE, I want batch file fraagment that will set an environment variable called VENV_REPO_ROOT
:: to either "none" or to the folder containing .gitignore, starting with the current folder, and working our way
:: to the root. No find, VENV_REPO_ROOT=none. Otherwise, it is set to the folder location.
if %VENV_REPO_ROOT%.==. set VENV_REPO_ROOT=none
set "current_dir=%cd%"

:folder_loop
if exist "%current_dir%\lstaf\requirements_gui.txt" (
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

:: AkienSez: Now we know where we are!
cd %VENV_REPO_ROOT%
for %%I in (.) do set VENV_REPO_NAME=%%~nxI

:: Akiensez: Now server_root has the location to publish to
:: Akiensez: And we should now be in the repo folder

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

:: GET THE COMMIT ID
for /f %%i in ('git log -n 1 --pretty=format:%%H -- %VENV_REPO_ROOT%\lstaf\requirements_gui.txt') do set commit_hash=%%i

REM Extract the last 5 characters of the commit hash
set commit_id=!commit_hash:~-5!

:: Akiensez: now we have branch in getgitbranch env var
set final_venv_name=venv_%commit_id%_%getgitbranch%_%VENV_REPO_NAME%

if not exist %VENV_UPSTREAM%\cache\%final_venv_name% (
    :: Akiensez: And we should now be in the repo folder
    :: prompt:
    :: Using only CMD.EXE, I want
    :: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm
    for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
    set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%

    mkdir %VENV_UPSTREAM%\cache\%final_venv_name%
    copy %VENV_REPO_ROOT%\lstaf\requirements*.txt %VENV_UPSTREAM%\cache\%final_venv_name%
    echo venv_%datetime%_%username%_%commit_id%_%getgitbranch%_%VENV_REPO_NAME% > venv_%datetime%_%username%_%commit_id%_%getgitbranch%_%VENV_REPO_NAME%.metadata
) 

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
