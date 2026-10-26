# REPIT. – Projektkontext für den KI-Assistenten (Cursor)

> **Für Dean, so benutzt du diese Datei:**
> 1. Öffne in Cursor das Repo **donpntlc/repit** (über „Clone Repository“).
> 2. Leg diese Datei als `AGENTS.md` in den Hauptordner des Repos. Cursor liest sie dann automatisch bei jedem Chat.
> 3. Starte den ersten Chat mit: *„Lies AGENTS.md und index.html, dann sag mir kurz, ob du alles verstanden hast.“*

---

## 0. Wie du mit Dean arbeitest
- Antworte immer auf **Deutsch**, kurz, locker und praktisch. Dean ist Personal Trainer (St. Gallen, Schweiz), kein Programmierer. Erkläre Schritte so, dass er sie ohne Fachwissen versteht.
- Er diktiert oft per Sprache. Tippfehler wie „Rapid“ = REPIT, „Soul“ = SOL.
- **Lösche nie seine Trainingsdaten.** Ändere nie die localStorage-Schlüssel `hantelbuch.*` (sonst sind alle Daten der Nutzer weg).
- Nach jeder Änderung: in der Daten-Ansicht die Versionsnummer hochzählen (`Version TT.MM. HH:MM` in `sData()`), damit Dean auf dem Handy sieht, ob die neue Version da ist.
- Teste jede Änderung in einer Handy-Ansicht (390 × 844), bevor du pushst.

## 0b. Arbeitsweise (so hat Claude bisher mit Dean gearbeitet, bitte genauso)
1. **Erst kurz sagen, was du machst, dann direkt machen.** Nicht lange planen oder nachfragen, wenn die Aufgabe klar ist. Nur bei echten Unklarheiten **eine** kurze Frage.
2. **Selbst testen, bevor du fertig meldest:** im Browser in der Handy-Ansicht 390 × 844 öffnen, Screenshot anschauen, die Funktion mit Testdaten durchspielen und auf JS-Fehler in der Konsole achten. Nie „sollte gehen“ sagen, ohne es geprüft zu haben.
3. **Danach selbst deployen** (commit + push) und prüfen, ob die neue Versionsnummer live ist (`https://donpntlc.github.io/repit/`).
4. **Antworten kurz und auf Deutsch:** was jetzt neu ist (Liste mit fett markierten Stichworten), wo man es in der App findet, und was Dean tun muss (meist: App ganz schliessen und neu öffnen).
5. **„Nur merken“-Modus:** Wenn Dean sagt „merk dir“, „bin im Training“ oder „nur merken“, baust du **nichts**. Trag den Wunsch unten in Abschnitt 5 (Backlog) dieser Datei ein und bestätige in 1 bis 2 Sätzen.
6. **Design-Regeln:** schwarz/gold, linksbündig, sauber. Keine Pop-up-Dialoge (`alert`/`confirm`), sondern die eigenen Sheets (`openSheet({type:'confirm',…})`). Nach jeder Änderung die Versionsnummer in `sData()` hochzählen.
7. **Mitdenken:** Ist etwas schon vorhanden (z. B. einseitiges Training mit Wechselpause), sag ihm, wo er es findet, statt es neu zu bauen. Fallen dir Fehler auf, behebst du sie gleich mit.
8. Kein Fachchinesisch. Erkläre Dinge so, wie man es einem Trainingskunden erklären würde.

## 1. Was REPIT ist
- Trainings-Tracker als **Web-App (PWA)** fürs iPhone, Ersatz für die App „Strong“. Früher hieß sie „Hantelbuch“, deshalb tragen interne Namen noch „hantelbuch“.
- Live: **https://donpntlc.github.io/repit/** (GitHub Pages, Repo `donpntlc/repit`, Branch `main`).
- Name/Logo: „REP“ weiß + „IT.“ gold. Slogan: **„Rep it. Track it. Repeat.“** Auf dem Homescreen heißt sie „REPIT.“ (mit Punkt).
- Design: schwarz mit Gold. Farben stehen als CSS-Variablen in `:root` (`--bg #0b0b0c`, `--gold #c9a24a`, `--gold-hi #e7c66d`, `--ok`, `--bad`, `--muted` …). Schriften: Barlow Condensed (Titel), Manrope (Text).
- Jeder Nutzer hat seine Daten **nur auf seinem Handy** (kein Server, keine Konten). Teilen geht über Dateien und Links.

