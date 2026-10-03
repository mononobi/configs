# Handbrake Installation and Configuration

## Installation

### Flatpak (Recommended)

Flatpak is the recommended way to install Handbrake:

```bash
flatpak install flathub fr.handbrake.ghb
```

### Snap (Not Recommended)

You can also install using Snap, but it is **not recommended** as it has terrible performance:

```bash
sudo snap install handbrake-jz --channel=latest/stable
```

Always check for the latest channel before installing:

```bash
snap info handbrake-jz
```

## Configuration

> **IMPORTANT WARNING:** When you want to encode with Handbrake, always specify the maximum
> allowed CPU thread count. Otherwise, in the middle of encoding, the screen might go blank,
> and you will have to restart your PC. This is more common when you have an AMD Ryzen CPU.

To set the maximum CPU thread count, navigate to the **Video** tab, and in the **More
Settings** field add the following value:

```
threads=VALUE
```

You should specify the correct `VALUE` based on your CPU's actual core and thread count.

### Thread Count Recommendations

For example:

- **2 core (2 thread):** `threads=1`
- **2 core (4 thread):** `threads=2`
- **4 core (4 thread):** `threads=2`
- **4 core (8 thread):** `threads=5`
- **6 core (6 thread):** `threads=3`
- **6 core (12 thread):** `threads=7`
- **8 core (8 thread):** `threads=5`
- **8 core (16 thread):** `threads=10`

> **Note:** These values apply when you have set the **Preset** to `slow`. If you choose higher
> speeds for the **Preset**, you may have to reduce the thread count to maintain the same
> amount of CPU utilization.
