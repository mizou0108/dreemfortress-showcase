#!/data/data/com.termux/files/usr/bin/bash

# المسارات الذكية
SCRIPT_DIR="$(dirname "$0")"
CONFIG="$SCRIPT_DIR/config.json"
LOG_FILE="$SCRIPT_DIR/logs/signed_commits.json"
SIGNER="$SCRIPT_DIR/signer.sh"

# التحقق من الملفات
if [[ ! -f "$CONFIG" ]]; then
  echo "❌ ملف الإعدادات غير موجود: $CONFIG"
  exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
  echo "📁 إنشاء ملف السجلات: $LOG_FILE"
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "[]" > "$LOG_FILE"
fi

# قراءة الرسالة من المستخدم
read -p "📝 أدخل رسالة التحديث: " COMMIT_MSG

# تنفيذ Git commit
git add .
git commit -m "🔧 $COMMIT_MSG"

# توقيع العملية
bash "$SIGNER"

echo "✅ تم تنفيذ العملية وتوقيعها بنجاح."
