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

:done
echo git branch
git branch > con:
set gitbranch_target=
set gitbranch_parent=
