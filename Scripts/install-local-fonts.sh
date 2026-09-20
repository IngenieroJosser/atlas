#!/bin/zsh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/ATLAS/Resources/Fonts"
mkdir -p "$DEST"

find_font() {
  local name="$1"
  local candidate
  for candidate in "$HOME/Downloads/$name" "$HOME/Desktop/$name"; do
    if [[ -f "$candidate" ]]; then
      cp "$candidate" "$DEST/$name"
      echo "✓ $name"
      return 0
    fi
  done
  echo "✗ No encontré $name en Downloads ni Desktop"
  return 1
}

find_font "Manrope-VariableFont_wght.ttf" || true
find_font "Geist-VariableFont_wght.ttf" || true

echo "Fuentes instaladas en: $DEST"
