@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   gitpush
::
:: Purpose:
::   akiens lazy tool for pushing current branch to github
::
:: Arguments:
::   branch name to push
::
:: Returns:
::   via the console, whatever git returns
::
:: Raises:
::   displays error if the branch name provided doesn't match the current
::   branch name, for safety.
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if %1.==. goto no_branch

call getgitbranch /q

if %1.==/p. goto perform_pull
if not %1.==%getgitbranch%. goto branch_mismatch

:perform_pull
echo Now performing git pull on %getgitbranch%
git config --global merge.message "Merge"
git pull --no-edit
echo Now performing git push origin %1...
git push origin %getgitbranch%
goto done

:no_branch
echo ERROR!
echo Thou doth not specify a branch!
echo Thou does't attempt confuse and confile me :(
echo.
echo If thou does't tell me which branch to push,
echo then should I be good.
echo.
echo but for this, akien won't let me
goto done

:branch_mismatch
echo.
echo ERROR!
echo These vile branches doth not match!
echo you're on %gitpush_current_actual_branch%
echo but you asked to push %gitpush_requested_branch%
echo Nay, I Cry
echo.
echo So sad friendly person but
echo akien won't let me

:done
