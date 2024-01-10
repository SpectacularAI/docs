#!/bin/bash
# Usage
#
#  1. Activate a Python virtualenv where the correct spectacularAI
#     Python package version has been installed
#
#  2. Run this script in the root folder of this repo (docs)
#
#   ./import-python-docs.sh MAJOR.MINOR
#
# where MAJOR.MINOR is the latest SDK version for which to generate
# the docs, e.g. 1.26. Do not include the patch version or "v"
#

set -eux

SDK_VERSION="v$1"

: "${SDK_PRIVATE_PATH:="../vio"}"
CUR=`pwd`
WORK=$(mktemp -d)

cd "$SDK_PRIVATE_PATH"
./scripts/docs/build_html.sh "$WORK"
cd "$CUR"

languages=("python" "cpp")
for l in $languages; do
  rm -rf "$CUR/sdk/$l/latest"
  mv "$WORK/$l/latest" "$CUR/sdk/$l/"
  rm -rf "$CUR/sdk/$l/$SDK_VERSION"
  cp -R "$CUR/sdk/$l/latest" "$CUR/sdk/$l/$SDK_VERSION"
  rm -rf "$WORK/$l"
done
rm -rf "$WORK/_sources" "$WORK/objects.inv" "$WORK/genindex.html" "$WORK/py-modindex.html"
cp -R "$WORK/"* "$CUR/sdk/"

rm -rf "$WORK"