## 2. Technik und Aufbau
- **Eine einzige Datei: `index.html`** (rund 170 KB, HTML + CSS + JS in einer Datei, kein Framework, kein Build). Dazu kommen `manifest.webmanifest`, Icons (`icon-180/192/512.png`) und der Ordner `img/`.
- Deploy: `index.html` ändern → commit → **push auf `main`** → GitHub Pages ist nach ca. 1 Minute live. Auf dem iPhone muss man die App eventuell ganz schließen und neu öffnen.
- Lokal testen: `python3 -m http.server` im Repo-Ordner, dann `http://localhost:8000` (für die Handy-Größe die DevTools nutzen).

### Code-Struktur (Abschnitte in `index.html`, Kommentar `/* ---------- … ---------- */`)
| Abschnitt | Inhalt |
|---|---|
| Übungsbibliothek | `LIB` (`[name, kategorie]`), `CATS`, `EXDESC` (Beschreibung: `[ausführung, hauptmuskeln, mit, „so lernst du es“]`), `IMG_ALIAS` (Strong-Namen → Bild) |
| State | globales Objekt `S` (tab, routines, workouts, body, active, sheet, custom, gear, goal …) |
| Speicherung | `LS='hantelbuch.v1'`, `lsSave()`, `saveMeta()`, `saveWorkout()`, `saveActive()`. **Zwei Modi:** `refs` gesetzt = Claude-Artifact-Cloud. Auf GitHub ist `refs` null, dann gilt localStorage. Fotos liegen in IndexedDB (`idbGet/idbSet`, Schlüssel `ph:local-…`). |
| Render | `renderAll / renderNav / renderMain / renderSheet`. Ansichten: `vRoutines, vHistory, vTraining, vActive, vExercises, vBody`. Tabs (`TABS`): Routinen, Verlauf, **Training (Mitte)**, Übungen, Körper |
| Sheets | untere Einblendungen, Map `{picker, menu, routine, hist, ex, confirm, summary, rest, data, setrest, rpe, order, rorder, tpl, client, intro, share, planin, pay, rday, gender, gear}` → Funktionen `sXxx()`. Öffnen mit `openSheet({type:'…'})`, schließen mit `closeSheet()`, Zurück-Stapel in `S.sheet.back` |
| Aktionen | **ein** Objekt `ACT` mit allen Klick-Handlern. Buttons rufen sie über `data-act="name" data-v="…" data-i="…"` auf. Eingabefelder laufen über `data-in="…"` (Input-Handler mit `k==='…'`-Zweigen) |
| Rest timer / Toast / Sound | Pausentimer, `toast()`, eigener Timer-Sound, iPhone-Kurzbefehl „REPIT Timer“ |
| Fotos | Formcheck-Fotos mit Datum |
| Strong-Import | `parseCSV`, `importStrong`, `routinesFromImport`. `STRONG_CUTOFF` gilt nur, wenn schon importierte Trainings da sind (Deans Oktober-Schnitt) |
| Pläne teilen (Coach) | `planPayload`, `sShare` (+ Gewichtsrechner `calcKg/calcFactor`), `takePlan`, `readPlan`, `shareOut`, Links `#plan=` (`checkPlanHash`) |
| Backup | `backupOut()` (JSON inkl. Fotos als Base64), `backupIn()` (führt zusammen statt zu überschreiben). **Ein** Knopf „Daten importieren“ (`#anyIn` → `importAny`) erkennt selbst: Backup, Coach-Plan (`app:'hantelbuch'`) oder CSV |
| Abo-Stufen | vorbereitet, **`PAYWALL=false`** (alles frei). `TIERS` free/pro/coach, `need()`, `needSlot()`, `sPay()`. Sperren hängen per `wrap()` vor den ACT-Handlern |

### Bilder
- `img/<slug>-m.jpg` (Mann) und `img/<slug>-w.jpg` (Frau), `slug()` aus dem Übungsnamen. `exImg(name)` nutzt `IMG_ALIAS` und `baseName()`.
- Wahl Mann/Frau: `hantelbuch.gender`.

