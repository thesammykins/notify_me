# notify_me.sh - Multi-Service Webhook Notifier

> A secure, feature-rich bash script for sending notifications to Discord and/or Slack via webhooks.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

## ✨ Features

- 🔒 **Secure**: Webhook URLs never exposed in process lists
- 🎯 **Multi-Service**: Support for Discord, Slack, or both simultaneously
- 📱 **Rich Messages**: Service-native formatting (Discord embeds, Slack blocks/attachments)
- 🛡️ **Robust**: Input validation, rate limiting, automatic retries
- 🌍 **System-wide**: Available from anywhere via PATH
- 📝 **Flexible**: Support for inline JSON and external files (Discord)
- 🤖 **LLM-friendly**: Simple interface for automated usage

## 🚀 Quick Start

### 1. Setup Your Webhook(s)

```bash
# Copy the example configuration
cp .env.example .env

# Edit .env and add your webhook URL(s)
# DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
# SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/XXXX"
```

**Getting Webhook URLs:**

**Discord:**
1. Go to your Discord server settings
2. Navigate to "Integrations" → "Webhooks"
3. Click "Create Webhook" or "New Webhook"
4. Copy the webhook URL

**Slack:**
1. Go to https://api.slack.com/incoming-webhooks
2. Click "Create New App" or use an existing app
3. Enable "Incoming Webhooks"
4. Click "Add New Webhook to Workspace"
5. Copy the webhook URL

### 2. Install System-wide (Optional)

```bash
# Make notify_me.sh available from anywhere
./notify_me.sh --install-path
```

This creates a symlink in your system's bin directory so you can use `notify_me.sh` from any location.

### 3. Test It Out

```bash
# Simple message (auto-detected service)
notify_me.sh -m "Hello from notify_me! 👋"

# Specific service
notify_me.sh --service slack -m "Deploy completed successfully" --username "CI/CD Bot"

# Rich content from file
notify_me.sh --embed-file embed.json --username "System Monitor"

# Both services
notify_me.sh --service both -m "System alert!" --username "Monitor"
```

## 🎛️ Services

notify_me.sh supports Discord, Slack, or both services simultaneously.

### Service Selection

If `--service` is not specified, the service is auto-detected based on your `.env` configuration:
- Only `DISCORD_WEBHOOK_URL` set → **discord**
- Only `SLACK_WEBHOOK_URL` set → **slack**
- Both URLs set → **discord** (for backward compatibility)
- Use `--service both` to send to both services

### Environment Variables

- `DISCORD_WEBHOOK_URL`: Discord webhook URL
- `SLACK_WEBHOOK_URL`: Slack incoming webhook URL
- `NOTIFY_ME_ENV_FILE`: Custom path to .env file
- `NOTIFY_ME_ENV_DIR`: Custom directory containing .env file

## 📖 Usage Examples

### Simple Text Messages

```bash
# Auto-detected service
notify_me.sh -m "Task completed"

# Discord with TTS
notify_me.sh --service discord -m "URGENT: System alert!" --tts

# Slack message
notify_me.sh --service slack -m "Deploy finished" --username "CI Bot"

# Both services
notify_me.sh --service both -m "Server backup finished" --username "Backup Bot"
```

### Rich Content

Each service uses its native rich formatting:
- **Discord**: Embeds (objects/arrays)
- **Slack**: Blocks (arrays) or attachments (via object merge)

#### Discord Embeds

```bash
# Simple Discord embed
notify_me.sh --service discord --embed-json '{
  "title": "Build Status",
  "description": "All tests passed",
  "color": 65280
}'

# Complex Discord embed with fields
notify_me.sh --service discord --embed-json '{
  "title": "Deployment Complete",
  "description": "Application deployed successfully",
  "color": 5814783,
  "fields": [
    {"name": "Environment", "value": "Production", "inline": true},
    {"name": "Version", "value": "v2.1.0", "inline": true},
    {"name": "Duration", "value": "3m 42s", "inline": true}
  ],
  "timestamp": "2024-01-15T10:30:00.000Z"
}' --username "Deploy Bot"
```

#### Slack Blocks

```bash
# Slack blocks (array format)
notify_me.sh --service slack --embed-json '[
  {
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "*Deploy Complete* 🚀\n\nAll systems operational"
    }
  },
  {
    "type": "context",
    "elements": [
      {
        "type": "mrkdwn",
        "text": "Version v1.2.3 • Production • 2m 15s"
      }
    ]
  }
]' --username "Deploy Bot"
```

#### Slack Attachments

```bash
# Slack attachments (object format)
notify_me.sh --service slack --embed-json '{
  "attachments": [
    {
      "color": "#36a64f",
      "title": "✅ Success",
      "text": "All tests passed",
      "fields": [
        {"title": "Environment", "value": "Production", "short": true},
        {"title": "Duration", "value": "3m 42s", "short": true}
      ]
    }
  ]
}'
```

#### From JSON Files (Discord Only)

**⚠️ Important:** File-based JSON (`--embed-file`) works reliably with **Discord only**. For **Slack**, use inline JSON with `--embed-json` to avoid potential payload issues.

Create Discord embed files:

