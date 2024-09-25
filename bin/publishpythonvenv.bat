@echo off
:: AkienSez: First and most important default (can be overridden)
set server_root=\\sacappautp34\software\publishpythonvenv
if not %1.==. set server_root=%1
goto main

:: AkienSez: Here be subroutines ---------------------------------------------------------------------------

:delete_more_than_10_days_old
:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will delete all the subfolders in the current folder more than 11 days old
forfiles /p %1 /s /d -11 /c "cmd /c if @isdir==TRUE rd /s /q @path"
exit /b

:: AkienSez: Here be main ---------------------------------------------------------------------------
:main
:: AkienSez: First we need to be in the right damn folder!

:: Prompt: Using only CMD.EXE, I want batch file fraagment that will set an environment variable called repo_root
:: to either "none" or to the folder containing .gitignore, starting with the current folder, and working our way
:: to the root. No find, repo_root=none. Otherwise, it is set to the folder location.
set "repo_root=none"
set "current_dir=%cd%"

:folder_loop
if exist "%current_dir%\.gitignore" (
    set "repo_root=%current_dir%"
    goto :folder_end
)
cd ..
if "%cd%"=="%current_dir%" goto :end
set "current_dir=%cd%"
goto :folder_loop

:folder_end
:: echo repo_root=%repo_root%

:: AkienSez: Now we know, check the result!

if %repo_root%.==none. (
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
if not exist %repo_root%\venv (
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
cd %repo_root%

:: AkienSez: This is where the meat of it begins. Now we fix the local everythings
:: AkienSez: On jenkins, we can create a hard link to the same foldername on D:

set local_root=c:\publishpythonvenv
if not exist %local_root% mkdir %local_root%
if not exist %local_root%\cached mkdir %local_root%\caches
set config_file=%local_root%\config.ini
if not exist %config_file% (
    if exist %server_root%\config.ini (
        copy %server_root%\config.ini %local_root%
    ) else (
        echo [main] > %config_file%
        echo sharedstorage=%server_root%\caches >> %config_file%
    )
)

:: AkienSez: Now we have a config.ini one way or another
:: AkienSez: Now we read it out

:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will read a value out c:\publishpythonvenv\config.ini, for section [main], key "sharedstorage", and put
:: the value into env var sharedstorage
setlocal enabledelayedexpansion
:: Read the value from the config file
for /f "tokens=1,2 delims==" %%A in ('findstr /i "sharedstorage" "%config_file%"') do (
    if "%%A"=="sharedstorage" (
        set "sharedstorage=%%B"
    )
)
:: Remove any leading or trailing spaces
set "sharedstorage=%sharedstorage:~1,-1%"

:: Display the value (for verification)
echo sharedstorage=%sharedstorage%
:: End of script

:: Akiensez: Now sharedrepo has the location to publish to

:: prompt:
:: Using only CMD.EXE, I want
:: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm_%USERNAME%, and then create a folder with that name.
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%
set timestamp_and_author=%datetime%_%USERNAME%
set datetime=
::mkdir %timestamp_and_author%

call getgitbranch /q
:: Akiensez: now we have branch in getgitbranch env var
set final_venv_name=%timestamp_and_author%_%getgitbranch%

:: AkienSez: Now we zip it up
:: prompt:
:: Using only CMD.EXE, I want
:: A batch file fragment that will take .\venv and compress a copy of it it in to %final_venv_name%.zip
powershell -command "Compress-Archive -Path .\venv -DestinationPath %local_root%\cached\%final_venv_name%.zip"

:: AkienSez: Now we copy the zip up
copy %local_root%\cached\%final_venv_name%.zip %sharedstorage%

:: AkienSez: Now we delete more than 11 days old on server
call delete_more_than_10_days_old %sharedstorage%

:: AkienSez: Now we noclobber xcopy the whole folder down (skip already present)
xcopy "%sharedstorage%\*" "%local_root%\cached" /E /I /Y /D

:: AkienSez: Now we delete more than 11 days old local
call delete_more_than_10_days_old %local_root%\cached

:close
endlocal
