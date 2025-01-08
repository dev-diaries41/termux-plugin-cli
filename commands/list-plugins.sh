#!/data/data/com.termux/files/usr/bin/sh

LOCAL_PLUGIN_DIR="/data/data/com.termux/files/home/.termux-plugins"
TPLUG_CLI_DIR="/data/data/com.termux/files/home/.termux-plugin-cli"
. "$TPLUG_CLI_DIR/utils.sh"

check_dir "$LOCAL_PLUGIN_DIR"
echo "Installed Plugins:"
find "$LOCAL_PLUGIN_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No plugins installed."