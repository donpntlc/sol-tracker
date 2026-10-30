#!/bin/bash
# SOL Tracker Web-App bauen und in Upload-Pakete (<100 Dateien, <25 MB) aufteilen.
cd "$(dirname "$0")"
bash scripts/logo_schrift_holen.sh || { echo "LOGO-SCHRIFT FEHLT"; exit 1; }
flutter build web --release --base-href /sol-tracker/ --no-tree-shake-icons || { echo "BUILD FEHLER"; exit 1; }
B=build/web; U=build/upload; rm -rf "$U"; mkdir -p "$U/1" "$U/2" "$U/3"
touch "$B/.nojekyll"
# 1: alles ausser canvaskit und assets/assets
rsync -a --exclude canvaskit --exclude assets/assets "$B/" "$U/1/"
# 2: canvaskit (nur das Nötige)
mkdir -p "$U/2/canvaskit"; cp "$B/canvaskit/canvaskit.js" "$B/canvaskit/canvaskit.wasm" "$U/2/canvaskit/" 2>/dev/null; [ -d "$B/canvaskit/chromium" ] && cp -r "$B/canvaskit/chromium" "$U/2/canvaskit/"
# 3: Bilder
mkdir -p "$U/3/assets"; [ -d "$B/assets/assets" ] && cp -r "$B/assets/assets" "$U/3/assets/"
open "$U"
echo FERTIG
