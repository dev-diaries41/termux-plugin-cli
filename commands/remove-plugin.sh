#!/data/data/com.termux/files/usr/bin/sh

LOCAL_PLUGIN_DIR="/data/data/com.termux/files/home/.termux-plugins"
UTILS_DIR="$(dirname "$0")/../"
source "$UTILS_DIR/utils.sh"

PLUGIN_NAME="$1"

if [ -z "$PLUGIN_NAME" ]; then
    error "Usage: tplug remove-plugin <plugin_name>"
    exit 1
fi

check_dir "$LOCAL_PLUGIN_DIR/$PLUGIN_NAME"
echo "Removing plugin $PLUGIN_NAME..."
rm -rf "$LOCAL_PLUGIN_DIR/$PLUGIN_NAME"
success "Plugin $PLUGIN_NAME removed successfully."