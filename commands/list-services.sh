#!/data/data/com.termux/files/usr/bin/sh

USR_PREFIX="/data/data/com.termux/files/usr"
SERVICE_DIR="$USR_PREFIX/var/service"
UTILS_DIR="$(dirname "$0")/../"

source "$UTILS_DIR/utils.sh"

check_dir "$SERVICE_DIR"
echo "Installed Services:"
find "$SERVICE_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No services installed."