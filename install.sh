#!/bin/sh
# Installs dist/keypause to ~/.local/bin. Run build.sh first.
set -e

cd "$(dirname "$0")"

if [ ! -f dist/keypause ]; then
  echo "dist/keypause not found. Run build.sh first." >&2
  exit 1
fi

mkdir -p "$HOME/.local/bin"
cp dist/keypause "$HOME/.local/bin/keypause"

echo "Installed: $HOME/.local/bin/keypause"
