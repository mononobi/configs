# libjpeg Installation Guide

> **Note:** If you want to use the Pillow image processing Python package, you must install
> `libjpeg` before Pillow.

```bash
sudo apt-get install libjpeg-dev
```

> **Note:** If you're on Ubuntu 14.04, also install this:

```bash
sudo apt-get install libjpeg8-dev
```

## Reinstalling Pillow

If you already have Pillow installed, you must uninstall it and reinstall it again with:

```bash
pip install --no-cache-dir -I pillow
```

If you want a specific version of Pillow, you must install it with:

```bash
pip install --no-cache-dir -Iv pillow==SOME.SPECIFIC.VERSION
```
