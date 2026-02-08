# Linux Theme & Icon Styling

## Offered by
https://github.com/vinceliuice

## Step 1
Go to the Ubuntu settings and select your base style. This is the most important part as failing
to do so can cause conflicts between the base style and the applied theme (Dark/Light).

> Settings → Appearance → Dark or Light (Based on the theme you want to select)

> Settings → Appearance → Color (Based on the theme you want to select)

## Step 2
Create the required folders.
These commands will skip creation if any of the folders already exist.

```bash
mkdir -p ~/.icons
mkdir -p ~/.themes
mkdir -p ~/Workspace/linux-styling/themes
mkdir -p ~/Workspace/linux-styling/icons
```

## Step 3
Clone the theme repository and then install the selected theme.

```bash
cd ~/Workspace/linux-styling/themes
git clone https://github.com/vinceliuice/Orchis-theme.git
cd ~/Workspace/linux-styling/themes/Orchis-theme
```

Install with a **non-floating** top panel:

```bash
./install.sh -t all --tweaks submenu --tweaks compact
```

Install with a **floating** top panel:

```bash
./install.sh -t all --tweaks submenu
```

## Step 4
Clone the icons repository and then install the selected icons.

```bash
cd ~/Workspace/linux-styling/icons
git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd ~/Workspace/linux-styling/icons/Tela-icon-theme
./install.sh -a -d ~/.icons
```

## Step 5
Copy the installed themes and icons to the shared folder to be able to also use 
them on the login screen.

```bash
sudo cp -r ~/.themes/* /usr/share/themes
sudo cp -r ~/.icons/* /usr/share/icons
```

## Step 6
Open the **Tweaks** app and configure the theme and icons:

> Tweaks → Appearance:
  - **Cursor:** DMZ-White
  - **Icons:** Tela-dark
  - **Shell:** Orchis-Dark
  - **Legacy Applications:** Orchis-Dark

> Tweaks → Windows:
  - **Center New Windows:** On

## Step 7
Open the **GDM Settings** app and configure the theme and icons for login page:

> GDM Settings → Appearance:
  - **Shell:** Orchis-Dark
  - **Icons:** Tela-dark
  - **Cursor:** DMZ-White

## Step 8
Go to the **Ubuntu Settings**:

> Settings → Ubuntu Desktop:
  - **Desktop Icons:**
    - **Size:** Small
  
  - **Dock:**
    - **Icon Size:** 42

>IMPORTANT: After configuring the themes, never open the **Appearance** menu
> on the **Ubuntu Settings** window, otherwise all styling settings will be reset
> to their default values and you have to reconfigure.

## Suggestions

### Login Screen Images:
Set it in the **GDM Settings** app:

> GDM Settings → Appearance → Background:
  - **Type:** Image
  - **Image:** A high quality image of your choice

> Suggested Images:
  - [Abstract Blur](./login-background/images/abstract-blur.jpg)
  - [Tony Webster Blur](./login-background/images/tony-webster-blur.jpg)

### File Explorer Icon Size (From 1 to 5):
Set it in the **Files** app.
Set it to **3 out of 5** (The middle size) using the **CTRL + Mouse Wheel**.

## Reinstalling The Themes & Icons
If you have already installed the themes or icon packs and would like to reinstall them with 
different flags, first remove the installed icons or themes and then continue as above.

> Remove Themes:

```bash
rm -r ~/.themes/Orchis*
sudo rm -r /usr/share/themes/Orchis*
```

> Remove Icons:

```bash
rm -r ~/.icons/Tela*
sudo rm -r /usr/share/icons/Tela*
```
