# NVIDIA Graphics Driver Installation

## If a Valid Version is Already Installed

### Uninstall

```bash
sudo apt-get purge nvidia*
```

### Install (Option A or B)

**Option A:**

```bash
# sudo apt-get install nvidia-331
```

**Option B:**

```bash
sudo add-apt-repository ppa:xorg-edgers/ppa
sudo apt-get update
sudo apt-get install nvidia-346
sudo add-apt-repository -r ppa:xorg-edgers/ppa
```

## If a Valid Version is Not Installed (and a Manual Driver is Installed)

```bash
sudo ubuntu-drivers install
```
