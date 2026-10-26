#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/ios_daily.sh
#   ./scripts/ios_daily.sh --device <flutter-device-id>
#   ./scripts/ios_daily.sh --no-analyze
#
# One-time manual prerequisites (cannot be fully automated):
# - Xcode signing/team configured for Runner target
# - iPhone trusted developer profile

DEVICE_ID=""
RUN_ANALYZE="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE_ID="${2:-}"
      shift 2
      ;;
    --no-analyze)
      RUN_ANALYZE="false"
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

echo "==> Flutter clean"
flutter clean

echo "==> Flutter pub get"
flutter pub get

if [[ "$RUN_ANALYZE" == "true" ]]; then
  echo "==> Flutter analyze"
  flutter analyze
fi

echo "==> Build iOS release"
flutter build ios --release

if [[ -n "$DEVICE_ID" ]]; then
  echo "==> Install + run on device: $DEVICE_ID"
  flutter run --release -d "$DEVICE_ID"
else
  echo "==> Build complete."
  echo "Tip: run with --device <id> to install directly."
  echo "Get IDs with: flutter devices"
fi
