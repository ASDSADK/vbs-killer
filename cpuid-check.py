# -*- coding: utf-8 -*-
# 直接执行 CPUID 指令，检测 hypervisor 是否存在及其厂商
import ctypes, struct

# rcx=leaf, rdx=subleaf, r8=输出缓冲区(ebx,ecx,edx 连续 12 字节)
code = bytes([
    0x53,              # push rbx
    0x89, 0xC8,        # mov eax, ecx
    0x89, 0xD1,        # mov ecx, edx
    0x0F, 0xA2,        # cpuid
    0x41, 0x89, 0x18,  # mov [r8], ebx
    0x41, 0x89, 0x48, 0x04,  # mov [r8+4], ecx
    0x41, 0x89, 0x50, 0x08,  # mov [r8+8], edx
    0x5B,              # pop rbx
    0xC3,              # ret
])

k32 = ctypes.windll.kernel32
k32.VirtualAlloc.restype = ctypes.c_void_p
k32.VirtualAlloc.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint32, ctypes.c_uint32]
MEM_COMMIT, MEM_RESERVE, PAGE_EXECUTE_READWRITE = 0x1000, 0x2000, 0x40
buf = k32.VirtualAlloc(None, len(code), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE)
ctypes.memmove(buf, code, len(code))

PROTO = ctypes.CFUNCTYPE(None, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p)
f = PROTO(buf)

def cpuid(leaf, sub=0):
    out = (ctypes.c_uint32 * 3)()
    f(leaf, sub, ctypes.addressof(out))
    return out[0], out[1], out[2]

def chars(v):
    return struct.pack("<I", v).decode("latin1")

ebx, ecx, edx = cpuid(0)
print("CPU 厂商:", chars(ebx) + chars(edx) + chars(ecx))

ebx, ecx, edx = cpuid(1)
hv = bool(ecx & (1 << 31))
print("CPUID leaf1 ECX[31] hypervisor present:", hv)

ebx, ecx, edx = cpuid(0x40000000)
vendor = chars(ebx) + chars(ecx) + chars(edx)
print("hypervisor vendor (leaf 0x40000000):", repr(vendor))

if vendor.strip("\x00"):
    ebx, ecx, edx = cpuid(0x40000010)
    print("leaf 0x40000010 signature:", hex(ebx), hex(ecx), hex(edx))
