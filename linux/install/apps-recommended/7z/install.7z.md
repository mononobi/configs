# Install 7-Zip

> **Warning:** The following line may break your system. Use with caution.
>
> ```bash
> # sudo add-apt-repository universe
> ```

## For Ubuntu >= 26.04

Run the following commands:

```bash
sudo apt update
sudo apt install 7zip 7zip-rar
```

## For Ubuntu <= 24.04

Run the following commands:

```bash
sudo apt update
sudo apt install p7zip-full p7zip-rar
```

## Extracting Archives via Terminal

If the archive manager cannot open an archive, try this command to extract it using the
terminal:

```bash
7z e ARCHIVE_FILE_NAME
```
