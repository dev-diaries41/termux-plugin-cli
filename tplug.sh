#!/data/data/com.termux/files/usr/bin/sh

# CLI tool to manage Termux plugins
# Usage: tplug <command> [options]
# save script to /data/data/com.termux/files/usr/bin/tplug.

HOME="/data/data/com.termux/files/home"
USR_PREFIX="/data/data/com.termux/files/usr"
LOCAL_PLUGIN_DIR="$HOME/plugins"
SERVICE_DIR="$USR_PREFIX/var/service"

# Install dependencies from the plugin.yml
install_dependencies() {
    PLUGIN_DIR="$1"

    # Check for plugin.yml file
    if [ -f "$PLUGIN_DIR/plugin.yml" ]; then
        echo "Found plugin.yml, installing dependencies..."

        # Extract the dependencies names using awk or grep
        DEPENDENCIES=$(awk '/dependencies:/ {flag=1} flag && /name:/ {print $2} /dependencies:/ && /description:/ {flag=0}' "$PLUGIN_DIR/plugin.yml")

        for DEP in $DEPENDENCIES; do
            echo "Installing dependency: $DEP"
            pkg install -y "$DEP"
        done
    else
        echo "No plugin.yml found in $PLUGIN_DIR, skipping dependencies installation."
    fi
}

# Add local plugin
tplug_add_local() {
    SERVICE_NAME="$1"

    if [ -z "$SERVICE_NAME" ]; then
        echo "Usage: tplug add -l <service_name>"
        exit 1
    fi

    PLUGIN_DIR="$LOCAL_PLUGIN_DIR/$SERVICE_NAME"

    if [ ! -d "$PLUGIN_DIR" ]; then
        echo "Error: Local plugin directory $PLUGIN_DIR does not exist."
        exit 1
    fi

    # Install dependencies from plugin.yml (if it exists)
    install_dependencies "$PLUGIN_DIR"

    mkdir -p "$SERVICE_DIR/$SERVICE_NAME"
    mkdir -p "$SERVICE_DIR/$SERVICE_NAME/log"
    ln -sf $USR_PREFIX/share/termux-services/svlogger $SERVICE_DIR/$SERVICE_NAME/log/run

    echo "Copying 'run' script..."
    if [ -f "$PLUGIN_DIR/run" ]; then
        cp "$PLUGIN_DIR/run" "$SERVICE_DIR/$SERVICE_NAME/run"
        chmod 755 "$SERVICE_DIR/$SERVICE_NAME/run"
    else
        echo "Error: 'run' script not found in $PLUGIN_DIR."
        exit 1
    fi

    if [ -d "$PLUGIN_DIR/plugin" ]; then
        echo "Copying 'plugin' folder..."
        mkdir -p "$SERVICE_DIR/$SERVICE_NAME/plugin"
        cp -r "$PLUGIN_DIR/plugin/"* "$SERVICE_DIR/$SERVICE_NAME/plugin/"
    fi

    echo "Service $SERVICE_NAME added successfully."
    echo "Run 'sv-enable $SERVICE_NAME' to enable the service."
}

# Add GitHub plugin
tplug_add_github() {
    REPO_URL="$1"
    SERVICE_NAME="$2"

    if [ -z "$REPO_URL" ] || [ -z "$SERVICE_NAME" ]; then
        echo "Usage: tplug add -g <repo_url> <service_name>"
        exit 1
    fi

    TEMP_DIR=$(mktemp -d)

    echo "Cloning repository..."
    git clone "$REPO_URL" "$TEMP_DIR"

    if [ ! -f "$TEMP_DIR/run" ]; then
        echo "Error: The repository does not contain a 'run' script in the root."
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Install dependencies from plugin.yml (if it exists)
    install_dependencies "$TEMP_DIR"

    mkdir -p "$SERVICE_DIR/$SERVICE_NAME"
    mkdir -p "$SERVICE_DIR/$SERVICE_NAME/log"
    ln -sf $USR_PREFIX/share/termux-services/svlogger $SERVICE_DIR/$SERVICE_NAME/log/run

    echo "Copying 'run' script..."
    cp "$TEMP_DIR/run" "$SERVICE_DIR/$SERVICE_NAME/run"
    chmod 755 "$SERVICE_DIR/$SERVICE_NAME/run"

    if [ -d "$TEMP_DIR/plugin" ]; then
        echo "Copying 'plugin' folder..."
        mkdir -p "$SERVICE_DIR/$SERVICE_NAME/plugin"
        cp -r "$TEMP_DIR/plugin/"* "$SERVICE_DIR/$SERVICE_NAME/plugin/"
    fi

    rm -rf "$TEMP_DIR"

    echo "Service $SERVICE_NAME added successfully."
    echo "Run 'sv-enable $SERVICE_NAME' to enable the service."
}

# Remove plugin
tplug_remove() {
    SERVICE_NAME="$1"

    if [ -z "$SERVICE_NAME" ]; then
        echo "Usage: tplug remove <service_name>"
        exit 1
    fi

    if [ ! -d "$SERVICE_DIR/$SERVICE_NAME" ]; then
        echo "Error: Service $SERVICE_NAME does not exist."
        exit 1
    fi

    echo "Removing service $SERVICE_NAME..."
    rm -rf "$SERVICE_DIR/$SERVICE_NAME"

    echo "Service $SERVICE_NAME removed successfully."
}

# Main
COMMAND="$1"
shift

case "$COMMAND" in
    add)
        FLAG="$1"
        shift
        case "$FLAG" in
            -l)
                tplug_add_local "$@"
                ;;
            -g)
                tplug_add_github "$@"
                ;;
            *)
                echo "Usage: tplug add -l <service_name> | -g <repo_url> <service_name>"
                exit 1
                ;;
        esac
        ;;
    remove)
        tplug_remove "$@"
        ;;
    *)
        echo "Usage: tplug <command> [options]"
        echo "Commands:"
        echo "  add -l <service_name>            Add a new plugin from the local plugins directory"
        echo "  add -g <repo_url> <service_name> Add a new plugin from a GitHub repo"
        echo "  remove <service_name>           Remove an existing plugin"
        exit 1
        ;;
esac
