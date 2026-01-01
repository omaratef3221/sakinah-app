#!/bin/bash
# Quick screenshot script for Android emulator
# Usage: ./capture-android.sh <name>

if [ -z "$1" ]; then
    FILENAME="screenshot-$(date +%Y%m%d-%H%M%S).png"
else
    FILENAME="$1.png"
fi

~/Library/Android/sdk/platform-tools/adb -s emulator-5554 exec-out screencap -p > "/Users/omaratef/Dropbox/Projects/MobileApps/Sakinah/screenshots/$FILENAME"

if [ $? -eq 0 ]; then
    echo "✅ Screenshot saved: $FILENAME"
    ls -lh "/Users/omaratef/Dropbox/Projects/MobileApps/Sakinah/screenshots/$FILENAME"
else
    echo "❌ Failed to take screenshot"
fi
