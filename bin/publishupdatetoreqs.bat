@echo off

:: TODO: MOD BOTH SIDES OF THIS TO SORT OUT HOW TO PRESENT METADATA NAME, BUT GET FOLDERNAME BACK

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
    echo ~crying~ Oh, you must be in an actual repo folder when you run this batch!
    echo.
    echo Dispair! Sadness! Go there and please try again!
    echo.
    pause
    goto close
)

:: AkienSez: Now we know where we are!
cd %VENV_REPO_ROOT%
for %%I in (.) do set VENV_REPO_NAME=%%~nxI

:: Akiensez: we should now be in the repo folder

:: GET THE COMMIT ID for %VENV_REPO_ROOT%\lstaf\requirements_gui.txt
for /f %%i in ('git log -n 1 --pretty=format:%%H -- %VENV_REPO_ROOT%\lstaf\requirements_gui.txt') do set commit_hash=%%i

:: Extract the last 5 characters of the commit hash
set commit_id=!commit_hash:~-5!

:: Akiensez: now we have branch in getgitbranch env var
set final_venv_name=venv_%commit_id%_%VENV_REPO_NAME%

if not exist %VENV_UPSTREAM%\cache\%final_venv_name% (

    :: make our new home
    mkdir %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_gui.txt
    if not exist %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_gui.txt goto permissions_failure
    copy %VENV_REPO_ROOT%\lstaf\requirements_gui.txt %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_gui.txt\
    mkdir %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_api.txt
    copy %VENV_REPO_ROOT%\lstaf\requirements_api.txt %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_api.txt\

    :: prompt:
    :: Using only CMD.EXE, I want
    :: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm
    for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
    set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%

    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :: Akiensez: Included Module. See github/AkienTools
    :: Script: getgitbranch
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

    set final_metadata_string=venv_%datetime%_%username%_%commit_id%_%getgitbranch%_%VENV_REPO_NAME%
    echo %final_metadata_string% > %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_api.txt\%final_metadata_string%.metadata
    echo %final_metadata_string% > %VENV_UPSTREAM%\cache\%final_venv_name%_requirements_gui.txt\%final_metadata_string%.metadata
) 

:: AkienSez: Now we need to produce the output for jenkins to read
:: Prompt: I have a batch file, it produces a list in this way: dir /B /O:-N > output.txt
:: All the files in this folder are .zip files.
:: I want to show the list in the way the dir command does, except without the .zip extensions.
:: how?
dir /B /O:-N %VENV_UPSTREAM%\cache\ > %VENV_UPSTREAM%\cache.list.txt

:: AkienSez: Now we would like a CSV just in case Yuriy can use that :)

:: Prompt: Ok, here's a hard one for you. I have a cache folder called c:\cache. Inside of it will be a 
:: group of timestamped folders all starting with "venv_<something>". Inside of each of those folders 
:: is a file called venv_%USERNAME%_%datestamp%.metadata. in a cmd.exe batch file, I want to read each 
:: of those folders, and get the name portion of the .metadata file (removing the .metadata extension), 
:: and produce a csv file called c:\cache\cache.list.csv in the form:
:: venv_folder1, venv_dave_2024_01_01
:: venv_folder2, venv_john_2024_02_14
echo Folder, Metadata > "%VENV_UPSTREAM%\cache.list.txt"
for /d %%D in ("%VENV_UPSTREAM%\cache\venv_*") do (
    set "folder_name=%%~nxD"
    for %%F in ("%%D\*.metadata") do (
        set "file_name=%%~nF"
        echo !folder_name!, !file_name! >> %VENV_UPSTREAM%\cache.list.txt
    )
)

goto close

:permissions_failure
    echo.
    echo Oh Nos!
    echo I am so sad friendly person, but I can't help you with this but...
    echo.
    echo I couldn't create %VENV_UPSTREAM%\cache\%final_venv_name%
    echo.
    echo ~crying~ Oh, you must have permissions to write to that folder! ~sob~
    echo.
    echo Dispair! Sadness! 
    echo.
    echo GET HELP! GET AKIEN! TELL HIM YOU NEED PERMISSIONS TO WRITE TO 
    echo %VENV_UPSTREAM%
    echo.
    pause
    goto close

:close
