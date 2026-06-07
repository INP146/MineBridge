#!/bin/zsh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/build.sh [options]

Options:
  --output PATH   Write dylib to PATH. Default: dist/minebridge.dylib
  --verbose       Enable high-frequency trace logging in the dylib.
  --clean         Remove the output dylib before building.
  -h, --help      Show this help.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCES=(
  "$ROOT_DIR/bridge/BridgeMain.m"
  "$ROOT_DIR/bridge/Core/BridgeState.m"
  "$ROOT_DIR/bridge/Core/BridgeSettings.m"
  "$ROOT_DIR/bridge/Core/BridgeHooks.m"
  "$ROOT_DIR/bridge/Input/BridgeConnection.m"
  "$ROOT_DIR/bridge/Input/BridgeKeyboard.m"
  "$ROOT_DIR/bridge/Input/BridgeMouse.m"
  "$ROOT_DIR/bridge/Pointer/BridgePointer.m"
  "$ROOT_DIR/bridge/UI/BridgeHUD.m"
  "$ROOT_DIR/bridge/UI/BridgeMenu.m"
  "$ROOT_DIR/bridge/Controller/BridgeControllerHooks.m"
)
OUT="$ROOT_DIR/dist/minebridge.dylib"
VERBOSE=0
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      [[ $# -ge 2 ]] || { echo "--output needs a path" >&2; exit 2; }
      OUT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --clean)
      CLEAN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for source in "${SOURCES[@]}"; do
  if [[ ! -f "$source" ]]; then
    echo "Source not found: $source" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$OUT")"
if [[ "$CLEAN" -eq 1 ]]; then
  rm -f "$OUT"
fi

SDK="$(xcrun --sdk macosx --show-sdk-path)"
FLAGS=(
  -target arm64-apple-ios14.0-macabi
  -isysroot "$SDK"
  -fobjc-arc
  -fblocks
  -fvisibility=hidden
  -dynamiclib "${SOURCES[@]}"
  -o "$OUT"
  -framework Foundation
)

if [[ "$VERBOSE" -eq 1 ]]; then
  FLAGS+=(-DMC_KEYBOARD_BRIDGE_VERBOSE=1)
fi

xcrun --sdk macosx clang "${FLAGS[@]}"
codesign --force --sign - "$OUT" >/dev/null

echo "$OUT"
