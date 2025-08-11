#!/bin/bash

unit_name="$1"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
unit_path="units/$unit_name/$unit_name.sh"

# تحقق من وجود الوحدة
if [ ! -f "$unit_path" ]; then
  echo "❌ الملف $unit_path غير موجود."
  exit 1
fi

# توليد SHA256 hash
hash=$(sha256sum "$unit_path" | awk '{print $1}')

# توقيع رقمي وهمي (للتجربة)
signature="SIGNATURE-$(echo $hash | cut -c1-16)"

# إنشاء ملف JSON
output_path="legal/signatures/${unit_name}.json"
cat <<EOF > "$output_path"
{
  "unit": "$unit_name",
  "timestamp": "$timestamp",
  "hash": "$hash",
  "signature": "$signature",
  "verified": true
}
EOF

echo "✅ تم توليد توقيع قانوني للوحدة '$unit_name' في $output_path"
