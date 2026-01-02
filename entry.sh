#!/bin/bash
set -e

CONTAINER_USER=starbound
DATA="$PWD/openStarbound"

# Create data folder
mkdir -p "$DATA"

# Remap UID/GID if provided
if [ -n "$PUID" ] && [ -n "$PGID" ]; then
    echo "Remapping $CONTAINER_USER to PUID=$PUID PGID=$PGID"
    groupmod -o -g "$PGID" $CONTAINER_USER
    usermod -o -u "$PUID" -g "$PGID" $CONTAINER_USER
fi

# Ensure ownership for the user
chown -R $CONTAINER_USER:$CONTAINER_USER "$DATA"

# Execute the main start script as the mapped user
exec gosu $CONTAINER_USER /start.sh "$@"
