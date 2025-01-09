#!/data/data/com.termux/files/usr/bin/sh

PLUGIN_SERVICES_DIR="/data/data/com.termux/files/home/.plugins/services"
PLUGIN_SCRIPTS_DIR="/data/data/com.termux/files/home/.plugins/scripts"
USR_PREFIX="/data/data/com.termux/files/usr"
SERVICE_DIR="$USR_PREFIX/var/service"
LOGS_DIR="$USR_PREFIX/var/log/sv"
LOGGER_PATH="$USR_PREFIX/share/termux-services/svlogger"
TERMUX_PLUGINS_REPO_URL=${TERMUX_PLUGINS_REPO_URL:-"https://github.com/dev-diaries41/termux-plugins.git"} # Allow override

# Colors for better output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

error() { echo "${RED}$*${NC}"; }
success() { echo "${GREEN}$*${NC}"; }
check_dir() {
    [ -d "$1" ] || { error "Error: Directory $1 does not exist."; exit 1; }
}

show_help() {
    echo "Usage: tplug <command> [options]"
    echo
    echo "Commands:"
    echo "  add <plugin_name>            Create a new termux-service by adding a plugin-service from a local directory."
    echo "  run <script_name> [args]     Run plugin-scripts from a local directory."
    echo "  install [<name> | -a] [-s | -r]"
    echo "                               Install plugin-services or plugin-scripts from the repository."
    echo "                               <name>         Install a specific plugin-service or plugin-script."
    echo "                               -a             Install all plugins (requires -s or -r)."
    echo "                               -s             Install plugin-services."
    echo "                               -r             Install plugin-scripts."
    echo "                               'i' or 'install' for installing plugins."
    echo "  logs [-c] <service_name>     View current logs for a termux-service. Use [-c] to clear logs."
    echo "  list [-S | -s | -r | -a]     List items (plugin-services, plugin-scripts, termux-services, or available plugin-services/scripts in repo)."
    echo "    -S                         List installed plugin-services."
    echo "    -s                         List installed termux-services."
    echo "    -r                         List installed plugin-scripts."
    echo "    -a                         List available plugin-services or plugin-scripts from the repository."
    echo "                               Use '-a -S' for plugin-services or '-a -r' for plugin-scripts."
    echo "    'ls' or 'list' for listing."
    echo "  remove <item_name> [-s | -S | -r] [-p]"
    echo "                               Remove a termux-service, plugin-service, or plugin-script."
    echo "                               <item_name>    Name of the service, plugin-service, or plugin-script to remove."
    echo "                               -s             Remove a termux-service."
    echo "                               -S             Remove a plugin-service."
    echo "                               -r             Remove a plugin-script."
    echo "                               -p             Purge logs when removing the service (only applicable to termux-services)."
    echo "                               'rm' or 'remove'."
    echo "  --help                      Show this help message."
    echo
}


check_dependencies() {
    REQUIRED_COMMANDS="git"
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v $cmd >/dev/null; then
            error "Required command '$cmd' is not installed."
            exit 1
        fi
    done
}

add_service() {
    local PLUGIN_NAME="$1"
    local PLUGIN_DIR="$PLUGIN_SERVICES_DIR/$PLUGIN_NAME"

    check_dir "$PLUGIN_DIR"

    if [ -f "$PLUGIN_DIR/plugin.txt" ]; then
        echo "Installing dependencies from plugin.txt..."
        while IFS= read -r DEP || [ -n "$DEP" ]; do
            if [ -n "$DEP" ]; then
                pkg install -y "$DEP" || { echo "Failed to install dependency: $DEP"; exit 1; }
            fi
        done < "$PLUGIN_DIR/plugin.txt"
    fi

    local SERVICE_NAME="$PLUGIN_NAME"
    mkdir -p "$SERVICE_DIR/$SERVICE_NAME/log"
    ln -sf "$LOGGER_PATH" "$SERVICE_DIR/$SERVICE_NAME/log/run"

    if [ -f "$PLUGIN_DIR/run" ]; then
        cp "$PLUGIN_DIR/run" "$SERVICE_DIR/$SERVICE_NAME/run"
        chmod 755 "$SERVICE_DIR/$SERVICE_NAME/run"
    else
        error "'run' script missing in $PLUGIN_DIR."; exit 1;
    fi

    # Enforce plugin-service file structure
    if [ -d "$PLUGIN_DIR/plugin" ]; then
        if [ ! -f "$PLUGIN_DIR/plugin/run.py" ] && [ ! -f "$PLUGIN_DIR/plugin/run.sh" ] && [ ! -f "$PLUGIN_DIR/plugin/run.ts" ] && [ ! -f "$PLUGIN_DIR/plugin/run.js" ]; then
            error "'run.py', 'run.sh', 'run.ts', or 'run.js' is missing in $PLUGIN_DIR/plugin."; exit 1;
        fi

        mkdir -p "$SERVICE_DIR/$SERVICE_NAME/plugin"
        cp -r "$PLUGIN_DIR/plugin/"* "$SERVICE_DIR/$SERVICE_NAME/plugin/"

        # Make scripts executable if they exist
        if [ -f "$PLUGIN_DIR/plugin/run.sh" ]; then
            chmod 755 "$SERVICE_DIR/$SERVICE_NAME/plugin/run.sh"
        fi

        # Check for package.json in plugin or plugin/src and run npm install if found
        if [ -f "$PLUGIN_DIR/plugin/package.json" ]; then
            echo "Found package.json in plugin directory. Running 'npm install'..."
            (cd "$PLUGIN_DIR/plugin" && npm install) || { echo "Failed to install npm dependencies"; exit 1; }
        elif [ -f "$PLUGIN_DIR/plugin/src/package.json" ]; then
            echo "Found package.json in plugin/src directory. Running 'npm install'..."
            (cd "$PLUGIN_DIR/plugin/src" && npm install) || { echo "Failed to install npm dependencies"; exit 1; }
        fi
    fi

    success "Plugin $PLUGIN_NAME added successfully."
}



