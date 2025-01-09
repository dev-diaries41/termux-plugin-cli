#!/data/data/com.termux/files/usr/bin/sh

# Colors for better output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Utility functions
error() {
    echo "${RED}$*${NC}"
}

success() {
    echo "${GREEN}$*${NC}"
}

check_dir() {
    [ -d "$1" ] || { error "Error: Directory $1 does not exist."; exit 1; }
}
