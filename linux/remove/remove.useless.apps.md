# Removing Pre-Installed Bloatware & Games

Uninstall default GNOME games, unused media utilities, and default snap browsers:

```bash
# Remove default GNOME games and redundant desktop apps
sudo apt autoremove -y aisleriot
sudo apt autoremove -y gnome-sudoku
sudo apt autoremove -y gnome-mines
sudo apt autoremove -y gnome-mahjongg
sudo apt autoremove -y thunderbird
sudo apt autoremove -y rhythmbox

# Remove default Snap Firefox package
sudo snap remove firefox
```
