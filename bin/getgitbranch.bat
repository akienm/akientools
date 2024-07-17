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
::   none
::
:: Returns:
::   via the console, the branch or nothing
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set myname=%temp%\getgitbranch
set raw=%myname%_raw.tmp
set filtered=%myname%_filtered.tmp
if exist %myname%*.tmp del %myname%*.tmp

git branch > %raw%
type %raw% | find "*" > %filtered%
<%filtered% set /p filteredData=
set filteredData=%filteredData:~2,2000%
echo %filteredData%

del %myname%*.tmp