### Wichtige localStorage-Schlüssel (nie umbenennen)
`hantelbuch.v1` (Hauptdaten), `.gender`, `.intro`, `.pomode` (Hinweise: full/short/off), `.rlabel` (num/day), `.exmode` (Übungsliste: cat/az/oft), `.clients`, `.warmex`, `.tier`, `.sound`, `.soundRaw`, `.iostimer`, `.lockbell`

### Datenmodell (kurz)
- Routine: `{id, name, note, exercises:[{name, target:'10-12', sets, rest, note, plan:[{kg,reps,rpe,rest,type}]}], folder?:'coach', client?, day?:'Mo'…}`
- Training: `{id, name, start, routineId, note, exercises:[{name, target, note, sets:[{kg, reps, rpe, done, type:'n'|'w', rest}]}]}`
- Varianten: `"Dips · Aufwärmen"`. `baseName()` / `variantOf()` trennen am „ · “, jede Variante hat ihren eigenen Verlauf.
- Anstrengung wird im Feld `rpe` gespeichert: `'8'` = Stufe 1, `'9'` = 2, `'9.5'` = 3, `'10'` = 4 (`effLvl()`, `effBadge()`).

## 3. Deans Trainingssystem (Produktlogik, bitte so beibehalten)
1. **REPIT-Idee:** keine festen Tage. Die Routinen laufen im Kreis 1 → 2 → 3 … und dann wieder von vorne. Fällt ein Tag aus, kommt einfach das nächste Training. Die App markiert es golden mit „Als Nächstes“ (`nextRid()`). Feste Wochentage sind **optional** (Umschalter „1 · 2 · 3 | Wochentage“, dann wird das Training von heute mit „Heute“ markiert).
2. **Progressive Overload pro Satz:** Jede Übung hat einen Zielbereich (z. B. 10–12). **Jeder Satz wird einzeln bewertet:** War ein Satz letztes Mal über dem oberen Ziel, wird **nur in diesem Satz** das Gewicht erhöht (`incKg`, wieder bei der unteren Zahl starten). Die anderen Sätze: +1 Wdh. War der Satz mit Stufe 2 bewertet: gleiche Wdh., aber sauber. Logik in `setGoals()`, `applyGoals()` (trägt die Ziele beim Start einer Routine ein) und `poHint()`. Aufwärmsätze (`type:'w'`) und Aufwärmübungen (`isWarmEx`) werden ignoriert.
3. **Hinweise in 3 Stufen** (Einstellung in Daten): Anfängerhilfe (ausführlich) · Trainingshinweis (eine Zeile) · Aus.
4. **Anstrengung in 4 Stufen statt RPE:** 1 Noch Luft · 2 Noch 1, aber unsauber · 3 Nur noch halb · 4 Muskelversagen. Die Farben (grün, gold, orange, rot) erscheinen als kleine Hochzahl in der Spalte „Vorher“. Grundsatz: **saubere Ausführung vor Gewicht.**
5. **Einführung beim ersten Start** (`INTRO`, 3 Seiten, später erneut über „So funktioniert REPIT“).
6. **Coach-Bereich:** Routinen → „Für Kunden (Coach)“, eine Rubrik pro Kunde (`client`). „Plan teilen“ verschickt als Datei oder Link, optional mit Gewichten und Notizen und mit Gewichtsrechner (Mann/Frau, Größe, Gewicht, Level).
7. **6er-Split-Vorlage** (`SPLIT6`, `applySplit`) mit Levels Anfänger/Fortgeschritten/Profi, skaliert nach Körpergewicht (Basis: Dean ≈ 80 kg).
8. Weitere Funktionen: Übungen nach Rubriken / A–Z / Häufigste, Kampfsport-Drills unter Athletik, Geräte-Einstellungen pro Übung, Notizen (die letzte sichtbar, ältere aufklappbar), Kraftwert (geschätztes 1RM mit Erklärung), Körper mit Gewicht, Start-/Zielgewicht samt Ziellinie und Formcheck-Fotos.

