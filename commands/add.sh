#!/data/data/com.termux/files/usr/bin/sh

UTILS_DIR="$(dirname "$0")/../"
source "$UTILS_DIR/utils.sh"

LOCAL_PLUGIN_DIR="/data/data/com.termux/files/home/.termux-plugins"
USR_PREFIX="/data/data/com.termux/files/usr"
SERVICE_DIR="$USR_PREFIX/var/service"
LOGGER_PATH="$USR_PREFIX/share/termux-services/svlogger"

PLUGIN_NAME="$1"
PLUGIN_DIR="$LOCAL_PLUGIN_DIR/$PLUGIN_NAME"

# Ensure the plugin directory exists
check_dir "$PLUGIN_DIR"

# Install dependencies from plugin.yml
if [ -f "$PLUGIN_DIR/plugin.yml" ]; then
    echo "Installing dependencies from plugin.yml..."
    local DEPS
    DEPS=$(grep -oP '(?<=- name: )\S+' "$PLUGIN_DIR/plugin.yml" | xargs)
    if [ -n "$DEPS" ]; then
        pkg install -y $DEPS || { error "Failed to install dependencies: $DEPS"; exit 1; }
    fi
fi

# Create and configure the service directory
SERVICE_NAME="$PLUGIN_NAME"
mkdir -p "$SERVICE_DIR/$SERVICE_NAME/log"
ln -sf "$LOGGER_PATH" "$SERVICE_DIR/$SERVICE_NAME/log/run"

# Ensure 'run' script exists and copy it
if [ -f "$PLUGIN_DIR/run" ]; then
    cp "$PLUGIN_DIR/run" "$SERVICE_DIR/$SERVICE_NAME/run"
    chmod 755 "$SERVICE_DIR/$SERVICE_NAME/run"
else
    error "'run' script missing in $PLUGIN_DIR."; exit 1;
fi

# Enforce plugin file structure
if [ -d "$PLUGIN_DIR/plugin" ]; then
    if [ ! -f "$PLUGIN_DIR/plugin/run.py" ] && [ ! -f "$PLUGIN_DIR/plugin/run.sh" ]; then
        error "'run.py' or 'run.sh' is missing in $PLUGIN_DIR/plugin."; exit 1;
    fi

    # Copy the plugin files
    mkdir -p "$SERVICE_DIR/$SERVICE_NAME/plugin"
    cp -r "$PLUGIN_DIR/plugin/"* "$SERVICE_DIR/$SERVICE_NAME/plugin/"

    # Make run.sh executable if it exists
    if [ -f "$PLUGIN_DIR/plugin/run.sh" ]; then
        chmod 755 "$SERVICE_DIR/$SERVICE_NAME/plugin/run.sh"
    fi
fi

success "Plugin $PLUGIN_NAME added successfully."