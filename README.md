# Claude Code Statusline

Portable Claude Code statusline that works on **macOS, Linux, and devcontainers**. Shows real-time usage, session costs, Firebase cross-machine totals, context percentage, and model info.

## Features

- ✅ **Portable OAuth token reading** - works with:
  - Environment variable `CLAUDE_CODE_OAUTH_TOKEN`
  - Credentials file `~/.claude/.credentials.json` (Linux/devcontainers)
  - macOS Keychain (fallback)
- ✅ **5-hour and 7-day quota percentages** - color-coded (green/yellow/red)
- ✅ **Per-model breakdown** - Sonnet % (API data), Opus/Haiku tokens (for limit inference)
- ✅ **Billing cycle tracking** - days elapsed/remaining with DST-safe calculation
- ✅ **Session cost tracking** - see current session spend
- ✅ **Firebase cross-machine sync** - track monthly totals and 7-day token usage across all machines (optional)
- ✅ **Context window percentage** - monitor token usage
- ✅ **Model drift detection** - shows both configured and actual model
- ✅ **Overage tracking** - if you have overage enabled

## Installation

### Quick Install (works everywhere)

```bash
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/install.sh | bash
```

This installs to `~/.local/bin` and configures Claude Code automatically.

### Manual Install

```bash
# Download scripts
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/claude-statusline -o ~/.local/bin/claude-statusline
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/claude-session-sync -o ~/.local/bin/claude-session-sync
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/claude-billing-cost -o ~/.local/bin/claude-billing-cost
chmod +x ~/.local/bin/claude-*

# Add to PATH (if not already)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc

# Configure Claude Code
mkdir -p ~/.claude
cat > ~/.claude/settings.json <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "~/.local/bin/claude-statusline"
  }
}
EOF
```

## Optional: Firebase Cross-Machine Sync

Track session costs across all your machines in real-time.

1. **Create Firebase Realtime Database**:
   - Go to https://console.firebase.google.com
   - Create a new project
   - Enable Realtime Database
   - Copy the database URL (e.g., `https://your-db.firebaseio.com`)
   - Get the database secret from **Project Settings > Service Accounts > Database secrets**

2. **Add environment variables** to `~/.zshrc` or `~/.bashrc`:
   ```bash
   export CLAUDE_FIREBASE_URL='https://your-db.firebaseio.com'
   export CLAUDE_FIREBASE_SECRET='your-secret-token'
   ```

3. **Reload shell**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

4. **Bootstrap with existing data** (optional, one-time):
   ```bash
   claude-session-bootstrap
   ```

   This imports your current billing cycle costs from `~/.claude/stats-cache.json` into Firebase as a starting baseline. Safe to run on multiple machines - generates unique session IDs per machine/run.

Without Firebase, the statusline still works - monthly totals show `?`.

## What It Shows

Example statusline:
```
5h:7%~3h28m | 7d:18%~18h28m = S:11% + O:245K | V:$12.34/$513 | C:+4/-24d | B:$0/$50 | X:15% | opusplan/sonnet
```

**Quota & Usage:**
- `5h:7%~3h28m` - 5-hour quota at 7%, resets in 3h28m (color: green <70%, yellow 70-90%, red ≥90%)
- `7d:18%~18h28m` - 7-day quota at 18%, resets in 18h28m (color-coded same as 5h)
- `S:11%` - Sonnet using 11% of 7-day quota (real API data, color-coded)
- `O:245K` - Opus used 245K tokens in 7-day window (raw tokens for hidden limit inference)
- `H:50K` - Haiku tokens (only shown if >0)

**Costs & Billing:**
- `V:$12.34/$513` - **Value**: current session cost ($12.34) / monthly total across all machines ($513)
- `C:+4/-24d` - **Cycle**: 4 days elapsed / 24 days remaining in billing cycle (DST-safe)
- `B:$0/$50` - **Billing overage**: $0 used of $50 limit (only shown if overage enabled)

**Context & Model:**
- `X:15%` - Context window at 15% usage
- `opusplan/sonnet` - Configured model (from settings) / Actual model (detects drift when rate-limited)

**Color coding:**
- Green: <70% quota usage
- Yellow: 70-90% quota usage
- Red: ≥90% quota usage (approaching limit)
- Cyan: Time periods and cycle days
- Blue: Token counts and synthetic percentages
- Purple: Cost values

## Platform Support

| Feature | macOS (keychain) | Linux (credentials file) | Env var set |
|---|:---:|:---:|:---:|
| 5h/7d quota % | ✅ | ✅ | ✅ |
| Session cost | ✅ | ✅ | ✅ |
| Firebase total | ✅ | ✅ | ✅ |
| Context % | ✅ | ✅ | ✅ |
| Model display | ✅ | ✅ | ✅ |
| Overage display | ✅ | ✅ | ✅ |

**Without OAuth token**: Still shows session cost, Firebase total, context %, and model (just no quota %).

## Scripts

- **`claude-statusline`** - Main statusline script with portable OAuth token reading
- **`claude-session-sync`** - Firebase WAL (write-ahead log) + sync for cross-machine tracking
- **`claude-session-bootstrap`** - One-time import of existing billing data to Firebase
- **`claude-billing-cost`** - Local-only fallback for billing cycle cost calculation

### Bootstrap Script

The `claude-session-bootstrap` script imports your existing billing cycle costs into Firebase to give you a starting baseline. This is useful when:

- Setting up Firebase sync for the first time
- You already have Claude Code usage history
- You want your statusline to show accurate monthly totals immediately

**How it works:**
1. Reads token counts from `~/.claude/stats-cache.json`
2. Calculates API-equivalent cost for current billing cycle
3. Creates a synthetic session record with unique ID: `bootstrap-{hostname}-{timestamp}`
4. Uploads to Firebase

**Session ID format ensures:**
- No collisions between machines (includes hostname)
- Safe to re-run (includes timestamp)
- Identifiable as bootstrap data (has prefix)

**Example:**
```bash
# After setting up Firebase environment variables
claude-session-bootstrap

# Output:
# Billing cycle: 2026-02-12 to now
# Total billing cycle cost: $206.48
# Generated session ID: bootstrap-macbook-1739664000
# Uploading to Firebase...
# ✓ Successfully bootstrapped Firebase with $206.48
```

## Development

This repo is the canonical source for the portable statusline. To update:

1. Edit scripts in this repo
2. Push to `main` branch
3. Users can re-run `install.sh` to update

## Devcontainer Usage

Add to your `.devcontainer/postCreateCommand.sh` (after Claude Code install):

```bash
# Install Claude Code statusline
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/install.sh | bash
```

Same one-liner as macOS. Works everywhere.

## License

MIT

## Credits

Created for portable Claude Code usage tracking across macOS, Linux, and devcontainers.