## 4. Geschäftsmodell (vorbereitet, noch nicht aktiv)
- Kostenlos: 2 eigene Trainingstage. **Pro: 20 / Jahr oder 3 / Monat.** **Coach: ca. 80 / Jahr** (Kunden-Rubriken, ganze Splits teilen, Rechner). Einzelne Tage teilen kann jeder.
- Für echtes Bezahlen fehlen noch Konten, ein Zahlungsanbieter (z. B. Stripe) und ein Server (Supabase ist bei Dean verbunden). Bis dahin bleibt `PAYWALL=false`.

## 5. Offene Aufgaben (REPIT)
- Bilder (macht Dean mit ChatGPT, dann ab nach `img/`):
  - Frauen-Bilder prüfen (lockeres T-Shirt ohne Ausschnitt, lange lockere Jogginghose).
  - **Überkopf-Trizeps neu:** langes Seil, Kabel **ganz unten** eingestellt.
  - Twisted Curls, Deans eigene Übungen (Chest Press Band, Cable Crunch Sideways, Decline Crunch, Shoulder Warm Up Cable, Bicep Curl Machine, Triceps Extension, Cable Pulldown, Stairmaster …), die Kampfsport-Drills.
  - Muskelgruppen-Bilder für Routinen (Legday, Push, Pull …).
- Später: Konten und Sync (Coach sieht Kundentrainings, Pläne kommen automatisch an), Paywall aktivieren.

### Backlog vom 17.10. – erledigt (live seit 19.10., APPV „19.10. 10:30“)
Anstrengung Stufe 2 „Letzte unsauber“, Erinnerung im Anfängermodus, Gewichtsschritte pro Gerät, Timer-Ton (vorher/ersetzen, auch im Reiter Routinen), Supersatz, Wochenbericht mit Export, Dragon Flag, Split-Wechsel A/B im Wochentakt, kcal pro Training, Training nachträglich bearbeiten inkl. Endzeit, automatische Update-Prüfung. Offen sind nur noch die Bild-Wünsche (Reverse Fly Cable überkreuzt, Überkopf-Trizeps, Dragon Flag, Seitheben am Kabel in Deans Variante: Rolle leicht unter Hüfthöhe, Kabel hinter dem Rücken, ca. 30° schräg zum Turm).

### Backlog vom 19.10. – erledigt (live seit 26.10., APPV „26.10. 12:45“)
Anstrengung 1–4 neu (Zu leicht · Letzte unsauber · Nur halb geschafft · Alles gegeben), Zirkel mit 3+ Übungen („Zur Gruppe davor hinzufügen“), Pause nur nach der letzten Übung einer Gruppe (Ansicht bleibt stehen, bis Pause vorbei/„Weiter“), Aufwärm-Markierung (blau) im Training und Routinen-Editor, „Deficit Deadlift (Trap Bar)“ inkl. Umbenennung im Verlauf (Migration `tb1`), Check-in vor/nach Training (Schalter in Daten, Schlüssel `hantelbuch.checkin`, Felder `food`/`feel` am Training, Auswertung im Wochenbericht).

### Noch offen (REPIT)
- **Sprache Englisch** in den Einstellungen (alle Texte, Übungen, Einführung, Hinweise).
- Bild „Deficit Deadlift (Trap Bar)“ (Trap Bar, erhöht auf Platte) – nutzt bis dahin das Kreuzheben-Bild.

## 5b. Strategie / Fahrplan (Deans Entscheidung)
1. **Erst Web-App:** REPIT und SOL Tracker laufen vorerst als **Web-Apps** (GitHub Pages, aufs iPhone über „Zum Home-Bildschirm“). Kein App Store, solange die Funktionen noch wachsen. So geht jede Änderung sofort live.
2. **Dann verknüpfen:** SOL Tracker (Ernährung) und REPIT (Training) werden zu **einer App „SOL“** zusammengeführt, mit den Bereichen PREPIT und REPIT, gemeinsamen Daten (z. B. Trainings-kcal → Tagesdefizit) und einem gemeinsamen Abo.
3. **Später App Store,** wenn beides stabil läuft. Dazu kommen Konten, Sync und Bezahlen.
- **Offene Technik-Frage, vor dem Start mit Dean klären:** SOL Tracker ist **Flutter**, REPIT ist **eine HTML-Datei**. Mögliche Wege: REPIT in Flutter nachbauen, SOL als Web-App neu bauen, oder vorerst zwei Web-Apps mit gemeinsamem Startbildschirm und Datenaustausch. Schlag ihm die Optionen kurz und als Rangliste vor und entscheide nicht allein.

