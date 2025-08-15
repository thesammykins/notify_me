# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

- **Project**: notify_me.sh — a secure, feature-rich bash script to send webhook notifications to Discord and/or Slack
- **Key capabilities**: multi-service support, native rich formatting (Discord embeds, Slack blocks/attachments), robust input validation, rate limiting with retries, secure webhook handling (not exposed in process lists), and simple system-wide install
- **Platform**: macOS (bash), dependency: curl (preinstalled on macOS; install via Homebrew if missing)

## 1) Quickstart: Commonly used commands

### Initial setup
```bash
# From repo root
cp .env.example .env
# Edit .env and update webhook placeholders:
# DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
# SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/XXXX"
```

### Install to PATH (optional)
```bash
./notify_me.sh --install-path
# After this, you can run `notify_me.sh` from anywhere
```

### Help and guide
```bash
notify_me.sh --help
./notify_me.sh --show-agent-guide  # Displays AGENT.md
```

### Basic usage
```bash
# Auto-detected service based on your .env
notify_me.sh -m "Hello from notify_me! 👋"

# Target Slack explicitly
notify_me.sh --service slack -m "Deploy completed" --username "CI/CD Bot"

# Target Discord with TTS
notify_me.sh --service discord -m "URGENT: System alert!" --tts

# Send to both (succeeds if any one succeeds)
notify_me.sh --service both -m "System alert!" --username "Monitor"
```

### Rich content (service-native)

**Discord: embed object/array**
```bash
notify_me.sh --service discord --embed-json '{
  "title":"Build Status",
  "description":"All tests passed",
  "color":65280
}'
```

**Slack: blocks (array) or attachments (object)**
```bash
# Blocks
notify_me.sh --service slack --embed-json '[
  {"type":"section","text":{"type":"mrkdwn","text":"*Deploy Complete* 🚀\nAll systems operational"}}
]'

# Attachments
notify_me.sh --service slack --embed-json '{
  "attachments":[{"color":"good","title":"✅ Success","text":"All tests passed"}]
}'
```

### Load JSON from file
```bash
# Provide a service-specific JSON file (examples in README)
notify_me.sh --service discord --embed-file discord-success.json
notify_me.sh --service slack   --embed-file slack-success.json
```

### Environment overrides (runtime)
```bash
NOTIFY_ME_ENV_FILE=/custom/path/.env notify_me.sh -m "Hello"
NOTIFY_ME_ENV_DIR=/custom/dir       notify_me.sh -m "Hello"
```

### Testing and debugging
```bash
# Help output
notify_me.sh --help

# Error handling: temporarily remove .env and expect a clear error
mv .env .env.backup
notify_me.sh -m "test"
mv .env.backup .env

# Discord message length check (should error if >2000 chars)
longmsg="$(printf 'x%.0s' {1..2001})"
notify_me.sh -m "$longmsg"

# Unknown option handling (should show helpful error)
notify_me.sh --invalid-option

# Verbose bash debug (no webhook URL is exposed by design)
bash -x notify_me.sh -m "debug message"
```

### Optional: 1Password secret retrieval (if your team uses it)
- Do not commit secrets. Replace item/field names with your actual vault values.
```bash
export DISCORD_WEBHOOK_URL="$(op item get "Discord Webhook URL" --vault "API Credentials" --field "url" --reveal)"
export SLACK_WEBHOOK_URL="$(op item get "Slack Webhook URL"   --vault "API Credentials" --field "url" --reveal)"
notify_me.sh -m "Hello via env overrides"
```

## 2) High-level architecture and code structure

### Top-level files
- **notify_me.sh**: main executable with argument parsing, env loading, secure webhook posting, payload building, and retries
- **README.md**: features, setup, usage, troubleshooting
- **AGENT.md**: strict guidance for LLM/agent usage (do not modify code)
- **.env.example**: webhook placeholders
- **embed.json**: example Discord embed

### Execution flow (big picture)
1. **resolve_script_dir**: Resolves real script path (handles symlinks)
2. **load_env**: Loads .env (default next to script) or via NOTIFY_ME_ENV_FILE/NOTIFY_ME_ENV_DIR
3. **Argument parsing**: --message/--embed-json/--embed-file, --service (discord|slack|both), --username, --avatar-url, --tts, etc.
4. **Service selection**: Auto-detect based on which webhook(s) exist; defaults to Discord if both are set (use --service both for both)
5. **Payload building**:
   - Discord: build_discord_payload constructs {"content","embeds","username","avatar_url","tts"}
   - Slack: build_slack_payload constructs {"text","blocks","attachments","username","icon_url"}; merges object keys when given an object payload
