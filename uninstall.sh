#!/bin/bash

# This script undoes the changes made by install.sh.
set -e

echo "-> Beginning Discord auto-updater uninstallation..."

echo "--> Disabling and stopping systemd timer..."
# The || true prevents the script from failing if the timer is already gone.
systemctl --user disable --now discord-updater.timer || true

echo "--> Removing systemd unit files..."
rm -f "$HOME/.config/systemd/user/discord-updater.service"
rm -f "$HOME/.config/systemd/user/discord-updater.timer"

echo "--> Reloading systemd daemon..."
systemctl --user daemon-reload

echo "--> Removing sudoers rule..."
sudo rm -f "/etc/sudoers.d/discord-updater-nopasswd"

echo ""
echo "-> Uninstallation complete."
echo "-> If you wish to also remove Discord and deb-get, do it manually:"
echo "   sudo apt remove discord deb-get"
