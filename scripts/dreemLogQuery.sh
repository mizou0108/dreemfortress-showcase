#!/bin/bash

LOG_FILE="logs/dreemLogger.log"
ACTION_FILTER="$1"
START_DATE="$2"
END_DATE="$3"

# إعدادات Telegram
export TELEGRAM_BOT_TOKEN="8268505716:AAGAuj3SJWf4hfPEmhMfIIazMhMh4mPBPks"
export TELEGRAM_CHAT_ID="1838691511"

# تحقق من وجود ملف السجل
if [[ ! -f "$LOG_FILE" ]]; then
    echo "❌ Log file not found: $LOG_FILE"
    exit 1
fi

# استخراج السجلات حسب النوع
FILTERED=$(grep "$ACTION_FILTER" "$LOG_FILE")

# فلترة حسب الفترة الزمنية
if [[ -n "$START_DATE" && -n "$END_DATE" ]]; then
    FILTERED=$(echo "$FILTERED" | awk -v start="$START_DATE" -v end="$END_DATE" '
    {
        split($1, d, "-");
        date = d[1] d[2] d[3];
        if (date >= start && date <= end) print $0;
    }')
fi

# حساب عدد العمليات
COUNT=$(echo "$FILTERED" | wc -l)

# عرض النتائج بصيغة Markdown
echo -e "### 📊 Dreem LogQuery Report\n"
echo "**🔎 Filter:** Action='$ACTION_FILTER', Date Range='$START_DATE → $END_DATE'"
echo "**📦 Matches:** $COUNT"
echo -e "\n---\n"
echo "$FILTERED"

# حفظ التقرير في ملف مؤرشف
mkdir -p archive/query
REPORT_FILE="archive/query/query_$(date +%Y%m%d_%H%M%S).log"
echo "$FILTERED" > "$REPORT_FILE"

# إرسال تقرير مختصر إلى Telegram
MESSAGE="📊 Dreem LogQuery\n🔎 Action: $ACTION_FILTER\n📅 Range: $START_DATE → $END_DATE\n📦 Matches: $COUNT\n🗂️ Saved: $REPORT_FILE"
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
     -d chat_id="$TELEGRAM_CHAT_ID" \
     -d text="$MESSAGE"
