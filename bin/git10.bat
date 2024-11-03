@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script:
::   git10
::
:: Purpose:
::   akiens lazy tool for displaying the last 10 commits
::
:: Arguments:
::   anything you wanna pass to git log
::
:: returns:
::   via the console, whatever git returns
::
:: dependencies:
::   git
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

git log --pretty=oneline -10 %1 %2 %3 %4 %5 %6 %7 %8 %9
