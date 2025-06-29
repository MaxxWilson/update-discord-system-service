# Automatic Discord Updater for Linux

## Problem

The native Discord client for Debian-based Linux distributions does not auto-update. This requires manually downloading and installing the new .deb package every time an update is released.

## Solution

This repository provides a systemd timer and service to automate this process using the excellent deb-get tool. Once installed, it will automatically check for and install Discord updates daily and on every boot.

## Requirements

- A Debian-based Linux distribution (Ubuntu, Debian, etc.).
- A user account with sudo privileges.
- curl must be installed (sudo apt install curl).

## Installation

First, make scripts executable:
```
chmod +x install.sh
chmod +x uninstall.sh
```

Then, run the installer:
```
./install.sh
```

The script will handle dependency installation, sudo permissions, and systemd setup.

## Verification

To verify that the timer is active and scheduled, run:
```
systemctl --user list-timers
```

## Uninstallation

To remove the auto-updater, simply run the uninstall.sh script from the repository root (once created).

```
./uninstall.sh
```