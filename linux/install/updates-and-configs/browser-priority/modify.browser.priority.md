# Modify Browser Priority

To list the current browser priorities, execute the following command:

```bash
sudo update-alternatives --config x-www-browser
```

To change the priority of a browser, execute this for each one you want to adjust:

```bash
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/BROWSER_NAME PRIORITY
```

## Examples

For standard installations (e.g., Brave):

```bash
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/brave-browser-stable 20
```

For browsers installed with Flatpak (e.g., Firefox):

```bash
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /var/lib/flatpak/exports/bin/org.mozilla.firefox 600
```
