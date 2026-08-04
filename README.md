# CASS 虚拟环境检测修复（VBS Killer）

解决 CASS11 等软件在**物理机**上被误报"不要在虚拟机中运行"的问题。

## 问题根因

Windows 11 默认启用 **VBS（基于虚拟化的安全性）**，轻量级 hypervisor 随系统运行，CPUID 指令暴露 `Microsoft Hv` 特征。CASS 的授权检测把该特征误判为虚拟机环境，拒绝运行。

典型现象：运行关闭脚本后立即有效（VBS 服务停止），**重启后失效**——因为 VBS 会被以下机制在开机时重新拉起：

1. DeviceGuard 注册表配置（`EnableVirtualizationBasedSecurity`）
2. **Windows Hello 增强登录安全性**（`VSM Required`，Win11 24H2+ 默认开启）
3. 启动链签名强制（`Boot Chain Signer Soft Enforced`）

事件日志佐证（`Kernel-Boot` 事件 153）：

```
基于虚拟化的安全性(策略: VBS Enabled, VSM Required, Boot Chain Signer Soft Enforced) 是 enabled due to VBS registry configuration
```

## 解决方案

`vbs-killer.bat` 一次写入全部关闭项（多重保险）：

| 层面 | 操作 |
|---|---|
| 注册表 | `EnableVirtualizationBasedSecurity=0`（显式关闭而非删除） |
| 注册表 | `Scenarios\WindowsHello\Enabled=0`（消除 VSM Required 来源） |
| 注册表 | `Scenarios\HypervisorEnforcedCodeIntegrity\Enabled=0`（关闭内存完整性） |
| 注册表 | `HyperVVirtualizationBasedSecurityOptout=1`（注册表 opt-out） |
| 策略 | `Policies\Microsoft\Windows\DeviceGuard\*=0`（阻止更新/策略恢复） |
| BCD | `hypervisorlaunchtype=off` |
| UEFI | SecConfig.efi 一次性启动项 → 重启按 F3 写入 UEFI opt-out 变量（最高优先级） |

## 使用方法

1. 右键 `vbs-killer.bat` → **以管理员身份运行**
2. **重启电脑**
3. 过了 BIOS 自检、屏幕出现**黑白字符提示**时，**狂按 F3**，直到电脑自动重启
4. 完成，CASS 不再报虚拟机

> ⚠️ F3 提示是**一次性**的（bootsequence），错过需重新运行脚本再重启。

## 验证

```bash
python cpuid-check.py
```

- `hypervisor present` 应为 `False`
- `hypervisor vendor` 应为空（修复前为 `Microsoft Hv`）

或查看事件日志：`eventvwr → Windows 日志 → 系统 → Kernel-Boot 事件 153`，应显示 `disabled due to opt-out UEFI variable`。

## 保底方案（Windows 更新重置时）

```bash
copy fix-vbs-boot.bat C:\fix-vbs-boot.bat
schtasks /create /tn "FixVBS" /tr "C:\fix-vbs-boot.bat" /sc onlogon /ru SYSTEM /rl HIGHEST /f
```

每次登录前自动以 SYSTEM 权限重新应用注册表/BCD 关闭项。

## 回滚

```bat
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f
bcdedit /set hypervisorlaunchtype auto
```

## 免责声明

关闭 VBS 会降低 Credential Guard / 内核隔离等安全性，请仅在解决软件兼容性问题时使用，并确保软件授权合法。
