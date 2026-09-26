# Material Shell Themes for GNOME 40

> **Note:** The zip file contains 3 material shell themes for GNOME 40. The blue theme is revised and works perfectly, but the black and mint themes must be revised to fit correctly.

## Installation Instructions

1. Extract the `Material-Originals-Shell-40.zip` file.
2. Place the extracted top folders into your `~/.themes` directory.
3. Open **Gnome Tweaks** and change the shell theme in the **Appearance** tab.
   * *Note: You must have the GNOME `user-themes` extension installed first.*

## Revising a Theme

To revise a theme, open its `gnome-shell.css` file. Search for the following values and correct the related CSS attributes:

```css
/* Top Bar */

/* Activities Ripple */
#panel #panelActivities.panel-button

/* Dash */
#dash .overview-icon
.dash-item-container .app-well-app, .show-apps
.dash-label
```
