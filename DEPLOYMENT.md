# Deployment Guide

This document explains how to deploy the portable Claude Code statusline on different platforms.

## Quick Start

### macOS (Fresh Install)

```bash
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/install.sh | bash
```

Restart Claude Code to see the statusline.

### Linux / Devcontainer

Add to your `.devcontainer/postCreateCommand.sh` or run manually:

```bash
# After Claude Code is installed
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/install.sh | bash
```

The statusline will read OAuth tokens from `~/.claude/.credentials.json` automatically.

## OAuth Token Sources (Priority Order)

The statusline tries these sources in order:

1. **`CLAUDE_CODE_OAUTH_TOKEN` environment variable** (explicit override)
   ```bash
   export CLAUDE_CODE_OAUTH_TOKEN="your-token"
   ```

2. **`~/.claude/.credentials.json`** (Linux/devcontainers)
   ```json
   {
     "claudeAiOauth": {
       "accessToken": "your-token"
     }
   }
   ```

3. **macOS Keychain** (macOS only, via `security` command)
   - Automatically populated by Claude Code on macOS

If no token is found, the statusline still works - it just skips the 5h/7d quota display and shows session costs, context %, and model info.

## Verification

After installation, check that all scripts are in place:

```bash
ls -lh ~/.local/bin/claude-*
```

Expected output:
```
-rwxr-xr-x  1 user  staff   12K Feb 16 claude-billing-cost
-rwxr-xr-x  1 user  staff   9.5K Feb 16 claude-session-sync
-rwxr-xr-x  1 user  staff   6.5K Feb 16 claude-session-bootstrap
-rwxr-xr-x  1 user  staff   14K Feb 16 claude-statusline
```

Test the statusline manually:

```bash
~/.local/bin/claude-statusline '{"session_id":"test","cost":{"total_cost_usd":12.34},"context_window":{"used_percentage":15},"model":{"id":"claude-sonnet-4-5-20250929","display_name":"sonnet"}}'
```

Expected output (colors may vary):
```
5h:7%~3h28m | 7d:18%~18h28m = S:11% + O:245K | V:$12.34/$513 | C:+4/-24d | B:$0/$50 | X:15% | opusplan/sonnet
```

## Platform-Specific Notes

### macOS

- OAuth token is automatically read from Keychain
- No additional setup needed
- Works immediately after Claude Code install

### Linux

- OAuth token must be in `~/.claude/.credentials.json`
- Claude Code automatically creates this file when you sign in
- No manual token extraction needed

### Devcontainer

- OAuth token is typically mounted from host via Docker volume
- If not mounted, you can set `CLAUDE_CODE_OAUTH_TOKEN` in the container
- Firebase sync works across host and container if both have credentials

### CI/CD

- Set `CLAUDE_CODE_OAUTH_TOKEN` as environment variable
- Statusline will work without additional configuration
- Useful for automated Claude Code sessions

## Troubleshooting

### "No auth" message

This means no OAuth token was found. Check:

1. Is Claude Code signed in? Run `claude-code --version` and check auth status
2. On Linux, does `~/.claude/.credentials.json` exist?
3. On macOS, is the token in Keychain? Run:
   ```bash
   security find-generic-password -s "Claude Code-credentials" -w
   ```

### Statusline not updating

1. Check that Claude Code settings.json is configured:
   ```bash
   cat ~/.claude/settings.json
   ```
   Should contain:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.local/bin/claude-statusline"
     }
   }
   ```

2. Restart Claude Code

3. Check script permissions:
   ```bash
   ls -l ~/.local/bin/claude-statusline
   ```
   Should be executable (`-rwxr-xr-x`)

### Firebase sync not working

1. Check environment variables are set:
   ```bash
   echo $CLAUDE_FIREBASE_URL
   echo $CLAUDE_FIREBASE_SECRET
   ```

2. Test manually:
   ```bash
   claude-session-sync read
   ```

3. Check Firebase RTDB rules allow write access with secret

### Bootstrap existing data

If you have existing Claude Code usage and want to populate Firebase with your current billing cycle costs:

```bash
# Make sure Firebase env vars are set
echo $CLAUDE_FIREBASE_URL

# Bootstrap (one-time)
claude-session-bootstrap
```

This creates a synthetic session with your current billing cycle total, giving you an immediate baseline. Safe to run on multiple machines - each generates a unique session ID.

## Updates

To update to the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/bovorasr/claude-statusline/main/install.sh | bash
```

This will overwrite the scripts in `~/.local/bin/`.

## Uninstall

```bash
rm ~/.local/bin/claude-statusline
rm ~/.local/bin/claude-session-sync
rm ~/.local/bin/claude-billing-cost

# Remove from settings.json
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```
