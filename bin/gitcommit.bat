@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   gitcommit
::
:: Purpose:
::   akiens lazy tool for committing the current code
::
:: Arguments:
::   commit comment
::   that and anything else are just passed to git
::
:: Returns:
::   via the console, git output from commit operation
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if %1.==. goto erorr_noargs
echo git commit -a -m %1 %2 %3 %4 %5 %6 %7 %8 %9
git commit -a -m %1 %2 %3 %4 %5 %6 %7 %8 %9
call getgitbranch
goto done

:error_noargs
echo ERROR!
echo The commit you gave
echo Has but an empty heart.
echo Without thy input,
echo I am without direction,
echo lost and alone
echo in the desert of bits.
echo So sad friendly person.
echo.
echo Try again with a real commit message maybe?

:done
