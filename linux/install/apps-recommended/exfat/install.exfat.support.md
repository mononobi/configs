# exFAT Support Installation

To add support for exFAT file systems, run the following commands based on your Ubuntu version.

> **WARNING**: The following command to add the universe repository may break your system. Use with caution if needed:
> ```bash
> # sudo add-apt-repository universe
> ```

## Base Installation

```bash
sudo apt update
sudo apt install exfat-fuse
```

## Additional Utilities (Version Specific)

### Ubuntu 21.10 and earlier

```bash
sudo apt install exfat-utils
```

### Ubuntu 22.04 and later

```bash
sudo apt install exfatprogs
```
