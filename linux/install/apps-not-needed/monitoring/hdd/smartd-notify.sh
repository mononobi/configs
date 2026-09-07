#!/bin/bash

# Save this file to: /usr/local/bin/smartd-notify.sh

# 1. Identify the user (ID 1000 is standard for the first user)
TARGET_USER_ID=1000
TARGET_USER_NAME=$(id -nu $TARGET_USER_ID)

# 2. Define Message
SUMMARY="⚠️ HARD DRIVE WARNING"
BODY="<b>Device:</b> $SMARTD_DEVICE [$SMARTD_DEVICETYPE] • <b>Error:</b> $SMARTD_MESSAGE"

# 3. Send Notification
if [ -n "$TARGET_USER_NAME" ]; then
    sudo -u "$TARGET_USER_NAME" \
    DISPLAY=:0 \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_USER_ID/bus" \
    notify-send "$SUMMARY" "$BODY" \
    --icon=drive-harddisk-error \
    --urgency=critical \
    --app-name="SMART"
fi
