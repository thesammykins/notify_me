#!/usr/bin/env bash
# notify_me.sh — Send Discord notifications using a webhook from .env
# - Loads DISCORD_WEBHOOK_URL from .env in the same directory as this script by default.
# - Override .env location with NOTIFY_ME_ENV_FILE or NOTIFY_ME_ENV_DIR.
# - Avoids exposing the webhook URL in process lists by passing it to curl via stdin.
# - Supports plain text content, optional embeds (JSON string or file), username/avatar overrides, and TTS.

set -euo pipefail

SCRIPT_SELF="${BASH_SOURCE[0]:-$0}"

resolve_script_dir() {
  local src="$SCRIPT_SELF"
  while [ -h "$src" ]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
    src="$(readlink "$src")"
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  cd -P "$(dirname "$src")" >/dev/null 2>&1
  pwd
}
SCRIPT_DIR="$(resolve_script_dir)"

load_env() {
  local env_file
  if [ "${NOTIFY_ME_ENV_FILE:-}" != "" ]; then
    env_file="$NOTIFY_ME_ENV_FILE"
  else
    local dir="${NOTIFY_ME_ENV_DIR:-$SCRIPT_DIR}"
    env_file="$dir/.env"
  fi
  if [ -f "$env_file" ]; then
    # CAUTION: sourcing executes the file. Keep only KEY=VALUE lines.
    # shellcheck disable=SC1090
    set -a
    . "$env_file"
    set +a
  fi
}

die() {
  echo "Error: $*" >&2
  exit 1
}

usage() { cat <<'EOF'
Usage: notify_me.sh --message "text" [options]
Send a message to Discord via webhook using DISCORD_WEBHOOK_URL from .env

Required:
  --message, -m "text"           Plain text message (1-2000 chars), required if no --embed-json/--embed-file

Options:
  --embed-json 'JSON'            Embed JSON string (object or array). If object, it will be wrapped in [ ... ]
  --embed-file /path/embed.json  Read embed JSON from file
  --username "name"              Override display username
  --avatar-url "url"             Override avatar URL
  --tts                          Enable text-to-speech
  --help, -h                     Show this help

Environment and config:
  - Script loads .env next to notify_me.sh by default.
  - Override location with:
      NOTIFY_ME_ENV_FILE=/abs/path/to/.env
      or
      NOTIFY_ME_ENV_DIR=/abs/path/to/dir
  - .env must define: DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."

Security:
  The webhook URL is passed to curl via stdin (not args) to avoid exposure in process lists.
EOF
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  s="${s//$'\b'/\\b}"
  s="${s//$'\f'/\\f}"
  printf '%s' "$s"
}

build_payload() {
  local message="$1"
  local embed_json="${2:-}"
  local username="${3:-}"
  local avatar_url="${4:-}"
  local tts="${5:-false}"

  local payload="{"
  local first=1
  add() { if [ $first -eq 1 ]; then first=0; else payload+=", "; fi; payload+="$1"; }

  if [ -n "$username" ]; then
    add "\"username\":\"$(json_escape "$username")\""
  fi
  if [ -n "$avatar_url" ]; then
    add "\"avatar_url\":\"$(json_escape "$avatar_url")\""
  fi
  if [ "$tts" = "true" ]; then
    add "\"tts\":true"
  fi
  if [ -n "$message" ]; then
    add "\"content\":\"$(json_escape "$message")\""
  fi
  if [ -n "$embed_json" ]; then
    local trimmed
    trimmed="$(printf '%s' "$embed_json" | awk 'NR==1{sub(/^[ \t\r\n]+/,"")}1')"
    if printf '%s' "$trimmed" | grep -q '^\['; then
      add "\"embeds\":$trimmed"
    else
      add "\"embeds\":[${trimmed}]"
    fi
  fi

  payload+="}"
  printf '%s' "$payload"
}

send_discord() {
  local webhook="$1"
  local payload="$2"
  local max_retries="${3:-2}"

  umask 077
  local headers body http_code attempt=0
  headers="$(mktemp -t notify_me_headers.XXXXXX)"
  body="$(mktemp -t notify_me_body.XXXXXX)"
  trap 'rm -f "$headers" "$body"' EXIT

  while :; do
    attempt=$((attempt+1))
    http_code="$(
      printf 'url="%s"\n' "$webhook" |
      curl -sS --config - \
        -H 'Content-Type: application/json' \
        --data-binary @<(printf '%s' "$payload") \
        -o "$body" -D "$headers" -w '%{http_code}' || echo "000"
    )"

    if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
      rm -f "$headers" "$body"; trap - EXIT
      return 0
    fi

    if [ "$http_code" = "429" ] && [ "$attempt" -le "$max_retries" ]; then
      local retry
      retry="$(awk 'tolower($0) ~ /^retry-after:/ {print $2; exit}' "$headers" | tr -d '\r')"
      [ -z "$retry" ] && retry="1"
      echo "Rate limited by Discord. Retrying after ${retry}s (attempt ${attempt}/${max_retries})..." >&2
      sleep "$retry"
      continue
    fi

    echo "Discord API error (HTTP $http_code):" >&2
    cat "$body" >&2
    rm -f "$headers" "$body"; trap - EXIT
    return 1
  done
}

main() {
  load_env

  local message="" embed_json="" embed_file="" username="" avatar_url="" tts="false"

  if [ $# -eq 0 ]; then
    usage
    exit 1
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      -m|--message)
        shift; message="${1:-}"; [ -z "${message:-}" ] && die "--message requires a value"
        ;;
      --embed-json)
        shift; embed_json="${1:-}"; [ -z "${embed_json:-}" ] && die "--embed-json requires a value"
        ;;
      --embed-file)
        shift; embed_file="${1:-}"; [ -z "${embed_file:-}" ] && die "--embed-file requires a path"
        [ ! -f "$embed_file" ] && die "Embed file not found: $embed_file"
        embed_json="$(cat "$embed_file")"
        ;;
      --username)
        shift; username="${1:-}"; [ -z "${username:-}" ] && die "--username requires a value"
        ;;
      --avatar-url)
        shift; avatar_url="${1:-}"; [ -z "${avatar_url:-}" ] && die "--avatar-url requires a value"
        ;;
      --tts)
        tts="true"
        ;;
      -h|--help)
        usage; exit 0
        ;;
      --)
        shift; break ;;
      -*)
        die "Unknown option: $1. Use --help for usage."
        ;;
      *)
        if [ -z "$message" ]; then
          message="$1"
        else
          die "Unexpected positional argument: $1"
        fi
        ;;
    esac
    shift || true
  done

  local webhook="${DISCORD_WEBHOOK_URL:-}"
  [ -z "$webhook" ] && die "DISCORD_WEBHOOK_URL is not set. Create a .env file next to notify_me.sh with: DISCORD_WEBHOOK_URL=\"https://discord.com/api/webhooks/...\""

  if [ -z "$message" ] && [ -z "$embed_json" ]; then
    die "You must provide --message or --embed-json/--embed-file."
  fi
  if [ -n "$message" ] && [ "${#message}" -gt 2000 ]; then
    die "Message exceeds Discord 2000 character limit (${#message})."
  fi

  local payload
  payload="$(build_payload "$message" "$embed_json" "$username" "$avatar_url" "$tts")"
  send_discord "$webhook" "$payload"
}

main "$@"
