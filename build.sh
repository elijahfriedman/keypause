#!/bin/sh
# Builds keypause and copies the binary to ./dist/keypause.
set -e

cd "$(dirname "$0")"

xcodebuild \
  -project keypause.xcodeproj \
  -scheme keypause \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  build

BUILT_PRODUCTS_DIR=$(xcodebuild -project keypause.xcodeproj -scheme keypause \
  -configuration Release -showBuildSettings 2>/dev/null \
  | awk '/ BUILT_PRODUCTS_DIR/{print $3}')

mkdir -p dist
cp "$BUILT_PRODUCTS_DIR/keypause" dist/keypause

echo "Built: dist/keypause"
