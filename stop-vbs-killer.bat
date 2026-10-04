@echo off
rem ============================================================
rem  stop-vbs-killer.bat - DISABLE boot auto-run of vbs-killer
rem  Double-click OK: auto-elevates via UAC.
rem  Stops vbs-killer from running at every boot/logon.
rem  Does NOT change the current VBS on/off state.
rem  (To also turn VBS back ON, run enable-vbs.bat.)
rem ============================================================
rem --- auto-elevate ---
fltmc >nul 2>&1 || powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
fltmc >nul 2>&1 || exit /b

echo [1/3] Removing scheduled task...
schtasks /delete /tn "FixVBS" /f >nul 2>&1

echo [2/3] Removing Startup folder / Run entries...
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\vbs-killer.bat" >nul 2>&1
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\fix-vbs-boot.bat" >nul 2>&1
del "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\vbs-killer.bat" >nul 2>&1
del "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\fix-vbs-boot.bat" >nul 2>&1
del "C:\fix-vbs-boot.bat" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "VBSKiller" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "VBSKiller" /f >nul 2>&1

echo [3/3] Clearing one-shot F3 boot entry...
bcdedit /deletevalue {bootmgr} bootsequence >nul 2>&1
bcdedit /delete {0cb3b571-2f2e-4343-a879-d86a476d7215} /f >nul 2>&1
mountvol X: /s >nul 2>&1
if exist X:\EFI\Microsoft\Boot\SecConfig.efi del X:\EFI\Microsoft\Boot\SecConfig.efi >nul 2>&1
mountvol X: /d >nul 2>&1

echo.
echo DONE. vbs-killer will NOT run at boot/logon anymore.
echo VBS state unchanged. Run enable-vbs.bat to turn VBS back ON.
pause
