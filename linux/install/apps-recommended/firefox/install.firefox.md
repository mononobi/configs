# Firefox Installation Guide

## Install on Ubuntu <= 21.10

```bash
sudo apt-get install firefox
```

## Install on Ubuntu >= 22.04

Remove the Snap version if you currently have it installed:

```bash
sudo snap remove firefox
sudo rm /usr/bin/firefox
```

Create the apt keyrings directory if you do not already have it:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

Import the Mozilla APT repository signing key:

```bash
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
```

Create the `.gnupg` directory if it does not exist:

```bash
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
```

Verify the fingerprint:

```bash
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
```

> **Note:** The expected fingerprint is `35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`.

Add the Mozilla APT repository:

```bash
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
```

Configure APT to prioritize packages from the Mozilla repository. Execute these lines all at once:

```bash
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
```

Update your package list and install Firefox:

```bash
sudo apt-get update && sudo apt-get install firefox
```

> **Reference:** For more information, see the [official Mozilla installation guide](https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions-recommended).

## Install Using Flatpak

> **Warning:** This installation method is known to have some issues.

```bash
flatpak install flathub org.mozilla.firefox
```

## Post-Installation Settings

Open Firefox, type the following into the URL bar, and press Enter:

```
about:config
```

Search for each of the following preferences and set them to `true`:

```
layers.acceleration.force-enabled
gfx.webrender.all
```

> **Note:** If these changes cause any issues with your browsing experience, revert them to `false`.

## Note on Wayland

> **Note:** If you use Wayland, refer to the `wayland/firefox.wayland.issues.md` file for more details.
