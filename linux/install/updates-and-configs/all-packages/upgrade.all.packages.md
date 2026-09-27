# Upgrade All Packages

## APT Packages

For applications installed via `apt`, run:

```bash
sudo apt-get update
sudo apt-get upgrade
```

## Flatpak Packages

For applications installed via `flatpak`, run:

```bash
sudo flatpak update
```

## Snap Packages

For applications installed via `snap`, run:

```bash
sudo snap refresh
```

## Pacman Packages

For applications installed via `pacman`, run:

```bash
sudo pacman -Syyu
```
