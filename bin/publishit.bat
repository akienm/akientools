@echo off

:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will read a value out c:\piblishitbat\config.ini, for section [main], key "source", and put the value into env var target01
@echo off
setlocal enabledelayedexpansion
:: Define the path to the config file
set "configFile=c:\piblishitbat\config.ini"
:: Read the value from the config file
for /f "tokens=1,2 delims==" %%A in ('findstr /i "source" "%configFile%"') do (
    if "%%A"=="source" (
        set "sharedrepo=%%B"
    )
)
:: Remove any leading or trailing spaces
set "sharedrepo=%sharedrepo:~1,-1%"
if
:: Display the value (for verification)
echo sharedrepo=%sharedrepo%

:: End of script
endlocal

:: Akien: Now sharedrepo has the location to publish to

:: prompt:
:: Using only CMD.EXE, I want
:: to generate a timestamp in the form yyyy-mm-dd-hh-mm-ss.mmmm_%USERNAME%, and then create a folder with that name.
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%.%datetime:~15,4%
set timestamp_and_author=%datetime%_%USERNAME%
set datetime=
mkdir %timestamp_and_author%

:: prompt:
:: Using only CMD.EXE, I want
:: a batch file that will delete all the subfolders in the current folder more than 11 days old
forfiles /p . /s /d -11 /c "cmd /c if @isdir==TRUE rd /s /q @path"

