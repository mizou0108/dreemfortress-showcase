#!/bin/bash

# تحميل التوكن والمعرف
export TELEGRAM_BOT_TOKEN="8268505716:AAGAuj3SJWf4hfPEmhMfIIazMhMh4mPBPks"
export TELEGRAM_CHAT_ID="1838691511"

ACTION="$1"
LOG_FILE="logs/dreemLogger.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SIGNATURE_FILE="signatures/dreemLogger.sig"

# ✅ تحقق من نوع العملية
if [[ "$ACTION" != "access" && "$ACTION" != "update" && "$ACTION" != "delete" ]]; then
    ERROR_MSG="❌ DreemLogger Error\n🕒 $TIMESTAMP\n⚠️ Invalid action: '$ACTION'"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$ERROR_MSG"
    echo "❌ Invalid action: '$ACTION'. Notification sent."
    exit 1
fi

# ✅ تسجيل العملية
mkdir -p logs
echo "$TIMESTAMP - ACTION: $ACTION" >> "$LOG_FILE"

# ✅ توليد توقيع قانوني
mkdir -p signatures
echo "$TIMESTAMP - SIGNED: $ACTION" > "$SIGNATURE_FILE"

# ✅ إرسال تنبيه Telegram
MESSAGE="🔐 DreemLogger Alert\n🕒 $TIMESTAMP\n📦 Action: $ACTION\n📁 Signed: $SIGNATURE_FILE"
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
     -d chat_id="$TELEGRAM_CHAT_ID" \
     -d text="$MESSAGE"

# ✅ أرشفة العملية
mkdir -p archive/dreemLogger
cp "$LOG_FILE" "archive/dreemLogger/$TIMESTAMP.log"

echo "✅ Operation '$ACTION' logged, signed, and notified."
