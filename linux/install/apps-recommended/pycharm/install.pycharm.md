# Install PyCharm

## Install Using JetBrains Toolbox App (RECOMMENDED)

Go to the [JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/) page and download the
latest Linux version.

Extract the downloaded file with this command:

```bash
tar -xf DOWNLOADED_ARCHIVE.tar.gz
```

Move the entire folder into a permanent location, such as:

```bash
~/.local/share/jetbrains-toolbox-setup
```

To start the application, open a terminal, `cd` into the directory, and type:

```bash
./bin/jetbrains-toolbox
```

This will initialize various Toolbox application files in the application directory:
`~/.local/share/JetBrains/Toolbox`

> **Note:** It may show an error at the end, which you can safely ignore. You can close the
> terminal.

Now, open the Toolbox App from the Ubuntu application launcher menu.

## Install Using JetBrains Toolbox App (OLD VERSIONS)

Install the dependencies found in the
[`install.fuse.appimage.md`](/linux/install/apps-recommended/fuse/install.fuse.appimage.md)
file.

Go to the [JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/) page and download the
latest Linux version.

Extract the downloaded file with this command:

```bash
tar -xf DOWNLOADED_ARCHIVE.tar.gz
```

Go to the extracted folder and execute this command:

```bash
./FILE_NAME
```

Now the Toolbox App is installed. Open it from the applications menu or taskbar, and install
PyCharm from it.

## Install Using Snap (NOT RECOMMENDED)

```bash
sudo snap install pycharm-professional --classic --channel=latest/stable
sudo snap install pycharm-community --classic --channel=latest/stable
```

Always check for the latest channel before installing:

```bash
snap info pycharm-professional
snap info pycharm-community
```

## Increase Inotify File Watch Limit for The IDE

```bash
cd /etc/sysctl.d
sudo touch idea.conf
sudo nano idea.conf
```

In the opened file, write this and save the file:

```ini
fs.inotify.max_user_watches = 2097152
```

Execute this to apply the changes:

```bash
sudo sysctl -p --system
```

Restart the IDE for the changes to take effect.

See the current inotify file watch limit:

```bash
sysctl fs.inotify.max_user_watches
```

## Recommended Plugins (Needed to be Installed)

- Nginx Configuration (meanmail)

## Recommended Plugins (Bundled)

- .env files support (JetBrains)
- Docker (JetBrains)
- Ini (JetBrains)

## No Longer Needed Plugins

- **EnvFile (Borys Pierov):** It is supported by the IDE natively now.
- **Settings Repository (JetBrains):** Deprecated and does not work anymore. The Settings Sync
  feature provided by the IDE is now free to use.

## Sync IDE Settings (No Longer Needed)

To be able to synchronize your IDE settings, you can create a GitHub repository (preferably
private). Then you should install the **Settings Repository** plugin. From the file menu,
select **Manage IDE Settings -> Settings Repository...**. Add the URL of your new repository
(use the `https` URL, not `ssh`), and then click on one of these options based on what you want
to do:

- **OVERWRITE REMOTE:** If you have just created a settings repository and want to initialize
  it with your current local settings.
- **OVERWRITE LOCAL:** If you have installed a new IDE and you want to get all the settings
  from a remote repository which has already been initialized.
- **MERGE:** If you want to synchronize your current local settings with remote settings on the
  repository which has already been initialized.
