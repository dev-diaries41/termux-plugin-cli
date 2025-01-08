#!/data/data/com.termux/files/usr/bin/sh

UTILS_DIR="$(dirname "$0")/../"
. "$UTILS_DIR/utils.sh"
. "./add.sh"


ARG="$1" 
TEMP_DIR=$(mktemp -d)

echo "Cloning repository..."
git clone --filter=blob:none --no-checkout "$TERMUX_PLUGINS_REPO_URL" "$TEMP_DIR" || {
    error "Failed to clone repository."
    exit 1
}
cd "$TEMP_DIR" || exit 1

if [ "$ARG" = "--all" ]; then
    echo "Installing all plugins..."
    git sparse-checkout init --cone && git checkout
    for PLUGIN in "$TEMP_DIR"/*/; do
        PLUGIN_NAME="$(basename "$PLUGIN")"
        DEST_DIR="$LOCAL_PLUGIN_DIR/$PLUGIN_NAME"
        check_dir "$PLUGIN"
        mkdir -p "$DEST_DIR"
        cp -r "$PLUGIN"/* "$DEST_DIR"
        add_plugin "$PLUGIN_NAME"
        success "Plugin $PLUGIN_NAME installed successfully."
    done
else
    echo "Installing plugin $ARG..."
    git sparse-checkout init --cone
    git sparse-checkout set "$ARG" && git checkout
    check_dir "$TEMP_DIR/$ARG"
    PLUGIN_NAME="$ARG"
    DEST_DIR="$LOCAL_PLUGIN_DIR/$PLUGIN_NAME"
    check_dir "$TEMP_DIR/$ARG"
    mkdir -p "$DEST_DIR"
    cp -r "$TEMP_DIR/$ARG"/* "$DEST_DIR"
    add_plugin "$PLUGIN_NAME"
    success "Plugin $PLUGIN_NAME installed successfully."
fi

rm -rf "$TEMP_DIR"