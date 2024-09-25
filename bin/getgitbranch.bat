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