## 6. SOL Tracker / Zusammenführung (nächstes Projekt)
- Ernährungs-App von Dean: Repo **`donpntlc/macro_tracker`** (Flutter), lokal `~/macro_tracker-1`. Web-Build mit `./web_bauen.sh` (baut die App und teilt sie in Upload-Pakete auf). In `lib/main.dart` gibt es `_webZoom` mit `kWebUiScale = 0.88`, damit die Web-Version weniger eng wirkt. **Dieser Build ist noch nicht ausgeführt und hochgeladen.**
- Geplant: **eine App „SOL“** (Logo „SOL“) mit zwei Bereichen: **PREPIT** (Ernährung, links) und **REPIT** (Training). Ein gemeinsames Abo für beide (kostenlos / Monat / Jahr).
- Design-Wunsch für SOL: **feine Trennlinien zwischen einzelnen Lebensmitteln und Rezepten** in Listen.
- **Kalorien aus dem Training:** Standardmässig **nicht** zum Essensbudget dazurechnen. Nur das Gesamtdefizit des Tages zeigen, am Wochenende das Wochendefizit in Fett umgerechnet (7000 kcal ≈ 1 kg). Optionaler Schalter: Trainings-kcal zum Tagesbudget addieren (für den Alltag ohne Diät oder Aufbau).
- **Erledigt 26.10.:** keine Nachkommastellen, Einkaufslisten + „Füllen“ (bis Zielmitte, in jeder Mahlzeit unter den Balken) zurückgeholt, Trennlinien in der Datenbank. Quellcode jetzt in **`donpntlc/sol-tracker`, Branch `source`**; jeder Push baut automatisch (GitHub Action) und veröffentlicht nach `main` (Pages). Fehlerlog bei Build-Fehlern im Branch `build-logs`.
- **Noch offen SOL:** Trainings-kcal manuell eintragen + Schalter „zum Budget addieren“ (Wochen-Fettäquivalent 7000 kcal gibt es schon im Wochen-Recap), Mahlzeiten vorplanen und abhaken.
- **Keine Nachkommastellen im Tracking:** Gramm, kcal und Prozent immer ganzzahlig gerundet anzeigen (z. B. „851 / 2234–2306 kcal“, „44 / 213 g“, „21 %“). Gilt für Tagesübersicht, Makros, Mahlzeiten, Zielmitte usw. Intern darf weiter genau gerechnet werden.
- **Mahlzeiten vorplanen und abhaken:** Mahlzeiten für heute/die nächsten Tage im Voraus eintragen (Lebensmittel + Menge, auch „Plan kopieren“ von gestern/Vorlage). Geplante Einträge erscheinen ausgegraut mit Haken-Kästchen und zählen noch nicht. Abhaken = gegessen → zählt ins Tracking. Menge beim Abhaken noch änderbar. Vorschau „Wenn du alles isst: X kcal / P / K / F“. Optional: Einkaufsliste aus dem Plan füllen.
- Es gibt außerdem die App „SOL Planer“ (`sol_day_planner`).
- **Zwei verschwundene Funktionen in SOL Tracker wiederherstellen** (sehr wichtig für Dean). Ursache gefunden: das Repo wurde von `main` auf den älteren Branch `master` umgestellt. Der vollständige Stand (Stash vom 21.06.) ist als Branch **`restore-sol`** gesichert. Genaue Schritte stehen in **`CURSOR_RESTORE.md`** im Repo:
  1. **Einkaufsliste**
  2. **„Füllen“:** Man tippt auf ein Makro bzw. auf kcal (Kohlenhydrate, Kalorien, Eiweiss, Fett …) und dann auf „Füllen“. Die App füllt bis zur Zielmitte auf und sagt, wie viel Gramm man vom gewählten Lebensmittel noch nehmen kann.
