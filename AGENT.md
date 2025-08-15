# AGENT.md - notify_me.sh Reference

> Quick reference for LLMs and automated agents using notify_me.sh for Discord and/or Slack

## ⚠️ IMPORTANT: DO NOT MODIFY CODE

**🛑 NEVER modify, edit, or suggest changes to the notify_me.sh script code unless the user explicitly requests code modifications.**

This tool is production-ready and stable. Your role is to:
- ✅ **Use the existing script** as-is for Discord and/or Slack notifications
- ✅ **Reference this guide** for proper usage patterns
- ✅ **Help troubleshoot** configuration and usage issues
- ❌ **DO NOT** suggest code improvements or modifications
- ❌ **DO NOT** propose "better" implementations
- ❌ **DO NOT** edit the script files unless explicitly asked

If the user needs different functionality, suggest using the existing options or ask them to explicitly request script modifications.

## 🚀 Quick Usage

```bash
# Simple notification (auto-detected service)
notify_me.sh -m "Your message here"

# Service-specific notification
notify_me.sh --service slack -m "Deploy completed"

# Both services
notify_me.sh --service both -m "System alert" --username "Monitor"

# Discord embed
notify_me.sh --service discord --embed-json '{"title":"Status","description":"Details","color":65280}'

# Slack blocks
notify_me.sh --service slack --embed-json '[{"type":"section","text":{"type":"mrkdwn","text":"*Status Update*"}}]'
```

## 🎛️ Service Selection

### Auto-Detection (Default)
- Only DISCORD_WEBHOOK_URL → discord
- Only SLACK_WEBHOOK_URL → slack
- Both URLs configured → discord (backward compatibility)

### Manual Selection
```bash
# Target specific service
notify_me.sh --service discord -m "Message"
notify_me.sh --service slack -m "Message"
notify_me.sh --service both -m "Message"
```

## 📋 Command Patterns

### Basic Text Messages
```bash
# Auto-detected service
notify_me.sh -m "Build completed successfully"

# Discord with TTS
notify_me.sh --service discord -m "URGENT: Server down!" --tts

# Slack message
notify_me.sh --service slack -m "Deploy finished" --username "CI Bot"

# Both services
notify_me.sh --service both -m "System alert" --username "Monitor"
```

### Status Updates (Success/Warning/Error)

#### Discord Embeds
```bash
# Success (Green)
notify_me.sh --service discord --embed-json '{"title":"✅ Success","description":"Operation completed","color":65280}'

# Warning (Orange) 
notify_me.sh --service discord --embed-json '{"title":"⚠️ Warning","description":"Check required","color":16753920}'

# Error (Red)
notify_me.sh --service discord --embed-json '{"title":"❌ Error","description":"Operation failed","color":16711680}'
```

#### Slack Blocks
```bash
# Success
notify_me.sh --service slack --embed-json '[{"type":"section","text":{"type":"mrkdwn","text":"✅ *Success*\nOperation completed"}}]'

# Warning
notify_me.sh --service slack --embed-json '[{"type":"section","text":{"type":"mrkdwn","text":"⚠️ *Warning*\nCheck required"}}]'

# Error
notify_me.sh --service slack --embed-json '[{"type":"section","text":{"type":"mrkdwn","text":"❌ *Error*\nOperation failed"}}]'
```

#### Slack Attachments
```bash
# Success
notify_me.sh --service slack --embed-json '{"attachments":[{"color":"good","title":"✅ Success","text":"Operation completed"}]}'

# Warning
notify_me.sh --service slack --embed-json '{"attachments":[{"color":"warning","title":"⚠️ Warning","text":"Check required"}]}'

# Error
notify_me.sh --service slack --embed-json '{"attachments":[{"color":"danger","title":"❌ Error","text":"Operation failed"}]}'
```

### Build/Deploy Notifications

#### Discord
```bash
notify_me.sh --service discord --embed-json '{
  "title":"🚀 Deploy Complete", 
  "description":"Application deployed to production",
  "color":5814783,
  "fields":[
    {"name":"Version","value":"v1.2.3","inline":true},
    {"name":"Environment","value":"Production","inline":true},
    {"name":"Duration","value":"2m 15s","inline":true}
  ]
}' --username "Deploy Bot"
```

#### Slack
```bash
notify_me.sh --service slack --embed-json '[
  {
    "type":"section",
    "text":{
      "type":"mrkdwn",
      "text":"🚀 *Deploy Complete*\nApplication deployed to production"
    }
  },
  {
    "type":"section",
    "fields":[
      {"type":"mrkdwn","text":"*Version:*\nv1.2.3"},
      {"type":"mrkdwn","text":"*Environment:*\nProduction"},
      {"type":"mrkdwn","text":"*Duration:*\n2m 15s"}
    ]
  }
]' --username "Deploy Bot"
```

## 🎨 Common Colors

