@echo off
cls

set /P servername=Bitte Servernamen eingeben:
if "%servername%"=="" set servername=%COMPUTERNAME%
cls

set /P zonename=Bitte Zonennamen eingeben:
if "%zonename%"=="" set zonename=%USERDNSDOMAIN%
cls

FOR /F "tokens=1,4" %%a IN (dns.txt) DO (
echo.
echo Fuege Host %%a mit IP %%b der Zone %zonename% auf Server %servername% hinzu...
echo.
echo dnscmd %servername% /RecordAdd %zonename% %%a A %%b
echo.
echo.
dnscmd %servername% /RecordAdd %zonename% %%a A %%b
echo.
)
pause >nul
