# notify_me.sh - Discord Webhook Notifier

A secure bash script for sending notifications to Discord via webhooks.

## Setup

1. **Create your .env file:**
   ```bash
   cp .env.example .env
   ```

2. **Add your Discord webhook URL to .env:**
   ```
   DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
   ```

3. **The script is already executable and available system-wide as `notify_me.sh`**

## Basic Usage

```bash
# Simple text message
notify_me.sh -m "Hello from the terminal!"

# With custom username
notify_me.sh -m "Build completed successfully" --username "CI Bot"

# Using embeds from JSON file
notify_me.sh --embed-file embed.json --username "Build System"

# Inline JSON embed
notify_me.sh --embed-json '{"title":"Alert","description":"Something happened","color":16711680}'
```

## Rich Embeds

Create JSON files for rich Discord embeds:

```json
{
  "title": "Build Status",
  "description": "Your build has finished",
  "color": 65280,
  "fields": [
    {"name": "Branch", "value": "main", "inline": true},
    {"name": "Status", "value": "✅ Success", "inline": true}
  ],
  "footer": {"text": "notify_me.sh"}
}
```

## Security Features

- **No URL exposure**: Webhook URLs are never shown in process lists
- **Local .env**: Secrets are kept in `.env` files, not committed to git
- **Input validation**: Message length and parameter validation
- **Rate limiting**: Automatic retry with Discord rate limits

## Options

- `-m, --message "text"` - Plain text message (1-2000 chars)
- `--embed-json 'JSON'` - Inline JSON embed
- `--embed-file path` - Load embed from JSON file  
- `--username "name"` - Override bot username
- `--avatar-url "url"` - Override bot avatar
- `--tts` - Enable text-to-speech
- `-h, --help` - Show help

Run `notify_me.sh --help` for detailed usage information.
