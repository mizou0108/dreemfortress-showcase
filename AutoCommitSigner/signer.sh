#!/data/data/com.termux/files/usr/bin/bash

CONFIG="./config.json"
LOGS_DIR="./logs"
LOG_FILE="$LOGS_DIR/signed_commits.json"

# تحقق من وجود ملف الإعدادات
if [ ! -f "$CONFIG" ]; then
  echo "❌ لم يتم العثور على ملف الإعدادات: $CONFIG"
  exit 1
fi

# تحميل البيانات من config.json
TELEGRAM_TOKEN=$(jq -r '.telegram.token' "$CONFIG")
TELEGRAM_CHAT_ID=$(jq -r '.telegram.chat_id' "$CONFIG")
REPO_NAME=$(jq -r '.repo.name' "$CONFIG")

# التحقق من وجود commit
LAST_COMMIT=$(git log -1 --pretty=format:"%H|%s|%an|%ad")
if [ -z "$LAST_COMMIT" ]; then
  echo "⚠️ لا يوجد أي commit في المستودع."
  exit 1
fi

# استخراج بيانات commit
COMMIT_HASH=$(echo "$LAST_COMMIT" | cut -d'|' -f1)
COMMIT_MSG=$(echo "$LAST_COMMIT" | cut -d'|' -f2)
COMMIT_AUTHOR=$(echo "$LAST_COMMIT" | cut -d'|' -f3)
COMMIT_DATE=$(echo "$LAST_COMMIT" | cut -d'|' -f4)

# توليد توقيع SHA256
SIGNATURE=$(echo "$COMMIT_HASH-$COMMIT_MSG-$COMMIT_DATE" | sha256sum | cut -d' ' -f1)

# إنشاء مجلد السجلات إذا لم يكن موجودًا
mkdir -p "$LOGS_DIR"

# التحقق من التكرار
if grep -q "$SIGNATURE" "$LOG_FILE" 2>/dev/null; then
  echo "🔁 تم توقيع هذا الـ commit مسبقًا."
  exit 0
fi

# أرشفة العملية
echo "{\"repo\":\"$REPO_NAME\",\"hash\":\"$COMMIT_HASH\",\"signature\":\"$SIGNATURE\",\"date\":\"$COMMIT_DATE\",\"message\":\"$COMMIT_MSG\"}" >> "$LOG_FILE"

# إرسال التنبيه إلى Telegram
MESSAGE="📦 *مستودع:* $REPO_NAME
📝 *العملية:* $COMMIT_MSG
🔐 *التوقيع:* \`$SIGNATURE\`
🕒 *الزمن:* $COMMIT_DATE"

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown"

echo "✅ تم إرسال التنبيه وتوقيع العملية بنجاح."