**discord-success.json:**
```json
{
  "title": "✅ Success",
  "description": "Operation completed successfully",
  "color": 65280,
  "fields": [
    {"name": "Status", "value": "Complete", "inline": true},
    {"name": "Time", "value": "2m 15s", "inline": true}
  ]
}
```

Then use them:
```bash
# Discord - File-based (recommended)
notify_me.sh --service discord --embed-file discord-success.json

# Slack - Use inline JSON instead
notify_me.sh --service slack --embed-json '[
  {
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "✅ *Success*\n\nOperation completed successfully"
    }
  }
]'
```

## 🎨 Colors

**Discord Embed Colors (decimal):**
- **Green (Success)**: `65280` or `0x00FF00`
- **Red (Error)**: `16711680` or `0xFF0000`
- **Orange (Warning)**: `16753920` or `0xFFA500`
- **Blue (Info)**: `3447003` or `0x3498DB`
- **Purple**: `8388736` or `0x800080`
- **Yellow**: `16776960` or `0xFFFF00`

**Slack Colors (hex):**
- **Green**: `#36a64f` or `good`
- **Red**: `#ff0000` or `danger`
- **Orange**: `#ffa500` or `warning`
- **Blue**: `#3498db`
- **Purple**: `#9b59b6`

## 🛠️ Configuration

### Environment Variables

- `DISCORD_WEBHOOK_URL`: Discord webhook URL
- `SLACK_WEBHOOK_URL`: Slack incoming webhook URL  
- `NOTIFY_ME_ENV_FILE`: Custom path to .env file
- `NOTIFY_ME_ENV_DIR`: Custom directory containing .env file

### Examples

```bash
# Use custom .env location
NOTIFY_ME_ENV_FILE=/path/to/custom/.env notify_me.sh -m "Hello"

# Use .env from different directory
NOTIFY_ME_ENV_DIR=/path/to/config notify_me.sh -m "Hello"

# Override service selection
notify_me.sh --service both -m "Multi-service message"
```

## 🔧 Command Line Options

| Option | Description |
|--------|-------------|
| `-m, --message "text"` | Plain text message |
| `--service SERVICE` | Target service: `discord`, `slack`, or `both` |
| `--embed-json 'JSON'` | Rich content JSON (service-specific format) |
| `--embed-file path` | Load rich content from JSON file (Discord only) |
| `--username "name"` | Override display username |
| `--avatar-url "url"` | Override avatar (Discord) or icon (Slack) |
| `--tts` | Enable text-to-speech (Discord only) |
| `--install-path` | Install script to system PATH |
| `--show-agent-guide` | Display LLM/Agent usage guide |
| `-h, --help` | Show detailed help |

## 🔒 Security Features

### Webhook Protection
- URLs are passed to curl via stdin, never appearing in process lists
- Temporary files are created with restrictive permissions (077)
- No webhook URLs are logged or displayed in error messages

### Input Validation
- Message length validation (Discord's 2000 character limit)
- JSON syntax validation for embeds
- File existence checks for embed files
- Parameter validation with helpful error messages

### Rate Limiting
- Automatic retry on HTTP 429 (rate limit) responses
- Respects Discord's `Retry-After` header
- Configurable retry attempts (default: 2)

## 🧪 Testing

```bash
# Test help output
notify_me.sh --help

# Test error handling (no webhook configured)
mv .env .env.backup
notify_me.sh -m "test"  # Should show clear error
mv .env.backup .env

# Test message length validation
longmsg="$(printf 'x%.0s' {1..2001})"
notify_me.sh -m "$longmsg"  # Should show length error

# Test unknown option handling
notify_me.sh --invalid-option  # Should show helpful error
```

## 🔍 Troubleshooting

### Common Issues

**"DISCORD_WEBHOOK_URL is not set"**
- Ensure `.env` file exists and contains your webhook URL
- Check that the URL format is correct: `https://discord.com/api/webhooks/ID/TOKEN`

**"Message exceeds Discord 2000 character limit"**
- Break long messages into smaller parts
- Consider using embeds for structured content

**"Discord API error (HTTP 400)"**
- Check your JSON syntax for embeds
- Ensure required fields are present
- Verify webhook URL is valid

**"curl: command not found"**
- Install curl: `brew install curl` (macOS with Homebrew)
- curl is pre-installed on most macOS systems

### Debug Mode

For debugging, you can run with verbose output:
```bash
bash -x notify_me.sh -m "debug message"
```

## 📁 Project Structure

```
notify_me/
├── notify_me.sh         # Main executable script
├── .env.example         # Environment template
├── .env                 # Your webhook configuration (gitignored)
├── .gitignore          # Git ignore rules
├── README.md           # This file
├── AGENT.md            # Quick reference for LLMs/agents
└── embed.json          # Example embed file
```

## 🤖 LLM/Agent Integration

See [AGENT.md](AGENT.md) for a concise reference when using this tool programmatically.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 🔗 Links

- [Discord Webhook Documentation](https://discord.com/developers/docs/resources/webhook)
- [Discord Embed Structure](https://discord.com/developers/docs/resources/channel#embed-object)
- [Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
