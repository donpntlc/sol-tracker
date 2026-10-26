# Auftrag für Cursor: SOL Tracker wiederherstellen + 3 Wünsche

## Ausgangslage
- Repo stand auf Branch `master` (2598bbe, 07.06.). Dort FEHLEN Einkaufsliste und „Füllen“.
- Der neueste Stand mit Einkaufsliste + Füllen + Gesamtmahlzeit lag im Stash (21.06., auf `main`).
- Dieser Stand ist jetzt gesichert als Branch **`restore-sol`** (e964deb). Nichts wurde gelöscht; `master`, `main` und der Stash sind unverändert.
- Uncommitted Änderungen auf master (ios/*, pubspec, Icons, kWebUiScale-Zoom in lib/main.dart) zuerst committen: `git add -A && git commit -m "WIP master vor Restore"`.

## Schritte
1. `git checkout restore-sol` und `git merge master`.
   - Konflikte in lib/main.dart: Basis ist restore-sol (Einkaufsliste/ShoppingList, „… füllen“ in Makro-Tabelle, „Restwerte mit Generator füllen“, Gesamtmahlzeit).
   - Von master übernehmen: persönliche Bewertung 1–3 (Performance/Verträglichkeit, `_loadPersonalRatingMap`), Fotos, Gewichts-Formular-Fixes, Intro-Assets, Mahlzeit-Einstellungen, Web-Zoom `kWebUiScale = 0.88`.
   - Danach `flutter analyze` ohne Fehler, App starten und prüfen: Einkaufsliste erreichbar, Füllen funktioniert.
2. **Füllen**: Makro oder kcal antippen → „Füllen“ → Lebensmittel wählen → füllt bis zur Mitte des Zielbereichs und zeigt die Gramm des gewählten Lebensmittels.
3. **Trennlinien**: in allen Listen (Lebensmittel, Rezepte, Mahlzeit-Einträge) dünne Linie zwischen den Einträgen (`Divider(height: 1, thickness: 0.5)`, dezente Farbe).
4. **Training-kcal / Defizit**:
   - Standard: Trainings-kcal werden NICHT zum Essensbudget addiert.
   - Anzeige: Tagesdefizit gesamt (Bedarf + Training − gegessen) und Wochendefizit, umgerechnet in Fett (7000 kcal ≈ 1 kg, z. B. „−3500 kcal ≈ 0,5 kg Fett“).
   - Einstellung (Schalter, Standard AUS): „Trainings-kcal zum Budget addieren“.
   - Trainings-kcal vorerst manuell eintragbar (REPIT ist noch eine getrennte Web-App; automatische Übernahme erst nach Zusammenführung zu SOL).
5. Web bauen: `./web_bauen.sh`, dann die 3 Upload-Pakete ins sol-tracker-Repo hochladen.
6. Wenn alles läuft: `restore-sol` nach `main` mergen und pushen.
