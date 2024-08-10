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
# if ALLOW_PROVISION_TO_DOWNLOAD_LIBS is set to true, then skip this step
if [ "$ALLOW_PROVISION_TO_DOWNLOAD_LIBS" = "true" ]; then
    echo "Skipping decompressing required libs for Provision..."
else
    echo "Decompressing required libs for Provision..."

    # Create the target directory
    mkdir -p /root/.config/Provision

    # Check OVERRIDE_PROVISION_LIBS_ARCH otherwise detect the system architecture
    ARCH=${OVERRIDE_PROVISION_LIBS_ARCH:-$(uname -m)}

    # Map the architecture directly
    ARCH_DIR="lib/${ARCH}"

    # Extract the specific directory or fallback to x86_64
    tar -xvf /altserver/lib.tar.xz -C /root/.config/Provision "$ARCH_DIR/" || tar -xvf /altserver/lib.tar.xz -C /root/.config/Provision "lib/x86_64/"
fi


# Execute supervisord
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
