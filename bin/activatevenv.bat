@echo off

:: AkienSez: Here be main ---------------------------------------------------------------------------
:main

:: AkienSez: First and most important work out where the things we need are
if %VENV_UPSTREAM%.==. set VENV_UPSTREAM=\\sacappautp34\software\VENV_UPSTREAM

if %VENV_STORE%.==. set if exist D:\*.* set VENV_STORE=D:\VENV_STORE
if %VENV_STORE%.==. set if exist C:\ENV_STORE set VENV_STORE=C:\VENV_STORE

if not exist %VENV_STORE% mkdir %VENV_STORE%
if not exist %VENV_STORE%\cache mkdir %VENV_STORE%\cache


if not exist %VENV_UPSTREAM%\cache\%1 (
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

if not exist %VENV_STORE%\cache\%1 (
    venv --copies --clear %VENV_STORE%\cache\%1
    call %VENV_STORE%\cache\%1\scripts\activate
    pip install -r %VENV_UPSTREAM%\cache\%1\requirements_gui.txt
    mkdir %VENV_STORE%\cache\%1\metadata
    copy %VENV_UPSTREAM%\cache\%1\* %VENV_STORE%\cache\%1\metadata
)

call %VENV_STORE%\cache\%1\scripts\activate

:close
endlocal
