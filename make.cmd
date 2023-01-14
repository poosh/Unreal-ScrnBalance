@echo off

setlocal
color 07

cd /D ..\System
del ScrnUBalance.u

ucc make
set /A ERR=%ERRORLEVEL%
if %ERR% NEQ 0 goto error

if .%1. == ./i. (
	ucc dumpint ScrnUBalance.u
)

color 0A
echo --------------------------------
echo Compile successful.
echo --------------------------------
goto end

:error
color 0C
echo ################################
echo Compile ERROR! Code = %ERR%.
echo ################################

:end
endlocal & SET _EC=%ERR%
exit /b %_EC%
