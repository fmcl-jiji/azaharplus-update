#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Configuration ---
REPO="AzaharPlus/AzaharPlus"
INSTALL_DIR="$HOME/.azaharplus"
BACKUP_DIR="$INSTALL_DIR/.azaharplus_backup"
VERSION_FILE="$INSTALL_DIR/version.txt"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}==>${NC} Checking for updates..."

# Get latest release data from GitHub API
RELEASE_DATA=$(curl -s "$GITHUB_API")
LATEST_VERSION=$(echo "$RELEASE_DATA" | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Error:${NC} Could not fetch version info. Check your internet connection."
    exit 1
fi

# Version check logic
UPGRADE_NEEDED=false
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "${GREEN}✓${NC} AzaharPlus is up to date (${CYAN}$CURRENT_VERSION${NC})."
    else
        echo -e "${YELLOW}!${NC} New version detected: ${CYAN}$LATEST_VERSION${NC} (Current: $CURRENT_VERSION)"
        UPGRADE_NEEDED=true
    fi
else
    echo -e "${YELLOW}!${NC} No local installation found."
    UPGRADE_NEEDED=true
fi

# Download and Install with Backup
if [ "$UPGRADE_NEEDED" = true ]; then
    DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep -Po '"browser_download_url": "\K.*linux\.zip(?=")')

    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${RED}Error:${NC} Linux zip not found in the latest release."
        exit 1
    fi

    # --- Backup Functionality ---
    echo -e "${BLUE}==>${NC} Backing up old version to ${CYAN}$BACKUP_DIR${NC}..."
    find "$INSTALL_DIR" -maxdepth 1 -not -name ".azaharplus_backup" -not -path "$INSTALL_DIR" -exec mv -t "$BACKUP_DIR" {} + 2>/dev/null

    echo -e "${BLUE}==>${NC} Downloading: ${CYAN}$LATEST_VERSION${NC}..."
    TEMP_ZIP="/tmp/azaharplus_latest.zip"
    curl -L "$DOWNLOAD_URL" -o "$TEMP_ZIP"

    echo -e "${BLUE}==>${NC} Extracting files..."
    unzip -oj "$TEMP_ZIP" -d "$INSTALL_DIR"
    rm "$TEMP_ZIP"

    # Update version file and permissions
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    chmod +x "$INSTALL_DIR"/*.AppImage
    echo -e "${GREEN}Success:${NC} Update and backup complete."
fi

# Launching
APPIMAGE=$(find "$INSTALL_DIR" -maxdepth 1 -name "*.AppImage" | head -n 1)

if [ -f "$APPIMAGE" ]; then
    echo -e "${GREEN}==>${NC} Launching AzaharPlus..."
    echo -e "${BLUE}--------------------------------------------------${NC}"
    # Execute AppImage with terminal output
    "$APPIMAGE"
else
    echo -e "${RED}Error:${NC} AppImage not found in $INSTALL_DIR."
    exit 1
fi
