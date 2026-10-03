# Fixing Dual-Boot OS Detection

When you have a dual-boot system, it might occasionally happen that after installing certain
Linux distributions, the other operating system does not appear in the boot menu.

To resolve this issue, execute the following commands:

## Recommended Method

```bash
sudo rm /boot/grub/grub.cfg
sudo update-grub
```

## Alternate Method

_(Note: This method may not always work)_

```bash
sudo apt update
sudo apt upgrade
sudo apt install os-prober
sudo os-prober
sudo update-grub
```

After completing either method, **restart the PC**.
