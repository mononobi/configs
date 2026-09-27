# Mednaffe Retro Console Emulator

This app can emulate many retro consoles, including:

- Atari Lynx
- Neo Geo Pocket (Color)
- WonderSwan
- GameBoy (Color)
- GameBoy Advance
- Nintendo Entertainment System (Micro)
- Super Nintendo Entertainment System/Super Famicom
- Virtual Boy
- PC Engine/TurboGrafx 16 (CD)
- SuperGrafx
- PC-FX
- Sega Game Gear
- Sega Genesis/Megadrive
- Sega Master System
- Sega Saturn (experimental, x86_64 only)
- Sony PlayStation

## Installation

```bash
flatpak install flathub com.github.AmatCoder.mednaffe
```

## Post-Installation Setup

To be able to load your games into the app, you should give access to the games folders.
You can execute this command once for each folder you want to give access to:

```bash
sudo flatpak override --filesystem=PATH_TO_GAMES_FOLDER com.github.AmatCoder.mednaffe
```

### Example:

```bash
sudo flatpak override --filesystem="/mnt/archives-1/Applications/Emulators/Games/Retro" com.github.AmatCoder.mednaffe
```

> **IMPORTANT:** If you have no sound coming out from games, you should try different
> sound drivers in the settings: `Global Settings -> Sound -> Driver` Try different
> drivers to see which one will work. On Ubuntu, the `sdl` driver works.
