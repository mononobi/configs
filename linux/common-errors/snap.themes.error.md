## Snap Themes Error

If you faced an error related to snapd failing to install snap themes, follow this:

List all installed snap libraries:

```bash
snap list
```

Remove those which are not basic, such as:

```bash
snap remove gtk-theme-orchis
snap remove gtk-common-themes
snap remove gnome-42-2204
```
