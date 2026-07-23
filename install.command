#!/usr/bin/env bash
#
# install.command — one-time auto-update setup (macOS & Linux).
#
# Run this ONCE from inside the extension folder, wherever you put it:
#   macOS : double-click install.command (if blocked: right-click -> Open,
#           or run:  bash install.command  in Terminal)
#   Linux : bash install.command
#
# What it does (detects your OS automatically):
#   macOS -> registers a LaunchAgent that runs update.sh every hour
#   Linux -> adds a crontab entry that runs update.sh every hour
# ...pointing at THIS folder, so the extension can live anywhere. If you ever
# move the folder, just run this again from the new location.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="in.affiliaters.deal-converter.updater"
OS="$(uname -s)"

echo ""
echo "Affiliaters Deal Converter — auto-update setup"
echo "Extension folder: $SCRIPT_DIR"
echo ""

if [ ! -f "$SCRIPT_DIR/manifest.json" ] || [ ! -f "$SCRIPT_DIR/update.sh" ]; then
    echo "ERROR: run this from inside the extension folder (manifest.json / update.sh not found)."
    read -r -p "Press Enter to close..." _ 2>/dev/null
    exit 1
fi

chmod +x "$SCRIPT_DIR/update.sh" "$SCRIPT_DIR/install.command" 2>/dev/null

case "$OS" in
    Darwin)
        PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
        mkdir -p "$HOME/Library/LaunchAgents"
        cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_DIR/update.sh</string>
    </array>
    <key>StartInterval</key><integer>3600</integer>
    <key>RunAtLoad</key><true/>
</dict>
</plist>
PLISTEOF
        # Re-register (handles re-runs and folder moves).
        launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || launchctl unload "$PLIST" 2>/dev/null || true
        if launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || launchctl load "$PLIST" 2>/dev/null; then
            echo "OK: macOS auto-update installed (checks every hour)."
        else
            echo "ERROR: could not register the update job with launchd."
            read -r -p "Press Enter to close..." _ 2>/dev/null
            exit 1
        fi
        ;;
    Linux)
        MARKER="# affiliaters-extension-updater"
        CRON_LINE="0 * * * * /bin/bash \"$SCRIPT_DIR/update.sh\" $MARKER"
        # Replace any previous entry (handles re-runs and folder moves).
        ( crontab -l 2>/dev/null | grep -vF "$MARKER"; echo "$CRON_LINE" ) | crontab -
        echo "OK: Linux auto-update installed via cron (checks every hour)."
        ;;
    *)
        echo "ERROR: unsupported OS '$OS'. On Windows, double-click install.bat instead."
        read -r -p "Press Enter to close..." _ 2>/dev/null
        exit 1
        ;;
esac

echo ""
echo "Running the first update check now..."
bash "$SCRIPT_DIR/update.sh"
echo "Done. Details are in last-update.log inside the extension folder."
echo ""
echo "From now on the extension updates itself automatically."
echo "If you ever MOVE this folder, run this installer again from the new location."
read -r -p "Press Enter to close..." _ 2>/dev/null
exit 0
