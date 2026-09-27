# Immutable File Protection with `chattr`

Protect critical configuration files against modification, overwrite, truncation, or
accidental deletion (even by the `root` user).

## Make a File Immutable (Protected)

```bash
sudo chattr +i FILE_NAME
```

While the `+i` attribute is active, no process (including `sudo rm` or root edits) can
alter or remove the file.

## Remove Immutability (Make Mutable Again)

```bash
sudo chattr -i FILE_NAME
```
