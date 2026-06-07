#!/bin/zsh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/hotload.sh [options]

Options:
  --pid PID          Inject into a specific process id.
  --dylib PATH       Inject an existing dylib. Default: dist/minebridge.dylib
  --build            Build the dylib before injection.
  --verbose          Only useful with --build; enables high-frequency trace logging.
  --unique-copy      Copy to a timestamped dylib path. For development only.
  --cleanup          Remove old timestamped bridge/probe dylibs before injecting.
  --cleanup-only     Remove old timestamped bridge/probe dylibs and exit.
  --container PATH  PlayCover container path.
  --pattern TEXT    Process search pattern used by pgrep.
  --dry-run         Print actions without calling lldb.
  -h, --help        Show this help.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
CONTAINER="$HOME/Library/Containers/io.playcover.PlayCover"
LOG_FILE="$CONTAINER/minebridge.log"
LOG_ARCHIVE_DIR="$ROOT_DIR/logs"
PROCESS_PATTERN="/com.mojang.minecraftpe.app/minecraftpe"
DYLIB="$ROOT_DIR/dist/minebridge.dylib"
PID=""
BUILD=0
VERBOSE=0
UNIQUE_COPY=0
CLEANUP=0
CLEANUP_ONLY=0
DRY_RUN=0

print_banner() {
  printf '\033[38;2;54;163;255m'
  cat <<'EOF'
███╗   ███╗██████╗
████╗ ████║██╔══██╗
██╔████╔██║██████╔╝
██║╚██╔╝██║██╔══██╗
██║ ╚═╝ ██║██████╔╝
╚═╝     ╚═╝╚═════╝
EOF
  printf '\033[0m'
  sleep 0.5
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)
      [[ $# -ge 2 ]] || { echo "--pid needs a value" >&2; exit 2; }
      PID="$2"
      shift 2
      ;;
    --dylib)
      [[ $# -ge 2 ]] || { echo "--dylib needs a path" >&2; exit 2; }
      DYLIB="$2"
      shift 2
      ;;
    --build)
      BUILD=1
      shift
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --unique-copy)
      UNIQUE_COPY=1
      shift
      ;;
    --cleanup)
      CLEANUP=1
      shift
      ;;
    --cleanup-only)
      CLEANUP=1
      CLEANUP_ONLY=1
      shift
      ;;
    --container)
      [[ $# -ge 2 ]] || { echo "--container needs a path" >&2; exit 2; }
      CONTAINER="$2"
      LOG_FILE="$CONTAINER/minebridge.log"
      shift 2
      ;;
    --pattern)
      [[ $# -ge 2 ]] || { echo "--pattern needs a value" >&2; exit 2; }
      PROCESS_PATTERN="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
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

print_banner

cleanup_old_copies() {
  emulate -L zsh
  setopt NULL_GLOB

  local keep_bridge="$CONTAINER/minebridge_${VERSION}.dylib"
  local candidates=(
    "$CONTAINER"/minebridge_*.dylib
    "$CONTAINER"/mc_keyboard_bridge_*.dylib
    "$CONTAINER"/mc_lldb_input_probe_*.dylib
  )
  local files=()
  local file
  for file in "${candidates[@]}"; do
    [[ "$file" == "$keep_bridge" ]] && continue
    files+=("$file")
  done

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No old bridge/probe dylib copies found."
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'Would remove: %s\n' "${files[@]}"
    return
  fi

  rm -f -- "${files[@]}"
  echo "Removed ${#files[@]} old bridge/probe dylib copies."
}

if [[ "$CLEANUP_ONLY" -eq 1 ]]; then
  cleanup_old_copies
  exit 0
fi

if [[ "$BUILD" -eq 1 ]]; then
  BUILD_ARGS=()
  if [[ "$VERBOSE" -eq 1 ]]; then
    BUILD_ARGS+=(--verbose)
  fi
  DYLIB="$("$ROOT_DIR/scripts/build.sh" "${BUILD_ARGS[@]}")"
fi

if [[ ! -f "$DYLIB" ]]; then
  echo "Dylib not found: $DYLIB" >&2
  exit 1
fi

if [[ -z "$PID" ]]; then
  PID="$(pgrep -n -f "$PROCESS_PATTERN" || true)"
fi

if [[ -z "$PID" ]]; then
  echo "Minecraft is not running. Start Minecraft in PlayCover first." >&2
  exit 1
fi

if ! kill -0 "$PID" 2>/dev/null; then
  echo "Process is not accessible: $PID" >&2
  exit 1
fi

mkdir -p "$CONTAINER" "$LOG_ARCHIVE_DIR"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
if [[ "$UNIQUE_COPY" -eq 1 ]]; then
  REMOTE_DYLIB="$CONTAINER/minebridge_${VERSION}_${RUN_ID}.dylib"
else
  REMOTE_DYLIB="$CONTAINER/minebridge_${VERSION}.dylib"
fi

if [[ "$CLEANUP" -eq 1 ]]; then
  cleanup_old_copies
fi

cp "$DYLIB" "$REMOTE_DYLIB"

if [[ -f "$LOG_FILE" ]]; then
  BRIDGE_ARCHIVE="$LOG_ARCHIVE_DIR/${RUN_ID}-minebridge-before-load.raw.log"
  cp "$LOG_FILE" "$BRIDGE_ARCHIVE"
  : > "$LOG_FILE"
  echo "Archived previous log: $BRIDGE_ARCHIVE"
fi

echo "Version: $VERSION"
echo "PID: $PID"
echo "Dylib: $REMOTE_DYLIB"
echo "Log: $LOG_FILE"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run: skipped lldb injection."
  exit 0
fi

lldb -p "$PID" \
  -o "expr -l objc++ -- (void *)dlopen(\"$REMOTE_DYLIB\", 2)" \
  -o detach \
  -o quit

echo "Injected into PID $PID"
if [[ -f "$LOG_FILE" ]]; then
  echo "Recent bridge log:"
  tail -n 20 "$LOG_FILE" || true
fi
