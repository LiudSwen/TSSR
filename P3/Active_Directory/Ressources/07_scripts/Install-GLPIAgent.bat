@echo off

REM === Configuration ===
SET SERVER=http://172.16.13.1
SET MSI=\\DOM-FS-01\departements\dsi\scripts\GLPI-Agent-1.15-x64.msi

REM === Vérifier si déjà installé ===
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s | find "GLPI Agent" >nul
if %ERRORLEVEL%==0 exit /b 0

REM === Installer ===
msiexec.exe /i "%MSI%" /qn ADDLOCAL=ALL SERVER=%SERVER% TAG=GPO RUNNOW=1 ADD_FIREWALL_EXCEPTION=1

exit /b
