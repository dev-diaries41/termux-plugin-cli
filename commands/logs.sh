#!/data/data/com.termux/files/usr/bin/sh

USR_PREFIX="/data/data/com.termux/files/usr"
SERVICE_DIR="$USR_PREFIX/var/service"
LOGS_DIR="$USR_PREFIX/var/log/sv"
TPLUG_CLI_DIR="/data/data/com.termux/files/home/.termux-plugin-cli"
. "$TPLUG_CLI_DIR/utils.sh"

CLEAR=false

while getopts "c" opt; do
    case "$opt" in
        c) CLEAR=true ;;
        *) error "Usage: tplug logs [-c] <service_name>" ;;
    esac
done
shift $((OPTIND-1))

SERVICE_NAME="$1"
LOG_FILE="$LOGS_DIR/$SERVICE_NAME/current"
LOG_DIR="$LOGS_DIR/$SERVICE_NAME"

if [ -z "$SERVICE_NAME" ]; then
    error "Usage: tplug logs [-c] <service_name>"
    exit 1
fi

# purge logs
if [ "$CLEAR" = true ]; then
    if [ -d "$LOG_DIR" ]; then
        echo "Purging logs for service: $SERVICE_NAME"
        rm -rf "$LOG_DIR"
        success "Logs purged successfully."
    else
        error "No logs found for service: $SERVICE_NAME"
    fi
    exit 0 
fi

if [ -f "$LOG_FILE" ]; then
    echo "Showing logs for service: $SERVICE_NAME"
    cat "$LOG_FILE"
else
    error "Log file for service $SERVICE_NAME does not exist."
fi
