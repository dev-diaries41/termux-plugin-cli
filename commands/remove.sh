#!/data/data/com.termux/files/usr/bin/sh


USR_PREFIX="/data/data/com.termux/files/usr"
SERVICE_DIR="$USR_PREFIX/var/service"
TPLUG_CLI_DIR="/data/data/com.termux/files/home/.termux-plugin-cli"
. "$TPLUG_CLI_DIR/utils.sh"

SERVICE_NAME="$1"
PURGE="$2"

if [ -z "$SERVICE_NAME" ]; then
    error "Usage: tplug remove <service_name> [--purge]"
    exit 1
fi

check_dir "$SERVICE_DIR/$SERVICE_NAME"
echo "Removing service $SERVICE_NAME..."
[ -L "$SERVICE_DIR/$SERVICE_NAME/log/run" ] && unlink "$SERVICE_DIR/$SERVICE_NAME/log/run"
rm -rf "$SERVICE_DIR/$SERVICE_NAME"

if [ "$PURGE" = "--purge" ]; then
    LOG_DIR="$LOGS_DIR/$SERVICE_NAME"
    if [ -d "$LOG_DIR" ]; then
        echo "Purging logs for service: $SERVICE_NAME"
        rm -rf "$LOG_DIR"
        success "Logs purged successfully."
    else
        error "No logs found for service: $SERVICE_NAME"
    fi
fi

success "Service $SERVICE_NAME removed successfully."


