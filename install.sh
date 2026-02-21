#!/bin/bash
set -euo pipefail

REPO="bovorasr/claude-statusline"
BASE="https://raw.githubusercontent.com/$REPO/main"
BIN_DIR="$HOME/.local/bin"

echo "Installing Claude Code statusline..."

# Create bin directory
mkdir -p "$BIN_DIR"

# Download and install scripts
for script in claude-statusline claude-statusline-collect claude-statusline-render claude-session-sync claude-session-bootstrap claude-billing-cost; do
    echo "  - Downloading $script..."
    curl -fsSL "$BASE/$script" -o "$BIN_DIR/$script"
    chmod +x "$BIN_DIR/$script"
done

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "  - Adding $BIN_DIR to PATH..."
    for rc in ~/.bashrc ~/.zshrc; do
        if [ -f "$rc" ]; then
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
                echo "    Added to $rc"
            fi
        fi
    done
    export PATH="$HOME/.local/bin:$PATH"
fi

# Configure Claude Code statusline (merge into settings.json)
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

echo "  - Configuring Claude Code settings..."
if [ -f "$SETTINGS" ] && jq empty "$SETTINGS" 2>/dev/null; then
    # Existing valid JSON - merge in statusLine config
    jq '.statusLine = {"type":"command","command":"~/.local/bin/claude-statusline"}' \
        "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
else
    # No file or invalid JSON - create new
    echo '{"statusLine":{"type":"command","command":"~/.local/bin/claude-statusline"}}' > "$SETTINGS"
fi

echo ""
echo "✓ Claude statusline installed to $BIN_DIR"
echo ""
echo "The statusline is now configured. Restart Claude Code to see it."
echo ""
echo "Optional: Set up Firebase cross-machine sync"
echo "  1. Create a Firebase Realtime Database at https://console.firebase.google.com"
echo "  2. Add to your shell RC file (~/.bashrc or ~/.zshrc):"
echo "       export CLAUDE_FIREBASE_URL='https://your-db.firebaseio.com'"
echo "       export CLAUDE_FIREBASE_SECRET='your-secret-token'"
echo "  3. Bootstrap with existing billing data (optional, one-time):"
echo "       source ~/.zshrc  # or ~/.bashrc"
echo "       claude-session-bootstrap"
echo ""
echo "Without Firebase, the statusline still works - it just shows '?' for monthly totals."
