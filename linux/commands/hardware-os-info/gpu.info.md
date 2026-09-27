# GPU Information Commands

CLI commands to query GPU hardware, memory allocation, and driver diagnostics.

## Quick Summary

Display basic GPU identity and PCI bus info:

```bash
lspci | grep -i vga
```

## Detailed Video Memory (VRAM)

Check total dedicated and available video memory:

```bash
# Recommended: Detailed OpenGL & VRAM information
glxinfo | grep -i "video memory"
```

```bash
# Alternative: Query kernel ring buffer for VRAM detection
sudo dmesg | grep -i vram
```

## AMD GPU Diagnostics

Inspect kernel driver initialization and state for AMD graphics:

```bash
sudo dmesg | grep -i amdgpu
```
