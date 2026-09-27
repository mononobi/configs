# Removing APT Packages

Commands for completely removing or purging APT packages and their associated
configuration files.

```bash
# Standard package removal (preserves configuration files):
sudo apt remove <package_name>

# Purge package completely along with configuration files:
sudo apt-get purge <package_name>

# Example (wildcard purging matching packages):
sudo apt-get purge "openjdk-*"
```