6. **Senders with retries**:
   - send_discord: HTTP 204/200 success, retries on 429 using Retry-After
   - send_slack: HTTP 200 success, retries on 429 using Retry-After
   - Webhook URLs piped to curl via stdin (never in process list)
7. **Exit behavior**:
   - Single target: exit status reflects that send's success
   - Both: exits 0 if any send succeeds; 1 only if all fail

### Service-specific behavior
- **Discord**: 2000-char content limit enforced; TTS supported; "embeds" accepts object or array
- **Slack**: TTS ignored; blocks must be array; attachments supported via object; HTTP success is 200

## 3) Important points from README.md and AGENT.md

- **Do not modify notify_me.sh unless explicitly requested**. Use existing options and follow AGENT.md
- **Service auto-detection rules**:
  - Only DISCORD_WEBHOOK_URL → discord
  - Only SLACK_WEBHOOK_URL → slack
  - Both set → defaults to discord; use --service both for both
- **Environment variables**:
  - DISCORD_WEBHOOK_URL, SLACK_WEBHOOK_URL
  - NOTIFY_ME_ENV_FILE, NOTIFY_ME_ENV_DIR
- **Security features**:
  - Webhooks never placed on command line; passed via curl stdin
  - Temp files created with umask 077
  - No webhook URL appears in logs or errors
- **Rate limiting**:
  - Retries on 429 with Retry-After header for both Discord and Slack
- **Exit codes**:
  - Single service: pass/fail reflects that service
  - Both: success if any succeed
- **Colors (Discord decimal / Slack hex)**:
  - Success: 65280 / #36a64f or good
  - Error: 16711680 / #ff0000 or danger
  - Warning: 16753920 / #ffa500 or warning
  - Info: 3447003 / #3498db

## 4) Configuration and environment setup

### Standard setup
```bash
cp .env.example .env
# Set one or both:
# DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
# SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/XXXX"
```

### Alternate .env locations
```bash
NOTIFY_ME_ENV_FILE=/path/to/.env notify_me.sh -m "Hello"
NOTIFY_ME_ENV_DIR=/path/to/dir  notify_me.sh -m "Hello"
```

### Webhook creation references
- **Discord**: Server Settings → Integrations → Webhooks → Create → Copy URL
- **Slack**: Create app → enable Incoming Webhooks → Add New Webhook to Workspace → Copy URL

### Dependencies
- curl (install via Homebrew if missing: `brew install curl`)

## 5) Security considerations and best practices

- **Never commit secrets**. Do not include real webhook URLs in docs, commands, or screenshots
- .env is gitignored; keep file permissions restrictive (e.g., `chmod 600 .env`)
- Prefer environment overrides for ephemeral usage; avoid shell history leakage
- The script already minimizes exposure (stdin for curl, strict umask)
- Use `bash -x` only when necessary; payloads may appear in debug output (webhooks will not)
- Validate your JSON locally before sending (optional): `echo 'JSON' | jq -e . >/dev/null`

## 6) Developer workflow in WARP

- **Do not modify notify_me.sh or AGENT.md unless requested**. Most needs are covered by flags and payload JSON
- **Typical flow**:
```bash
git checkout -b feature/my-changes
# make changes
git add .
git commit -m "docs: describe changes"
# Push only if user approves
# git push origin feature/my-changes
```

- **Notify stakeholders (optional)** via this repo's tool:
```bash
# at start of a longer task
notify_me.sh --service both -m "Starting documentation task" --username "Docs Bot"

# when finished
notify_me.sh --service both -m "Documentation ready for review ✅" --username "Docs Bot"
```

## 7) Troubleshooting quick refs

- **Missing webhooks**:
  - Ensure .env exists and URLs are correct
- **Discord 2000 char limit**:
  - Use embeds or split messages
- **API errors (400/other)**:
  - Validate JSON format and required fields
- **Rate-limited (429)**:
  - The script retries; consider spacing out messages

## 8) Reference links

- [Discord Webhook Docs](https://discord.com/developers/docs/resources/webhook)
- [Discord Embed Structure](https://discord.com/developers/docs/resources/channel#embed-object)
