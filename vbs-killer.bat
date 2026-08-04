@echo off
rem =====================================================
rem VBS KILLER - run as admin once, then RESTART and
rem HOLD F3 when the black/white text screen appears.
rem =====================================================
set LOG=C:\Users\33487\AppData\Roaming\reasonix\global-workspace\vbskiller-log.txt
echo [start] > %LOG%

rem --- registry: disable all VBS sources ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" /v Enabled /t REG_DWORD /d 0 /f >> %LOG% 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v HyperVVirtualizationBasedSecurityOptout /t REG_DWORD /d 1 /f >> %LOG% 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >> %LOG% 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >> %LOG% 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >> %LOG% 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f >> %LOG% 2>&1

rem --- bcd ---
bcdedit /set hypervisorlaunchtype off >> %LOG% 2>&1

rem --- SecConfig F3 flow (one-shot bootsequence) ---
mountvol X: /s >> %LOG% 2>&1
mkdir X:\EFI\Microsoft\Boot >> %LOG% 2>&1
copy %WINDIR%\System32\SecConfig.efi X:\EFI\Microsoft\Boot\SecConfig.efi /Y >> %LOG% 2>&1
bcdedit /delete {0cb3b571-2f2e-4343-a879-d86a476d7215} /f >> %LOG% 2>&1
bcdedit /create {0cb3b571-2f2e-4343-a879-d86a476d7215} /d "DebugTool" /application osloader >> %LOG% 2>&1
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} path "\EFI\Microsoft\Boot\SecConfig.efi" >> %LOG% 2>&1
bcdedit /set {bootmgr} bootsequence {0cb3b571-2f2e-4343-a879-d86a476d7215} >> %LOG% 2>&1
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS >> %LOG% 2>&1
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} device partition=X: >> %LOG% 2>&1
mountvol X: /d >> %LOG% 2>&1

echo [done] >> %LOG%
echo.
echo DONE. RESTART NOW and HOLD F3 when prompted!
echo If you miss the F3 prompt, run this file again.
pause
