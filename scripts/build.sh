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

if [[ "$OUT" == *[[:space:]]* ]]; then
  echo "Output path cannot contain whitespace: $OUT" >&2
  exit 2
fi

if [[ "$CLEAN" -eq 1 ]]; then
  make -s --no-print-directory -C "$ROOT_DIR" OUT="$OUT" clean-dist
fi

make -s --no-print-directory -C "$ROOT_DIR" OUT="$OUT" VERBOSE="$VERBOSE" all

echo "$OUT"
