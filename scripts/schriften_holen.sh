#!/usr/bin/env bash
# Holt die REPIT-Schriften (Barlow Condensed + Manrope) nach assets/fonts, falls sie fehlen.
set -euo pipefail
cd "$(dirname "$0")/.."
D=assets/fonts
mkdir -p "$D"
G=https://raw.githubusercontent.com/google/fonts/main/ofl
for w in Medium SemiBold Bold ExtraBold; do
  f="$D/BarlowCondensed-$w.ttf"
  [ -s "$f" ] || curl -fsSL "$G/barlowcondensed/BarlowCondensed-$w.ttf" -o "$f"
done
if [ ! -s "$D/Manrope-Bold.ttf" ]; then
  curl -fsSL "$G/manrope/Manrope%5Bwght%5D.ttf" -o /tmp/Manrope-var.ttf
  python3 -m pip install -q fonttools >/dev/null 2>&1 || pip3 install -q --user fonttools
  for pair in Regular:400 Medium:500 SemiBold:600 Bold:700 ExtraBold:800; do
    n=${pair%%:*}; w=${pair##*:}
    python3 -m fontTools.varLib.instancer /tmp/Manrope-var.ttf wght=$w -q -o "$D/Manrope-$n.ttf"
  done
fi
ls -1 "$D"
