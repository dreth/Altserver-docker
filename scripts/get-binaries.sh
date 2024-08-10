#!/bin/bash

set -e

# Function to download a file from a URL
download_file() {
    local url="$1"
    local dest="$2"
    if [ -f "$dest" ]; then
        echo "File $dest already exists, skipping download."
    else
        echo "Downloading from URL: $url"
        curl -L "$url" -o "$dest"
    fi
}

# Function to extract the latest version tag from GitHub API response
get_latest_version() {
    local api_url="$1"
    local version_path="$2"
    curl -s "$api_url" | jq -r "$version_path"
}

# Function to get the saved version from the versions file
get_saved_version() {
    local component="$1"
    if [ -f "/altserver/bin/versions" ]; then
        grep "^$component" "/altserver/bin/versions" | cut -d' ' -f2
    else
        echo ""
    fi
}

# Function to save the version to the versions file
save_version() {
    local component="$1"
    local version="$2"
    if grep -q "^$component" "/altserver/bin/versions"; then
        sed -i "s/^$component .*/$component $version/" "/altserver/bin/versions"
    else
        echo "$component $version" >> "/altserver/bin/versions"
    fi
}

# Function to save the architecture to the architectures file
save_architecture() {
    local component="$1"
    local architecture="$2"
    if grep -q "^$component" "/altserver/bin/architectures"; then
        sed -i "s/^$component .*/$component $architecture/" "/altserver/bin/architectures"
    else
        echo "$component $architecture" >> "/altserver/bin/architectures"
    fi
}

# Generalized function to check version and download files
check_and_download() {
    local component="$1"
    local api_url="$2"
    local version_path="$3"
    local download_url_template="$4"
    local dest="$5"

    local latest_version
    local saved_version
    local download_url

    latest_version=$(get_latest_version "$api_url" "$version_path")
    saved_version=$(get_saved_version "$component")

    if [ "$latest_version" != "$saved_version" ]; then
        download_url=$(printf "$download_url_template" "$latest_version")
        echo "$component download URL: $download_url"
        download_file "$download_url" "$dest"
        save_version "$component" "$latest_version"
    else
        save_version "$component" "$latest_version"
        echo "$component is up to date."
    fi
}

# Define URLs and paths
altstore_url="https://cdn.altstore.io/file/altstore/apps.json"
altstore_version_path=".apps[0].versions[0].version"
altstore_download_path=".apps[0].versions[0].downloadURL"
altserver_url="https://api.github.com/repos/NyaMisty/AltServer-Linux/releases/latest"
netmuxd_url="https://api.github.com/repos/jkcoxson/netmuxd/releases/latest"
anisette_url="https://api.github.com/repos/Dadoum/Provision/releases/latest"

ARCH="$(uname -m)"

# Override architectures
OVERRIDE_ALTSERVER_ARCH="${OVERRIDE_ALTSERVER_ARCH:-}"
OVERRIDE_NETMUXD_ARCH="${OVERRIDE_NETMUXD_ARCH:-}"
OVERRIDE_ANISETTE_ARCH="${OVERRIDE_ANISETTE_ARCH:-}"

# Ensure bin directory exists
mkdir -p "/altserver/bin"

# Check and download AltStore.ipa
altstore_version=$(curl -s "$altstore_url" | jq -r "$altstore_version_path")
altstore_download_url=$(curl -s "$altstore_url" | jq -r "$altstore_download_path")
check_and_download "AltStore" "$altstore_url" "$altstore_version_path" "$altstore_download_url" "/altserver/bin/AltStore.ipa"

# Check and download AltServer
# If the architecture is overridden, use the overridden value
if [ -n "$OVERRIDE_ALTSERVER_ARCH" ]; then
    ALTSERVER_PKG_ARCH="AltServer-${OVERRIDE_ALTSERVER_ARCH}"
else
    ALTSERVER_PKG_ARCH="AltServer-${ARCH}"
fi
check_and_download "AltServer" "$altserver_url" ".tag_name" "https://github.com/NyaMisty/AltServer-Linux/releases/download/%s/${ALTSERVER_PKG_ARCH}" "/altserver/bin/AltServer"

# Check and download netmuxd
if [ -n "$OVERRIDE_NETMUXD_ARCH" ]; then
    NETMUXD_PKG_ARCH="${OVERRIDE_NETMUXD_ARCH}-linux-netmuxd"
else
    NETMUXD_PKG_ARCH="${ARCH}-linux-netmuxd"
fi
check_and_download "netmuxd" "$netmuxd_url" ".tag_name" "https://github.com/jkcoxson/netmuxd/releases/download/%s/${NETMUXD_PKG_ARCH}" "/altserver/bin/netmuxd"

# Check and download anisette-server
if [ -n "$OVERRIDE_ANISETTE_ARCH" ]; then
    ANISETTE_PKG_ARCH="anisette-server-${OVERRIDE_ANISETTE_ARCH}"
else
    ANISETTE_PKG_ARCH="anisette-server-${ARCH}"
fi
check_and_download "anisette-server" "$anisette_url" ".tag_name" "https://github.com/Dadoum/Provision/releases/download/%s/${ANISETTE_PKG_ARCH}" "/altserver/bin/anisette-server"

# Save the architectures
save_architecture "AltServer" "$ALTSERVER_PKG_ARCH"
save_architecture "netmuxd" "$NETMUXD_PKG_ARCH"
save_architecture "anisette-server" "$ANISETTE_PKG_ARCH"