install_plugin() {
    local ARG INSTALL_TYPE INSTALL_ALL=false PLUGIN_NAME DEST_DIR TEMP_DIR PLUGIN_DIR

    # Initialize options
    while getopts "sra" opt; do
        case $opt in
            s) INSTALL_TYPE="services" ;;
            r) INSTALL_TYPE="scripts" ;;
            a) INSTALL_ALL=true ;;
            *) echo "Usage: install_plugin [-s] [-r] [-a]" ; exit 1 ;;
        esac
    done

    # Handle the plugin name after options
    shift $((OPTIND - 1))
    ARG="$1"

    # Validation for options
    if [ "$INSTALL_ALL" = true ] && [ -z "$INSTALL_TYPE" ]; then
        echo "Error: -a flag must be used with either -s (services) or -r (scripts)"
        exit 1
    fi

    if [ -z "$INSTALL_TYPE" ] && [ "$INSTALL_ALL" = false ]; then
        echo "Error: You must specify a plugin type with -s or -r or use -a"
        exit 1
    fi

    # Create a temporary directory for cloning the repository
    TEMP_DIR=$(mktemp -d)

    echo "Cloning repository..."
    git clone --filter=blob:none --no-checkout "$TERMUX_PLUGINS_REPO_URL" "$TEMP_DIR" || {
        echo "Error: Failed to clone repository."
        exit 1
    }
    cd "$TEMP_DIR" || exit 1

    # Install all plugins if -a is set
    if [ "$INSTALL_ALL" = true ]; then
        echo "Installing all plugins from $INSTALL_TYPE..."
        git sparse-checkout init --cone && git checkout
        for PLUGIN in "$TEMP_DIR/$INSTALL_TYPE"/*/; do
            PLUGIN_NAME="$(basename "$PLUGIN")"
            DEST_DIR="${PLUGIN_SERVICES_DIR}/$PLUGIN_NAME"
            if [ "$INSTALL_TYPE" = "scripts" ]; then
                DEST_DIR="${PLUGIN_SCRIPTS_DIR}/$PLUGIN_NAME"
            fi
            check_dir "$PLUGIN"
            mkdir -p "$DEST_DIR"
            cp -r "$PLUGIN"/* "$DEST_DIR"
            if [ "$INSTALL_TYPE" = "services" ]; then
                add_service "$PLUGIN_NAME" 
            fi
            echo "Plugin $PLUGIN_NAME ($INSTALL_TYPE) installed successfully."
        done
    else
        echo "Installing plugin $ARG from $INSTALL_TYPE..."

        # Determine plugin directory based on INSTALL_TYPE
        if [ "$INSTALL_TYPE" = "services" ]; then
            PLUGIN_DIR="services"
        elif [ "$INSTALL_TYPE" = "scripts" ]; then
            PLUGIN_DIR="scripts"
        fi

        # Initialize sparse-checkout and set the plugin to install
        git sparse-checkout init --cone
        git sparse-checkout set "$PLUGIN_DIR/$ARG" && git checkout

        check_dir "$TEMP_DIR/$PLUGIN_DIR/$ARG"
        PLUGIN_NAME="$ARG"
        DEST_DIR="${PLUGIN_SERVICES_DIR}/$PLUGIN_NAME"
        if [ "$INSTALL_TYPE" = "scripts" ]; then
            DEST_DIR="${PLUGIN_SCRIPTS_DIR}/$PLUGIN_NAME"
        fi

        check_dir "$TEMP_DIR/$PLUGIN_DIR/$ARG"
        mkdir -p "$DEST_DIR"
        cp -r "$TEMP_DIR/$PLUGIN_DIR/$ARG"/* "$DEST_DIR"
        if [ "$INSTALL_TYPE" = "services" ]; then
            add_plugin "$PLUGIN_NAME"
        fi
        echo "Plugin $PLUGIN_NAME ($INSTALL_TYPE) installed successfully."
    fi

    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
}



list() {
    case "$1" in
        -S) check_dir "$PLUGIN_SERVICES_DIR"; echo "Installed Plugin Services:"; find "$PLUGIN_SERVICES_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No plugins services installed." ;;
        -r) check_dir "$PLUGIN_SCRIPTS_DIR"; echo "Installed Plugins Scripts:"; find "$PLUGIN_SCRIPTS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No plugins scripts installed." ;;
        -s) check_dir "$SERVICE_DIR"; echo "Installed Services:"; find "$SERVICE_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No services installed." ;;
        -a) 
            if [ -z "$2" ]; then
                echo "Error: -a flag must be used with either -s (services) or -r (scripts)"
                echo "Usage: list -a -s for all plugin services or list -a -r for all plugin scripts"
                exit 1
            fi
            TEMP_DIR=$(mktemp -d)
            echo "Fetching available plugins from the repository..."
            git clone --filter=blob:none --no-checkout "$TERMUX_PLUGINS_REPO_URL" "$TEMP_DIR" > /dev/null 2>&1 || { echo "Failed to clone repository."; exit 1; }
            cd "$TEMP_DIR" || exit 1
            git sparse-checkout init --cone
            
            case "$2" in
                -S)
                    echo "Available Plugin Services:"
                    git sparse-checkout set "services"
                    git checkout > /dev/null 2>&1
                    find "services" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No plugin services available."
                    ;;
                -r)
                    echo "Available Plugin Scripts:"
                    git sparse-checkout set "scripts"
                    git checkout > /dev/null 2>&1
                    find "scripts" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; || echo "No plugin scripts available."
                    ;;
                *)
                    echo "Error: Invalid argument for -a. Use -a -S for services or -a -r for scripts."
                    ;;
            esac
            rm -rf "$TEMP_DIR"
            ;;
        *) 
            echo "Usage:"
            echo "-S for installed plugin services"
            echo "-r for installed plugin scripts"
            echo "-s for termux-services"
            echo "-a -S for available plugin services"
            echo "-a -r for available plugin scripts"
            ;;
    esac
}


clear_logs() {
    local LOG_DIR="$LOGS_DIR/$1"
    if [ -d "$LOG_DIR" ]; then
        echo "Purging logs for service: $1"
        rm -rf "$LOG_DIR"
        success "Logs purged successfully."
    else
        error "No logs found for service: $1"
    fi
}

logs() {
    local CLEAR=false

    while getopts "c" opt; do
        case "$opt" in
            c) CLEAR=true ;;
            *) error "Usage: tplug logs [-c] <service_name>" ;;
        esac
    done
    shift $((OPTIND-1))

    local SERVICE_NAME="$1"
    local LOG_FILE="$LOGS_DIR/$SERVICE_NAME/current"
    local LOG_DIR="$LOGS_DIR/$SERVICE_NAME"

    if [ -z "$SERVICE_NAME" ]; then
        error "Usage: tplug logs [-c] <service_name>"
        exit 1
    fi

    # purge logs
    if [ "$CLEAR" = true ]; then
        clear_logs "$SERVICE_NAME"
        exit 0 
    fi

    if [ -f "$LOG_FILE" ]; then
        echo "Showing logs for service: $SERVICE_NAME"
        cat "$LOG_FILE"
    else
        error "Log file for service $SERVICE_NAME does not exist."
    fi
}

run() {
    local SCRIPT_NAME="$1"
    shift  
    local ADDITIONAL_PARAMS="$@" 

    check_dir "$PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME"

    if [ ! -e "$PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME/run" ]; then
        echo "Script $PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME/run not found."
        exit 1
    elif [ ! -x "$PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME/run" ]; then
        echo "Script $PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME/run is not executable."
        exit 1
    fi

    "$PLUGIN_SCRIPTS__DIR/$SCRIPT_NAME/run" $ADDITIONAL_PARAMS
}


check_dependencies

case "$1" in
    add) shift; add_service "$@" ;;
    install|i) shift; install_plugin "$@" ;;
    logs) shift; logs "$@" ;;
    remove|rm) shift; remove "$@" ;; 
    list|ls) shift; list "$@" ;;
    run) shift; run "$@" ;;
    --help) show_help ;;
    *) show_help ;;
esac
