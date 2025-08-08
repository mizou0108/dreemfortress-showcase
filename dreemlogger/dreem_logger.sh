#!/bin/bash
# DreemLogger™ - Logging with legal verification

LOG_FILE="sample_log.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ACTION="$1"
STATUS="$2"

jq -n --arg time "$TIMESTAMP" --arg act "$ACTION" --arg stat "$STATUS" \
'{timestamp: $time, action: $act, status: $stat}' >> "$LOG_FILE"

echo "[✓] Logged: $ACTION - $STATUS at $TIMESTAMP"
