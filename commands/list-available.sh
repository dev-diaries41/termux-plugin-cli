#!/data/data/com.termux/files/usr/bin/sh

TEMP_DIR=$(mktemp -d)
TERMUX_PLUGINS_REPO_URL=${TERMUX_PLUGINS_REPO_URL:-"https://github.com/dev-diaries41/termux-plugins.git"} # Allow override

echo "Fetching available plugins from the repository..."
git clone --filter=blob:none --no-checkout "$TERMUX_PLUGINS_REPO_URL" "$TEMP_DIR" > /dev/null 2>&1 || {
    error "Failed to clone repository."
    exit 1
}
cd "$TEMP_DIR" || exit 1

echo "Available plugins:"
git ls-tree -d --name-only HEAD | \
grep -v '^\.git$' | \
xargs -I {} basename {}

rm -rf "$TEMP_DIR"