| Status | Color Code | Hex |
|--------|------------|-----|
| Success/Green | `65280` | `0x00FF00` |
| Error/Red | `16711680` | `0xFF0000` |
| Warning/Orange | `16753920` | `0xFFA500` |
| Info/Blue | `3447003` | `0x3498DB` |
| Purple | `8388736` | `0x800080` |

## 📝 JSON Embed Template

```json
{
  "title": "Title Here",
  "description": "Description text",
  "color": 65280,
  "fields": [
    {"name": "Field Name", "value": "Field Value", "inline": true}
  ],
  "footer": {"text": "Bot Name"},
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## 📝 Options Reference

| Option | Usage | Example |
|--------|-------|---------|
| `-m, --message` | Plain text message | `-m "Hello world"` |
| `--service` | Target service | `--service discord\|slack\|both` |
| `--embed-json` | Rich content JSON | `--embed-json '{...}'` |
| `--embed-file` | JSON file path (Discord only) | `--embed-file status.json` |
| `--username` | Display username | `--username "CI Bot"` |
| `--avatar-url` | Avatar/icon URL | `--avatar-url "https://..."` |
| `--tts` | Text-to-speech (Discord only) | `--tts` |

## 🎨 Rich Content Formats

### Discord: Embeds
- **Object**: Single embed `{"title":"...", "color":65280}`
- **Array**: Multiple embeds `[{"title":"..."}, {...}]`
- **Fields**: `"fields":[{"name":"...","value":"...","inline":true}]`

### Slack: Blocks or Attachments
- **Blocks (Array)**: `[{"type":"section","text":{...}}]`
- **Attachments (Object)**: `{"attachments":[{"color":"good","title":"..."}]}`
- **Custom Fields**: Any valid Slack webhook payload keys
- **⚠️ Note**: Use `--embed-json` for Slack (inline JSON). File-based `--embed-file` is Discord-only.

### Service Behavior
- **Discord**: Validates message ≤2000 chars; supports TTS
- **Slack**: No char limit; TTS ignored; username→username, avatar-url→icon_url
- **Both**: Sends to each service; exits 0 if any succeeds, 1 if all fail

## ⚡ Automation Examples

### CI/CD Pipeline
```bash
# Build started (both services)
notify_me.sh --service both -m "🔨 Build #${BUILD_NUMBER} started" --username "CI"

# Build success (Discord)
notify_me.sh --service discord --embed-json "{
  \"title\":\"✅ Build #${BUILD_NUMBER} Success\",
  \"description\":\"All tests passed\",
  \"color\":65280,
  \"fields\":[
    {\"name\":\"Branch\",\"value\":\"${GIT_BRANCH}\",\"inline\":true},
    {\"name\":\"Commit\",\"value\":\"${GIT_COMMIT:0:8}\",\"inline\":true}
  ]
}" --username "CI Bot"

# Build success (Slack)
notify_me.sh --service slack --embed-json "[
  {
    \"type\":\"section\",
    \"text\":{
      \"type\":\"mrkdwn\",
      \"text\":\"✅ *Build #${BUILD_NUMBER} Success*\\nAll tests passed\"
    }
  }
]" --username "CI Bot"
```

### System Monitoring
```bash
# Disk space warning
notify_me.sh --embed-json "{
  \"title\":\"⚠️ Disk Space Warning\",
  \"description\":\"Server storage is running low\",
  \"color\":16753920,
  \"fields\":[
    {\"name\":\"Server\",\"value\":\"${HOSTNAME}\",\"inline\":true},
    {\"name\":\"Usage\",\"value\":\"${DISK_USAGE}%\",\"inline\":true}
  ]
}" --username "System Monitor"
```

### Backup Reports
```bash
notify_me.sh --embed-json "{
  \"title\":\"💾 Backup Complete\",
  \"description\":\"Database backup finished successfully\",
  \"color\":3447003,
  \"fields\":[
    {\"name\":\"Size\",\"value\":\"${BACKUP_SIZE}\",\"inline\":true},
    {\"name\":\"Duration\",\"value\":\"${BACKUP_TIME}\",\"inline\":true}
  ],
  \"footer\":{\"text\":\"Backup Bot\"}
}"
```

## 🛡️ Security Notes

- **Never expose webhook URLs** in logs, commands, or error messages
- Webhook URL is stored in `.env` file only
- URLs are passed securely to curl via stdin
- No sensitive data appears in process lists

## ❌ Error Handling

The script provides clear error messages:
- Missing webhook configuration
- Invalid message length (>2000 chars)
- Invalid JSON syntax
- File not found errors
- Network/API errors

## 🔄 Rate Limiting

- Automatic retry on Discord rate limits (HTTP 429)
- Respects `Retry-After` header
- Default: 2 retry attempts with exponential backoff

---

**💡 Pro Tips:** 
- **Discord**: For complex embeds, create JSON template files and use `--embed-file`
- **Slack**: Use `--embed-json` with inline JSON for blocks and attachments (file-based JSON not recommended)
