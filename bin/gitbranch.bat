@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   gitbranch
::
:: Purpose:
::   akiens lazy tool for creating a branch.
::
:: Arguments:
::   none = display branches
::   %1 alone = new branch name off current branch
::   %1 with %2 =
::       %1 = parent branch
::       %2 = new branch name
::
:: Returns:
::   via the console, whatever git returns
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if %1.==. goto done
if %2.==. goto one_use_default_target
if %1.==/?. goto usage
if %1.==/h. goto usage
if %1.==/H. goto usage
if %1.==-?. goto usage
if %1.==-h. goto usage
if %1.==-H. goto usage
if %1.==-help. goto usage
if %1.==--help. goto usage
if %1.==--usage. goto usage

:both
set gitbranch_target=%2
set gitbranch_parent=%1
goto now_do_the_work

:one_use_default_target
set gitbranch_target=%1
set gitbranch_parent=develop

:now_do_the_work
echo git checkout %gitbranch_parent%
git checkout %gitbranch_parent%
echo git pull
git pull
echo git checkout -b %gitbranch_target%
git checkout -b %gitbranch_target%
echo git branch --set-upstream-to origin/%gitbranch_parent%
git branch --set-upstream-to origin/%gitbranch_parent%
goto done

:usage
echo.
echo Running gitbranch with no arguments just outputs
echo the same thing you'd get by just typying git branch -vv
echo.
echo Rrunning it with one argument creates a new branch off
echo develop that has the specified name.
echo.
echo Running it with two arguments creates the second branch name
echo from the first branch name. 
echo.
echo In all cases where it's creating a new branch, it fetches
echo the latest on that branch before creating the new one.
echo.
echo Have a lovely day.
echo.

:done
echo git branch
git branch -vv > con:
set gitbranch_target=
set gitbranch_parent=
