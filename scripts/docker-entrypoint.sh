#!/bin/bash

# Get the binaries
echo "Getting binaries..."
/altserver/scripts/get-binaries.sh

# Make the scripts executable
echo "Making scripts executable..."
chmod -R +x /altserver/bin/

# Start avahi-daemon in the background
echo "Starting avahi-daemon service..."
rm -rf /run/avahi-daemon//pid && avahi-daemon -D 

# Purge logs
echo "Purging logs..."
rm -rf /altserver/logs/*

# Decompressing required libs for Provision
# --- COMMENT THIS BLOCK IF YOU'D RATHER HAVE ANISETTE PULL AND EXTRACT THE LIBS
echo "Decompressing required libs for Provision..."

# Create the target directory
mkdir -p /root/.config/Provision

# Detect the system architecture
ARCH=$(uname -m)

# in case of aarch64, map it to arm64-v8a
if [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64-v8a"
fi

# Map the architecture directly
ARCH_DIR="lib/${ARCH}"

# Extract the specific directory or fallback to x86_64
tar -xvf /altserver/lib.tar.xz -C /root/.config/Provision "$ARCH_DIR/" || tar -xvf /altserver/lib.tar.xz -C /root/.config/Provision "lib/x86_64/"
# --- COMMENT THIS BLOCK IF YOU'D RATHER HAVE ANISETTE PULL AND EXTRACT THE LIBS

# Execute supervisord
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
