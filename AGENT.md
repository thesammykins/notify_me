# AGENT.md - notify_me.sh Reference

> Quick reference for LLMs and automated agents using notify_me.sh

## ⚠️ IMPORTANT: DO NOT MODIFY CODE

**🛑 NEVER modify, edit, or suggest changes to the notify_me.sh script code unless the user explicitly requests code modifications.**

This tool is production-ready and stable. Your role is to:
- ✅ **Use the existing script** as-is for Discord notifications
- ✅ **Reference this guide** for proper usage patterns
- ✅ **Help troubleshoot** configuration and usage issues
- ❌ **DO NOT** suggest code improvements or modifications
- ❌ **DO NOT** propose "better" implementations
- ❌ **DO NOT** edit the script files unless explicitly asked

If the user needs different functionality, suggest using the existing options or ask them to explicitly request script modifications.

## 🚀 Quick Usage

```bash
# Simple notification
notify_me.sh -m "Your message here"

# Rich notification with embed
notify_me.sh --embed-json '{"title":"Status","description":"Details","color":65280}'

# From file with custom bot name
notify_me.sh --embed-file status.json --username "Bot Name"
```

## 📋 Command Patterns

### Basic Text Messages
```bash
notify_me.sh -m "Build completed successfully"
notify_me.sh -m "Error: Database connection failed" --username "System Monitor"
notify_me.sh -m "URGENT: Server down!" --tts
```

### Status Updates (Success/Warning/Error)
```bash
# Success (Green)
notify_me.sh --embed-json '{"title":"✅ Success","description":"Operation completed","color":65280}'

# Warning (Orange) 
notify_me.sh --embed-json '{"title":"⚠️ Warning","description":"Check required","color":16753920}'

# Error (Red)
notify_me.sh --embed-json '{"title":"❌ Error","description":"Operation failed","color":16711680}'
```

### Build/Deploy Notifications
```bash
notify_me.sh --embed-json '{
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

## 🔧 Options Reference

| Option | Usage | Example |
|--------|-------|---------|
| `-m, --message` | Plain text (required if no embed) | `-m "Hello world"` |
| `--embed-json` | Inline JSON embed | `--embed-json '{...}'` |
| `--embed-file` | JSON file path | `--embed-file status.json` |
| `--username` | Bot display name | `--username "CI Bot"` |
| `--avatar-url` | Bot avatar image | `--avatar-url "https://..."` |
| `--tts` | Text-to-speech | `--tts` |

## ⚡ Automation Examples

### CI/CD Pipeline
```bash
# Build started
notify_me.sh -m "🔨 Build #${BUILD_NUMBER} started" --username "CI"

# Build success
notify_me.sh --embed-json "{
  \"title\":\"✅ Build #${BUILD_NUMBER} Success\",
  \"description\":\"All tests passed\",
  \"color\":65280,
  \"fields\":[
    {\"name\":\"Branch\",\"value\":\"${GIT_BRANCH}\",\"inline\":true},
    {\"name\":\"Commit\",\"value\":\"${GIT_COMMIT:0:8}\",\"inline\":true}
  ]
}" --username "CI Bot"
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

**💡 Pro Tip:** For complex notifications, create reusable JSON template files and use `--embed-file` instead of inline JSON.
