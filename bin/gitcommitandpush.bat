@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   gitcommitandpush
::
:: Purpose:
::   akiens lazy tool for committing and pushing the current code
::
:: Arguments:
::   %1 = commit message
::
:: Returns:
::   via the console, git output from commit operation
::
:: Dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call gitcommit %1 %2 %3 %4 %5 %6 %7 %8 %9
call gitpush /p