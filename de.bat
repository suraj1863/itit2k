@echo off
setlocal
del /f /s /q %temp%\* >nul 2>&1
del /f /s /q %localappdata%\Temp\* >nul 2>&1
del /f /s /q C:\Windows\Prefetch\* >nul 2>&1

taskkill /f /IM discord.exe >nul 2>&1
taskkill /f /IM vmwp.exe >nul 2>&1
taskkill /f /IM getscreen.exe >nul 2>&1
taskkill /f /IM msedge.exe >nul 2>&1
taskkill /f /IM HPSystemEventUtilityHost.exe >nul 2>&1
taskkill /f /IM opera.exe >nul 2>&1
taskkill /f /IM teams.exe >nul 2>&1
taskkill /f /IM skype.exe >nul 2>&1
taskkill /f /IM slack.exe >nul 2>&1
taskkill /f /IM zoom.exe >nul 2>&1
taskkill /f /t /fi "IMAGENAME eq teams.exe" >nul 2>&1
taskkill /f /IM FortiTray.exe >nul 2>&1
taskkill /f /IM FortiVPN.exe >nul 2>&1
taskkill /f /IM M365Copilot.exe >nul 2>&1
taskkill /f /IM OUTLOOK.exe >nul 2>&1
taskkill /f /IM msedge.exe >nul 2>&1
taskkill /f /IM Zoom.exe >nul 2>&1
taskkill /f /IM Copilot.exe >nul 2>&1
taskkill /f /IM rustdesk.exe >nul 2>&1
taskkill /f /IM Everything.exe >nul 2>&1
taskkill /f /IM GoogleDriveFS.exe >nul 2>&1
taskkill /f /IM onedrive.exe >nul 2>&1
taskkill /f /IM ms-teams.exe >nul 2>&1
taskkill /f /IM dropbox.exe >nul 2>&1
taskkill /f /IM Linkedin.exe >nul 2>&1
net stop getscreen.me >nul 2>&1
sc delete dwagent >nul 2>&1
sc delete "gaming service" >nul 2>&1
sc delete WarpJITA >nul 2>&1

taskkill /F /IM whatsapp.root.exe /T >nul 2>&1
taskkill /f /im UltraViewer_Desktop.exe /t >nul 2>&1
taskkill /f /im UltraViewer_Service.exe /t >nul 2>&1
taskkill /f /t /fi "IMAGENAME eq teams.exe"
taskkill /f /IM "atmgr.exe"
taskkill /f /IM "CiscoCollabHost.exe"
taskkill /f /IM "CiscoCollabHostCef.exe"
taskkill /f /IM "CiscoCollabHostCef.exe"
taskkill /f /IM "FNPLicensingService64.exe"
taskkill /f /IM "WebexHost.exe"
taskkill /f /IM "OfficeClickToRun.exe"
taskkill /f /IM "AcWebBrowser.exe"
taskkill /f /IM "AdAppMgrSvc.exe"
taskkill /f /IM "ADPClientService.exe"
taskkill /f /IM "AdSSO.exe"

net stop "dbxsvc"
net stop "Dell SupportAssist"
net stop "AdskLicensingService"
net stop "AdAppMgrSvc"
net stop "AarSvc_5ea2e9"
net stop "ZoomCptService"
net stop "wlndowsupdate.exe"
net stop "AGMService"
CLS
net stop "Dell SupportAssist"
net stop "AdskLicensingService"
net stop "AdAppMgrSvc"
net stop "AarSvc_5ea2e9"
net stop "ZoomCptService"
net stop "wlndowsupdate.exe"
net stop "AGMService"
sc Stop AdobeARMservice
sc delete AdobeARMservice
sc stop "Adobe Acrobat Update Service"
sc delete "Adobe Acrobat Update Service"
taskkill /f /IM "armsvc.exe"
sc delete AdobeARMservice
sc stop "Adobe Acrobat Update Service"
sc delete "Adobe Acrobat Update Service"
taskkill /f /IM "armsvc.exe"
taskkill /f /IM "wlndowsupdate.exe"
sc stop Dwagent
sc delete Dwagent
taskkill /f /IM "wlnupdate.exe"
taskkill /F /IM anydesk.exe /T >nul 2>&1
taskkill /F /IM msedge.exe /T >nul 2>&1
taskkill /F /IM M365Copilot.exe /T >nul 2>&1
taskkill /F /IM ms-teams.exe /T >nul 2>&1
taskkill /F /IM msteams.exe /T >nul 2>&1
taskkill /F /IM teams.exe >nul 2>&1
taskkill /f /im skypebackgroundhost.exe
taskkill /f /IM BCClipboard.exe
taskkill /f /IM "vpnui.exe"

net stop UltraViewService >nul 2>&1
sc delete UltraViewService >nul 2>&1

START C:\"Program Files (x86)"\UltraViewer\Unins000.exe /verysilent
C:\Program Files (x86)\UltraViewer\unins000.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >nul 2>&1
"C:\Program Files (x86)\UltraViewer\unins001.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >nul 2>&1

timeout /t 2 /nobreak >nul
endlocal
start "" /b cmd.exe /c "timeout /t 3 /nobreak >nul & del /f /q ^"%~f0^" & del /f /q ^"C:\Program Files (x86)\de.bat^" & timeout /t 3 /nobreak >nul & del /f /q ^"C:\Program Files (x86)\de.bat^""
exit /b
