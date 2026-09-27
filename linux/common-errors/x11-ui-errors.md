# Recovering from UI Glitches on X11

If you encounter graphical glitches, frozen shell extensions, or UI unresponsiveness while
running an X11 (Xorg) session, restart the GNOME Shell without closing running
applications:

1. Press `Alt + F2` to open the GNOME Run Command dialog.
2. Type `r` into the input prompt.
3. Press `Enter`.

This re-executes GNOME Shell in-place while keeping all open windows and applications
intact.
