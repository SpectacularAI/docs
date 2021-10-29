#!/bin/bash
set -eux
TARGET="$1"
WORK=$(mktemp -d)
CUR=`pwd`
cp "$TARGET" "$WORK"
cd "$WORK"
unzip *.zip

MINOR_VERSION=$(
  find wheels/ |
  grep spectacularAI- |
  head -n 1 |
  awk 'BEGIN { FS = "-" }; { print $2; }' |
  awk 'BEGIN { FS = "." }; { print $1 "." $2; }')

cat > most_recent_version.py << 'EOF'
import sys
def version_to_num(s):
    weight = 1.0
    num = 0.0
    for v in s.strip().replace('v', '').split('.'):
        num += int(v) * weight
        weight /= 1000.0
    return num

versions = sorted(sys.stdin.readlines(), key=version_to_num)
print(versions[-1].strip())
EOF

cd "$CUR"
TARGET_DIR="sdk/python/v$MINOR_VERSION"
rm -rf "$TARGET_DIR"
cp -r "$WORK/docs" "$TARGET_DIR"

MOST_RECENT=$(ls sdk/python | grep -v latest | python "$WORK/most_recent_version.py")
rm -rf "$WORK"
rm -rf "sdk/python/latest"
cp -r "sdk/python/$MOST_RECENT" "sdk/python/latest"
