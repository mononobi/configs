# Diable Snap Installation for Firefox

## 1. Block the Ubuntu Firefox transition package
This assigns a negative priority specifically to Firefox packages originating from Ubuntu's 
repositories, completely preventing the Snap trigger:

```bash
sudo tee /etc/apt/preferences.d/firefox-no-snap.pref <<EOF
Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1
EOF
```

## 2. Ensure the Mozilla repository is prioritized
If you haven't already, confirm your Mozilla preference file is set correctly to 
prioritize their official packages:

```bash
sudo tee /etc/apt/preferences.d/mozilla-firefox.pref <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
```

## 3. Uninstall the Snap Version

```bash
sudo snap remove --purge firefox
```

## 4. Remove Ubuntu Firefox Repository

```bash
sudo add-apt-repository --remove ppa:mozillateam/ppa
sudo rm /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-noble.sources.save
sudo apt update
```
