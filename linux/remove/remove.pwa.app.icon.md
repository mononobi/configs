# Removing PWA Application Launchers

To remove a Progressive Web App (PWA) or web shortcut launcher from the applications menu:

1. Navigate to your local applications directory:
   ```bash
   cd ~/.local/share/applications/
   ```
2. Locate and delete the corresponding `.desktop` launcher file:
   ```bash
   rm chrome-<app_id>-Default.desktop
   ```
