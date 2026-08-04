@echo off
rem =============================================
rem Boot-time fallback: silently re-apply VBS off
rem Install:
rem   copy this file to C:\fix-vbs-boot.bat
rem   schtasks /create /tn "FixVBS" /tr "C:\fix-vbs-boot.bat" /sc onlogon /ru SYSTEM /rl HIGHEST /f
rem Uninstall:
rem   schtasks /delete /tn "FixVBS" /f
rem =============================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v HyperVVirtualizationBasedSecurityOptout /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f
bcdedit /set hypervisorlaunchtype off
exit
