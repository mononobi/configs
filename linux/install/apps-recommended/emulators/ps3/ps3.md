# PS3 Emulator Guide

This is a guide for installing and configuring a PlayStation 3 (PS3) emulator.

## Installation

To install the RPCS3 emulator via Flatpak, run the following command:

```bash
flatpak install flathub net.rpcs3.RPCS3
```

## Firmware Setup

> **Note:** You must download the official PS3 firmware from Sony and install it within the
> application.

1. Download the firmware from the
   [official PlayStation support page](https://www.playstation.com/en-us/support/hardware/ps3/system-software/).
2. After the application installation is complete, install the downloaded firmware by
   navigating to **File -> Install Firmware** in the application menu.

## Game Directory Structure

For each game to work correctly, it must be organized into the following folder structure:

```
Game Title/
└── Region ID/
    ├── PS3_GAME/
    ├── PS3_UPDATE/ (optional)
    └── PS3_DISC.SFB
```

**Example:**

```
WRC 5/
└── BLES02242/
    ├── PS3_GAME/
    ├── PS3_UPDATE/
    └── PS3_DISC.SFB
```

- Inside the **Region ID** folder, the following subdirectories should exist:
  - `PS3_GAME`
  - `PS3_UPDATE` (optional)
- Inside the **Region ID** folder, the following file must exist:
  - `PS3_DISC.SFB`

## Adding Games to the Emulator

When adding games to the emulator application, you must select the **Game Title** folder (the
parent directory containing the Region ID folder).
