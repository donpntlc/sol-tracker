#!/usr/bin/env bash
set -euo pipefail
#
# Install auf ein physisches iPhone über xcodebuild — umgeht Flutter/devicectl-Signaturprobleme.
#
# Usage:
#   ./scripts/ios_install_xcode.sh
#   ./scripts/ios_install_xcode.sh --release
#   IOS_DEVICE_ID=<UDID> ./scripts/ios_install_xcode.sh   # falls mehrere iPhones
#

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="Debug"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      CONFIG="Release"
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

cd "$ROOT"
echo "==> flutter pub get"
flutter pub get

echo ""
echo "==> Physische iOS-Geräte (laut flutter devices):"
flutter devices 2>/dev/null | grep -E "• ios" || true
echo ""

UDID="${IOS_DEVICE_ID:-}"
NAME=""
if [[ -z "$UDID" ]]; then
  _py="$(flutter devices --machine | python3 -c "
import sys, json
xs = [x for x in json.load(sys.stdin)
      if x.get('targetPlatform') == 'ios' and not x.get('emulator', False)]
if not xs:
    sys.stderr.write('Kein iPhone erkannt (USB: Kabel, entsperrt, „Vertrauen“).\n')
    sys.exit(1)
x = xs[0]
print(x['id'])
print(x.get('name', ''))
")"
  UDID="$(printf '%s\n' "$_py" | sed -n '1p')"
  NAME="$(printf '%s\n' "$_py" | sed -n '2p')"
fi

if [[ -z "$UDID" ]]; then
  exit 1
fi

echo "==> Install-Ziel: ${NAME:-?} ($UDID)"
echo ""

if [[ "$CONFIG" == "Release" ]]; then
  echo "==> flutter build ios --release"
  flutter build ios --release
fi

cd "$ROOT/ios"
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration "$CONFIG" \
  -destination "id=$UDID" \
  -allowProvisioningUpdates \
  install

echo ""
echo "Done. Auf diesem Gerät sollte „SOL - Tracker“ erscheinen: ${NAME:-$UDID}"
