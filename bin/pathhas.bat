@echo off
echo %PATH% | find "%1" > nul
if ERRORLEVEL=1 goto notfound
echo OK
goto done
:notfound
echo %1 %2 %3 %4 %5 %6 %7 %8
:done
