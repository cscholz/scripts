@echo off
cls

set /P servername=Bitte Servernamen eingeben:
if "%servername%"=="" set servername=%COMPUTERNAME%
cls

set /P zonename=Bitte Zonenname eingeben:
cls

FOR /F "tokens=1,4" %%a IN (dns.txt) DO (
echo.
FOR /F "tokens=1,2,3,4 delims=." %%c IN ("%%b") DO (
if "%zonename%"=="" set zonename=%%e.%%d.%%c
echo Fuege Host %%a mit IP %%b der Reverse Lookup Zone %zonename%.in-addr.arpa auf Server %servername% hinzu...
echo.
echo dnscmd %servername% /RecordAdd %%e.%%d.%%c.in-addr.arpa %%f ptr %%a.%zonename%
echo.
echo.
rem dnscmd %servername% /RecordAdd %%e.%%d.%%c.in-addr.arpa %%f ptr %%a.%zonename%
)
echo.
)
pause >nul
