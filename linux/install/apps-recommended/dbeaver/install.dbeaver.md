# DBeaver Installation

DBeaver is an open-source, cross-platform database management application supporting all major
database systems. It is a great open-source alternative to the JetBrains DataGrip app. Visit
their website: [https://dbeaver.io](https://dbeaver.io)

## Installation using APT

```bash
sudo add-apt-repository ppa:serge-rider/dbeaver-ce
sudo apt-get update
sudo apt-get install dbeaver-ce
```

## Installation using Flatpak

```bash
flatpak install flathub io.dbeaver.DBeaverCommunity
```

> **TIP:** You can import the `dbeaver.dark.epf` file into your installed app to set a dark
> theme.

> **NOTE ON APP NOT GETTING UPDATED THROUGH APT:** If you have installed the app using APT and
> at some point the app has gotten stuck on an old version, you can download the latest `.deb`
> file and install it using this command:
>
> ```bash
> sudo dpkg -i ./DOWNLOADED_FILE.deb
> sudo apt-get install -f
> ```
