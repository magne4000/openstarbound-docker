#!/bin/bash
set -e

DATA="$PWD/openStarbound"
API="https://api.github.com/repos/OpenStarbound/OpenStarbound/releases/latest"

echo "Starting OpenStarbound Server..."
echo "Checking latest OpenStarbound release..."

# Follow redirect to get the latest release page
REDIRECT_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/OpenStarbound/OpenStarbound/releases/latest)

# Extract the tag from the URL (last path segment)
LATEST_TAG=$(basename "$REDIRECT_URL")

# Construct server download URL
LATEST_ZIP="https://github.com/OpenStarbound/OpenStarbound/releases/download/$LATEST_TAG/OpenStarbound-Linux-Clang-Server.zip"

if [ -z "$LATEST_TAG" ] || [ -z "$LATEST_ZIP" ]; then
    echo "❌ Failed to fetch latest release info from GitHub"
    exit 1
fi

echo "Latest version on GitHub: $LATEST_TAG"

INSTALLED_TAG_FILE="$DATA/.installed_version"
DO_INSTALL=false

# Check installed version
if [ ! -f "$INSTALLED_TAG_FILE" ]; then
    echo "No installed version detected — will install $LATEST_TAG"
    DO_INSTALL=true
else
    INSTALLED_TAG=$(cat "$INSTALLED_TAG_FILE")
    if [ "$INSTALLED_TAG" != "$LATEST_TAG" ]; then
        echo "Installed version is $INSTALLED_TAG but latest is $LATEST_TAG — updating"
        DO_INSTALL=true
    else
        echo "Already up to date ($INSTALLED_TAG)"
    fi
fi

# Install or update if required
if [ "$DO_INSTALL" = true ]; then
    echo "Downloading latest server ($LATEST_ZIP)..."
    wget -q --show-progress -O server.zip "$LATEST_ZIP"

    echo "Extracting server..."
    unzip -q server.zip
    rm server.zip

    if [ -f server.tar ]; then
        echo "Extracting inner tar..."
        tar -xvf server.tar
        rm server.tar
    fi

    if [ -d server_distribution ]; then
        echo "Moving server files into place..."

        cd server_distribution

        # Overwrite assets and linux
        if [ -d "$DATA/assets" ]; then
            echo "Removing old assets folder..."
            rm -rf "$DATA/assets"
        fi
        mv --verbose -f assets "$DATA/"

        # Overwrite linux
        if [ -d "$DATA/linux" ]; then
            echo "Removing old linux folder..."
            rm -rf "$DATA/linux"
        fi
        mv --verbose -f linux "$DATA/"

        # Keep mods intact: only move if /mods does not exist
        if [ ! -d "$DATA/mods" ]; then
            mv --verbose -f mods "$DATA/"
        else
            echo "Mods folder exists, keeping existing mods intact"
        fi

        cd ..
        rm -rf server_distribution
    fi

    echo "$LATEST_TAG" > "$INSTALLED_TAG_FILE"

    echo "Installation/update of $LATEST_TAG complete!"
fi

# Start server
echo "Starting OpenStarbound server..."
cd "$DATA/linux"
exec ./starbound_server
