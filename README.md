# Claude Code Statusline

Portable Claude Code statusline that works on **macOS, Linux, and devcontainers**. Shows real-time usage, session costs, Firebase cross-machine totals, context percentage, and model info.

## Features

- ✅ **Portable OAuth token reading** - works with:
  - Environment variable `CLAUDE_CODE_OAUTH_TOKEN`
  - Credentials file `~/.claude/.credentials.json` (Linux/devcontainers)
  - macOS Keychain (fallback)
- ✅ **5-hour and 7-day quota percentages** - color-coded (green/yellow/red)
- ✅ **Windowed costs** - Firebase-tracked spend within each quota window (5h/7d)
- ✅ **Per-query cost** - cost delta of the most recent query
- ✅ **Per-model breakdown** - Sonnet % (API data), Opus/Haiku tokens (for limit inference)
- ✅ **Billing cycle tracking** - days elapsed/remaining with DST-safe calculation
- ✅ **Session and monthly cost tracking** - current session + cross-machine monthly total
- ✅ **Firebase cross-machine sync** - monthly totals, 7-day token usage, and windowed costs across all machines (optional)
- ✅ **Context window percentage** - monitor token usage
- ✅ **Model drift detection** - shows both configured and actual model
- ✅ **Overage tracking** - if you have overage enabled
- ✅ **Project/git info line** - workspace directory, Obsidian vault detection, git branch, remote, ahead/behind, and file status (5s cached)

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

2. **Lock down Security Rules** (important — do this before adding any data):

   Firebase databases default to open rules that allow anyone with your database URL to read your data. Lock it down:

   - In the Firebase console, go to **Realtime Database > Rules**
   - Replace the rules with:
     ```json
     {
       "rules": {
         ".read": false,
         ".write": false
       }
     }
     ```
   - Click **Publish**

   The scripts authenticate using the database secret, which is a legacy admin token that bypasses these rules — so your scripts continue to work. This change only blocks unauthenticated access (anyone who stumbles across your database URL).

3. **Add environment variables** to `~/.zshrc` or `~/.bashrc`:
   ```bash
   export CLAUDE_FIREBASE_URL='https://your-db.firebaseio.com'
   export CLAUDE_FIREBASE_SECRET='your-secret-token'
   ```

   Keep `CLAUDE_FIREBASE_SECRET` out of any files you commit to git.

4. **Reload shell**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

5. **Bootstrap with existing data** (optional, one-time):
   ```bash
   claude-session-bootstrap
   ```

   This imports your current billing cycle costs from `~/.claude/stats-cache.json` into Firebase as a starting baseline. Safe to run on multiple machines - generates unique session IDs per machine/run.

Without Firebase, the statusline still works - monthly totals show `?`.

## What It Shows

Example statusline (with Firebase configured, in a git repo):
```
◆ my-vault->subfolder ☁main->origin/main ↑2 ↓1 3M 1?
7% $3.50 2h15m | 18% $28.40 6d18h = S:11% + O:245K | +6/-22d 25¢/$12.34/$513 $0/$50 | opusplan/Sonnet 4.6 15%
```

The statusline has two lines when workspace info is available:
1. **Project/git info line** (top) — workspace context and git status
2. **Cost/quota line** (bottom) — usage, costs, and model info

If no workspace info is passed by Claude Code, only the cost/quota line is shown.

---

**Project/git info line** — left to right:

| Element | Condition | Format |
|---------|-----------|--------|
| `◆` | `.obsidian/` dir in project root | Purple diamond (Obsidian vault) |
| `my-vault` | Always (if project dir known) | Project basename in cyan; `~` if HOME |
| `->subfolder` | Current dir ≠ project dir | Current dir basename with dim arrow |
| `☁` | Git repo with remote | Yellow cloud |
| `⌂` | Git repo, local only | Yellow home |
| `main` | In a git repo | Branch name in cyan |
| `->origin/main` | Has tracking branch | Remote branch with dim arrow |
| `↑2` | Ahead of remote | Green |
| `↓1` | Behind remote | Red |
| `3M` | Modified files | Yellow |
| `1?` | Untracked files | Yellow |
| `N+` | Added (staged) files | Green |
| `N-` | Deleted files | Red |
| `N⚡` | Merge conflicts | Red |

---

**Cost/quota line** — left to right:

Color does the labeling — no section headers needed.

**5-hour quota group:**
- `7%` - 5-hour quota usage (green <70%, yellow 70–90%, red ≥90%)
- `$3.50` - spend within the 5-hour window (purple, omitted if zero / Firebase not configured)
- `2h15m` - time until reset (cyan, omitted if unavailable)

**7-day quota group:**
- `18%` - 7-day quota usage (color-coded same as 5h)
- `$28.40` - spend within the 7-day window (purple, omitted if zero)
- `6d18h` - time until reset (cyan)
- `= S:11% + O:245K` - per-model breakdown: Sonnet % from API, Opus/Haiku raw tokens. Dark gray letters, dim colons.

**Billing period group:**
- `+6/-22d` - days elapsed / remaining in billing cycle (cyan, DST-safe)
- `25¢/$12.34/$513` - last query cost / session total / monthly total across all machines (purple). Amounts under $1 shown as cents (e.g. `25¢`). Query cost omitted if not yet available.
- `$0/$50` - overage used / limit (only shown if overage is enabled; green/yellow/red)

**Model group:**
- `opusplan/Sonnet 4.6` - configured model / actual model (dark cyan; detects drift when rate-limited)
- `15%` - context window usage (bright cyan)

**Without Firebase:** windowed costs and monthly total show `?`; quota % and all other fields still work.

**Color reference:**
| Color | Meaning |
|---|---|
| Green/Yellow/Red | Quota % thresholds (<70% / 70–90% / ≥90%) |
| Cyan | Time periods, billing cycle days, directory names, branch names |
| Bright cyan | Context window % |
| Dark cyan | Model names |
| Blue | Token counts |
| Purple | Cost values |
| Purple (135) | Obsidian vault icon |
| Yellow | Git icons, modified/untracked file counts |
| Dark gray | Model letter prefixes (S/O/H) |

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
