#!/usr/bin/env bash
# Holt Roboto Black (wie der REPIT-Schriftzug) nach assets/fonts, falls sie fehlt. Nur für das PREPIT-Logo.
set -euo pipefail
cd "$(dirname "$0")/.."
D=assets/fonts; mkdir -p "$D"
if [ ! -s "$D/Roboto-Black.ttf" ]; then
  curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto%5Bwdth,wght%5D.ttf" -o /tmp/Roboto-var.ttf
  python3 -m pip install -q fonttools >/dev/null 2>&1 || pip3 install -q --user fonttools
  python3 -m fontTools.varLib.instancer /tmp/Roboto-var.ttf wght=900 wdth=100 -q -o "$D/Roboto-Black.ttf"
fi
ls -l "$D"
