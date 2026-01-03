# AzaharPlus Linux Updater/Launcher

A simple bash script to automate the installation and updating of **AzaharPlus** on Linux.

## Features
* **Auto-Update:** Checks GitHub API for the latest release.
* **Smart Skip:** Skips download if you already have the latest version.
* **Backup:** Keeps your previous version in `.azaharplus_backup`.
* **Clean Install:** Flattens directory structure for direct access.
* **Live Logs:** Streams the AppImage output to your terminal.

## Installation
1. Move the `azaharplus-update.sh` script to your desired folder.
2. Make it executable:
   ```bash
   chmod +x azaharplus-update.sh
