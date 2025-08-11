#!/bin/bash

# إعدادات Telegram
export TELEGRAM_BOT_TOKEN="8268505716:AAGAuj3SJWf4hfPEmhMfIIazMhMh4mPBPks"
export TELEGRAM_CHAT_ID="1838691511"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
STATUS_MSG="📊 Dreem Fortress™ Status\n🕒 $TIMESTAMP\n"

# ✅ تحقق من وجود الوحدات
for file in units/dreemLogger/dreemLogger.sh scripts/generate_signature.sh; do
    if [[ -f "$file" ]]; then
        STATUS_MSG+="✅ Found: $file\n"
    else
        STATUS_MSG+="❌ Missing: $file\n"
    fi
done

# 📄 عرض آخر عملية
if [[ -f logs/dreemLogger.log ]]; then
    LAST_ACTION=$(tail -n 1 logs/dreemLogger.log)
    STATUS_MSG+="📦 Last Action: $LAST_ACTION\n"
else
    STATUS_MSG+="⚠️ No log file found.\n"
fi

# 🔏 عرض آخر توقيع
if [[ -f signatures/dreemLogger.sig ]]; then
    LAST_SIG=$(tail -n 1 signatures/dreemLogger.sig)
    STATUS_MSG+="🔏 Last Signature: $LAST_SIG\n"
else
    STATUS_MSG+="⚠️ No signature file found.\n"
fi

# 📬 إرسال التقرير إلى Telegram
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
     -d chat_id="$TELEGRAM_CHAT_ID" \
     -d text="$STATUS_MSG"

echo "✅ Dreem Fortress™ status report sent."
