# Remove snap apps and snap support from Ubuntu

## Important Notes:
There are a few minor things to keep in mind for the future before disabling Snap:

- **Ubuntu Release Upgrades:** When executing a full system upgrade to the next LTS version, the 
  do-release-upgrade process sometimes attempts to reinstall snapd. While your APT pin usually 
  blocks this, it is worth verifying that the pin is still active after a major OS upgrade.
- **Canonical-Specific GUI Tools:** Default utilities like the Ubuntu App Center and the new 
  Firmware Updater are exclusively Snap packages. You will need to use alternatives, such 
  as the standard GNOME Software center (which supports Flatpaks) and command-line tools 
  like fwupdmgr for firmware updates.
- **App Availability:** A small number of developers only package their software as Snaps. 

## 1. Remove all active Snaps
First, check what snaps are currently installed:

```bash
snap list
```

> Important: Snap packages have strict dependencies. Applications (like firefox or snap-store) 
> rely on frameworks (like gnome-42-2204) and base layers (like core22).
> You must always remove standard applications first, then frameworks and themes, then base 
> layers, and finally the snapd daemon.

Remove them one by one. You must remove standard applications (like Firefox, bare) before 
removing the core, base, and then snapd packages:

```bash
sudo snap remove --purge <package_name>
```

The removal order for default snap apps and packages on Ubuntu:

```bash
sudo snap remove --purge firefox firmware-updater snap-store
sudo snap remove --purge snapd-desktop-integration gtk-theme-orchis gtk-common-themes
sudo snap remove --purge gnome-42-2204 gnome-46-2404 mesa-2404
sudo snap remove --purge bare core22 core24
```

## 2. Purge the snapd package
Once all snap apps and core files are removed, uninstall the daemon:

```bash
sudo apt autoremove --purge snapd
```

## 3. Block snapd from reinstalling (The Fix)
To prevent any future apt updates or package installations from pulling snapd 
back in as a dependency, create an apt preference file that gives it a negative priority:

```bash
sudo tee /etc/apt/preferences.d/nosnap.pref <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
```

## 4. Clean up leftover directories
Remove the residual folders to reclaim space:

```bash
rm -rf ~/snap
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd
```

After doing this, run sudo apt update. Your system is now completely Snap-free.
