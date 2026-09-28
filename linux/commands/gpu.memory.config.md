# Dedicated GPU Memory (VRAM) Configuration for Integrated GPUs

Guidelines for configuring dedicated video RAM (VRAM) for processors with integrated
graphics (iGPUs) such as AMD APUs or Intel HD/UHD/Iris GPUs.

---

## BIOS/UEFI Configuration Steps

1. Restart your PC and press `Del` or `F2` during startup to enter the BIOS/UEFI menu.
2. Locate the integrated graphics settings, typically labeled:
   - **UMA Frame Buffer Size**
   - **VRAM Size**
   - **Integrated Graphics Memory Allocation**
3. Select your desired allocation size.
4. Save changes (`F10`) and reboot into the operating system.

---

## Allocation Sizing Guide

Recommended static allocation is between **10% and 20%** of total installed physical RAM:

| Total System RAM | Dedicated GPU VRAM |
| :--------------- | :----------------- |
| **> 64 GB**      | 12 GB              |
| **64 GB**        | 10 GB              |
| **32 GB**        | 5 GB               |
| **16 GB**        | 2.5 GB             |
| **8 GB**         | 1 GB               |
| **4 GB**         | 512 MB (0.5 GB)    |
| **2 GB**         | 256 MB (0.25 GB)   |

---

## Best Practice Recommendation

> [!TIP]
> On modern Linux kernels, it is recommended to set this configuration to
> **`Auto`** or a minimal static base (e.g., **512 MB**). The Linux kernel graphics
> drivers (e.g., `amdgpu`, `i915`) dynamically allocate and release system memory to the
> GPU on demand. Dedicating an excessively large static chunk of RAM permanently deprives
> the OS of memory needed for CPU tasks, which can degrade overall system performance.
