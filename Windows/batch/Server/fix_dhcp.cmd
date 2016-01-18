@echo off

REM ########################################################
REM ## checking dhcp service permission
REM ########################################################
del %temp%\dhcpservice.log
echo reading registry permission for DHCP Client service...
sc query "DHCP" | find /i "state" >nul 2>nul
\\domain.tld\NETLOGON\subinacl.exe /nostatistic /noverbose /outputlog=%temp%\dhcpservice.log /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dhcp\Parameters /display


:: recognize os language
echo %USERPROFILE% |find /i "Documents" >nul 2>nul
if %errorlevel%==0  goto englisch_os

echo %USERPROFILE% |find /i "Dokumente" >nul 2>nul
if %errorlevel%==0  goto german_os

goto exit


:englisch_os
echo englisch os detected...
type %temp%\dhcpservice.log |find /i "network service" >nul 2>nul
if %errorlevel% NEQ 1 goto good_perm
goto e_set_perm

:german_os
echo german os detected...
type %temp%\dhcpservice.log |find /i "netzwerkdienst" >nul 2>nul
if %errorlevel% NEQ 1 goto good_perm
goto g_set_perm




:e_set_perm
echo reparing enlgisch os permissions...
\\domain.tld\NETLOGON\subinacl.exe /noverbose /subkeyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dhcp\Parameters /grant="network service"=F >nul 2>nul
echo starting dhcp service
sc start dhcp
goto exit

:g_set_perm
echo reparing german os permissions...
\\domain.tld\NETLOGON\subinacl.exe /noverbose /subkeyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dhcp\Parameters /grant="netzwerkdienst"=F >nul 2>nul
echo starting dhcp service
sc start dhcp
goto exit

:good_perm
echo permissions are correct. Nothing changed...
goto exit

:exit
