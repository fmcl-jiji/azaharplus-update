#!/bin/bash

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Configuration ---
REPO="AzaharPlus/AzaharPlus"
INSTALL_DIR="$HOME/.azaharplus"
BACKUP_DIR="${INSTALL_DIR}_backup"
VERSION_FILE="$INSTALL_DIR/version.txt"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

echo -e "${BLUE}Checking for updates...${NC}"

# Get latest release data
RELEASE_JSON=$(curl -s "$API_URL")
LATEST_VERSION=$(echo "$RELEASE_JSON" | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Error: Could not fetch latest version.${NC}"
    exit 1
fi

# Version check
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "${GREEN}AzaharPlus is up to date ($CURRENT_VERSION).${NC}"
        APPIMAGE=$(find "$INSTALL_DIR" -maxdepth 1 -name "*.AppImage" | head -n 1)
        chmod +x "$APPIMAGE"
        echo -e "${BLUE}Launching and streaming logs...${NC}"
        echo "------------------------------------------"
        "$APPIMAGE"
        exit 0
    fi
fi

echo -e "${YELLOW}New version detected: $LATEST_VERSION${NC}"

# 1. Backup existing installation
if [ -d "$INSTALL_DIR" ] && [ "$(ls -A "$INSTALL_DIR")" ]; then
    echo -e "${BLUE}Backing up current version to ${BACKUP_DIR}...${NC}"
    rm -rf "$BACKUP_DIR"
    mv "$INSTALL_DIR" "$BACKUP_DIR"
fi

# 2. Download and Extract properly
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -Po '"browser_download_url": "\K.*?-linux\.zip(?=")')

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}Error: Could not find Linux .zip build. Restoring backup...${NC}"
    [ -d "$BACKUP_DIR" ] && mv "$BACKUP_DIR" "$INSTALL_DIR"
    exit 1
fi

echo -e "${BLUE}Downloading $LATEST_VERSION...${NC}"
TEMP_ZIP="/tmp/azaharplus.zip"
TEMP_EXTRACT="/tmp/azahar_temp_extract"
curl -L "$DOWNLOAD_URL" -o "$TEMP_ZIP"

echo -e "${BLUE}Extracting and organizing files...${NC}"
mkdir -p "$TEMP_EXTRACT"
unzip -q "$TEMP_ZIP" -d "$TEMP_EXTRACT"

# Create fresh install dir
mkdir -p "$INSTALL_DIR"

# Flattening: Move contents from the internal zip folder directly into .azaharplus
mv "$TEMP_EXTRACT"/*/* "$INSTALL_DIR/" 2>/dev/null || mv "$TEMP_EXTRACT"/* "$INSTALL_DIR/"

# Cleanup
rm -rf "$TEMP_ZIP" "$TEMP_EXTRACT"

# 3. Finalize and Launch
echo "$LATEST_VERSION" > "$VERSION_FILE"
APPIMAGE=$(find "$INSTALL_DIR" -maxdepth 1 -name "*.AppImage" | head -n 1)

if [ -n "$APPIMAGE" ]; then
    chmod +x "$APPIMAGE"
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${BLUE}Launching AzaharPlus and showing logs...${NC}"
    echo "------------------------------------------"
    # Running without '&' so logs appear in terminal. 
    # Use 'Ctrl+C' in terminal to stop the app.
    "$APPIMAGE"
else
    echo -e "${RED}Error: AppImage not found in $INSTALL_DIR.${NC}"
fi
