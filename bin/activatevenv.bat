@echo off

:: TODO: Full Docs

:: %1 is the requirements entry name... commitID_repo
:: %2 is which requirements file to activate for... REQUIRED! 
::    as of this writing, requirements_gui.txt and requirements_api.txt are allowed
:: AND NO CHECKING IS DONE BY THIS FILE SO YOU'RE ON YOUR OWN!
:: SO BEWARE!
:: AkienSez: Here be main ---------------------------------------------------------------------------
:main

:: AkienSez: First and most important work out where the things we need are
if %VENV_UPSTREAM%.==. set VENV_UPSTREAM=\\sacappautp34\software\VENV_UPSTREAM

if %VENV_STORE%.==. set if exist D:\jenkins\*.* set VENV_STORE=D:\VENV_STORE
if %VENV_STORE%.==. set if exist C:\ENV_STORE set VENV_STORE=C:\VENV_STORE

if not exist %VENV_STORE% mkdir %VENV_STORE%
if not exist %VENV_STORE%\cache mkdir %VENV_STORE%\cache


if not exist %VENV_UPSTREAM%\cache\%2 (
    echo.
    echo Oh Nos!
    echo I am so sad friendly person, but I can't help you with this but...
    echo.
    echo The specified things on the command line...
    echo which is: %2 
    echo is not found in %VENV_UPSTREAM%\cache
    echo.
    echo Check it out:
    echo dir of that folder:
    dir %VENV_UPSTREAM%\cache
    echo.
    echo ~crying~ Oh, i can't imagine how this happened! ~sob~
    echo.
    echo GET HELP! GET AKIEN! TELL HIM I COULDN'T FIND
    echo %VENV_UPSTREAM%\%2
    echo IT'S OUR ONLY HOPE!
    echo.
    echo ~ Dispair! ~sniffle~ Sadness! ~
    echo.
    goto close
)

if not exist %VENV_STORE%\cache\%2\scripts\activate.bat (
    venv --copies --clear %VENV_STORE%\cache\%2
    call %VENV_STORE%\cache\%2\scripts\activate.bat
    pip install -r %VENV_UPSTREAM%\cache\%2\requirements.txt
    mkdir %VENV_STORE%\cache\%2\metadata
    copy %VENV_UPSTREAM%\cache\%2\* %VENV_STORE%\cache\%2\metadata
)

call %VENV_STORE%\cache\%2\scripts\activate

:close
