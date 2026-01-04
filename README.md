# 🎮 AzaharPlus Linux Updater/Launcher

A simple bash script to automate the installation, updating, and launching of **AzaharPlus** on Linux.

## ✨ Features
* **Version Checking:** Only downloads if a newer build is detected on GitHub.
* **Backup:** Keeps your previous version in `.azaharplus_backup`.
* **Clean Install:** Installs everything to `~/.azaharplus/`..
* **Auto-Launch:** Boots the AppImage immediately after checking/updating.

## 🛠️ Installation & Usage

1. **Save the script** as `azaharplus-update.sh`.
2. **Make it executable**:
   ```bash
   chmod +x azaharplus-update.sh
