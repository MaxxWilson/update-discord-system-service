#!/bin/bash

set -e

echo "-> Starting Discord auto-updater setup..."

# Step 1: Forcefully install deb-get from its official .deb release
echo "--> Ensuring deb-get is installed..."
DEB_URL="https://github.com/wimpysworld/deb-get/releases/download/0.4.5/deb-get_0.4.5-1_all.deb"
DEB_FILE="/tmp/deb-get.deb"
curl -L "$DEB_URL" -o "$DEB_FILE"
sudo apt-get install -y "$DEB_FILE"
rm "$DEB_FILE" # Clean up

# Step 2: Verify installation and get the correct path
echo "--> Verifying deb-get path..."
if ! command -v deb-get &> /dev/null; then
    echo "[!] FATAL: deb-get installation failed. Aborting."
    exit 1
fi
DEB_GET_PATH=$(which deb-get)
echo "--> Found deb-get at: $DEB_GET_PATH"

# Step 3: Create sudoers rule with the correct path
SUDOERS_FILE="/etc/sudoers.d/discord-updater-nopasswd"
echo "--> Creating sudoers rule for the current user..."
CURRENT_USER=$(whoami)
echo "$CURRENT_USER ALL=(ALL) NOPASSWD: $DEB_GET_PATH install discord" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE"
echo "--> Sudoers rule created."

# Step 4: Copy and patch systemd unit files
SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_DIR/discord-updater.service"
echo "--> Creating systemd user directory..."
mkdir -p "$SYSTEMD_DIR"

echo "--> Copying and patching unit files..."
cp systemd/discord-updater.service "$SERVICE_FILE"
cp systemd/discord-updater.timer "$SYSTEMD_DIR/"

# Use sed to replace the placeholder with the actual path
sed -i "s|__DEB_GET_PATH__|${DEB_GET_PATH}|g" "$SERVICE_FILE"
echo "--> Unit files configured."

# Step 5: Reload systemd and enable the timer
echo "--> Reloading systemd daemon and enabling timer..."
systemctl --user daemon-reload
systemctl --user enable --now discord-updater.timer
echo "--> Timer enabled."

# Step 6: Add a small delay and perform the initial run
echo "--> Waiting 2 seconds for system to process new permissions..."
sleep 2
echo "--> Triggering initial run to install/update Discord..."
systemctl --user start discord-updater.service
echo "--> Initial run command sent."

echo ""
echo "-> Installation complete."
echo "-> To check the result, run: journalctl --user -u discord-updater.service -n 20"