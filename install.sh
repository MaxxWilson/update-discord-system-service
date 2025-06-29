#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "-> Starting Discord auto-updater setup..."

# Check for deb-get and install if not found
if ! command -v deb-get &> /dev/null; then
    echo "--> deb-get not found. Installing..."
    curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
else
    echo "--> deb-get is already installed."
fi

# Create sudoers rule for passwordless execution
# Note: Using a file in /etc/sudoers.d/ is the modern, safe way to add rules.
SUDOERS_FILE="/etc/sudoers.d/discord-updater-nopasswd"
SUDO_COMMAND="/usr/bin/deb-get install discord"
echo "--> Creating sudoers rule for the current user at $SUDOERS_FILE..."

# Use whoami to be robust, as $USER may not be set in all contexts.
CURRENT_USER=$(whoami)
echo "$CURRENT_USER ALL=(ALL) NOPASSWD: $SUDO_COMMAND" | sudo tee "$SUDOERS_FILE" > /dev/null

# Set correct permissions for the sudoers file
sudo chmod 0440 "$SUDOERS_FILE"
echo "--> Sudoers rule created."

# Copy systemd unit files
SYSTEMD_DIR="$HOME/.config/systemd/user"
echo "--> Creating systemd user directory at $SYSTEMD_DIR..."
mkdir -p "$SYSTEMD_DIR"

echo "--> Copying unit files..."
# Assuming the script is run from the repo root
cp systemd/discord-updater.service "$SYSTEMD_DIR/"
cp systemd/discord-updater.timer "$SYSTEMD_DIR/"
echo "--> Unit files copied."

# Reload systemd and enable the timer
echo "--> Reloading systemd daemon and enabling timer..."
systemctl --user daemon-reload
systemctl --user enable --now discord-updater.timer
echo "--> Timer enabled."

echo ""
echo "-> Installation complete."
echo "-> To check timer status, run: systemctl --user list-timers"