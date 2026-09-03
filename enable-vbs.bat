@echo off
rem ============================================================
rem  enable-vbs.bat - undo vbs-killer (run as ADMIN)
rem  Use when you WANT VBS back: Core Isolation / WSL2 /
rem  Windows Hello enhanced sign-in / Hyper-V, etc.
rem  1) removes boot-time auto-run of vbs-killer / fix-vbs-boot
rem  2) restores registry + BCD so VBS can start again
rem  3) RESTART after running
rem ============================================================

echo [1/5] Removing boot auto-run tasks...
schtasks /delete /tn "FixVBS" /f >nul 2>&1
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\vbs-killer.bat" >nul 2>&1
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\fix-vbs-boot.bat" >nul 2>&1
del "C:\fix-vbs-boot.bat" >nul 2>&1
echo       done.

echo [2/5] Re-enabling VBS in registry...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v HyperVVirtualizationBasedSecurityOptout /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" /v Enabled /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /f >nul 2>&1
echo       done.

echo [3/5] Allowing hypervisor at boot (BCD)...
bcdedit /set hypervisorlaunchtype auto
echo       done.

echo [4/5] Cleaning up vbs-killer boot entries...
bcdedit /deletevalue {bootmgr} bootsequence >nul 2>&1
bcdedit /delete {0cb3b571-2f2e-4343-a879-d86a476d7215} /f >nul 2>&1
mountvol X: /s >nul 2>&1
if exist X:\EFI\Microsoft\Boot\SecConfig.efi del X:\EFI\Microsoft\Boot\SecConfig.efi >nul 2>&1
mountvol X: /d >nul 2>&1
echo       done.

echo [5/5] Finished.
echo.
echo RESTART your PC now - VBS will start again.
echo NOTE: if you pressed F3 during a vbs-killer reboot, a UEFI
echo       opt-out flag may still block VBS. Re-enable features
echo       in Windows Security - Device security if needed.
pause
