# SOL — Roadmap / offene Ideen

Merkliste für die nächsten Features und Konzepte. Wird mit dem Assistenten gepflegt.

## UX / Produkt-Prinzipien (für alles, was dazukommt)

- **Einfachheit zuerst** — die App darf **keine** Benutzerfreundlichkeit verlieren: wenig kognitiv, klar, täglich ohne Umwege bedienbar.
- **Hauptjob ungeteilt** — Tracking, Tageskram, was man **jetzt** braucht, bleibt im Vordergrund; kein Wälzen durch lange Texte oder tiefe Menüs fürs Alltagsgeschäft.
- **Zusatzfunktionen: ~2 Klicks, leicht verlagert** — sinnvoll **gut erreichbar**, aber **nicht** in der gleichen visuellen Ebene wie der Kern: z. B. Einstellungen, zweite Ebene, Icon neben dem Haupt-CTA — *hilfreich, aber kein Dauer-Noise am Startscreen.*
- **Nicht überladen** — Ziel ist, dem Menschen **zu helfen, ohne viel mitdenken zu müssen**; lieber **visuelle Anzeigen** (Balken, Karten, kompakte Kennzahlen) als Wände aus Zahlen.
- **Wochen-/längerfristige Auswertung** — **weiter sinnvoll** (Wochenbilanz, vergleichen, speichern), idealerweise **eigenständig aufrufbar** (z. B. aus **Einstellungen** / eigener Sektion) und wo möglich **eingeklappt** im Alltag, **aufgeklappt** wenn man es aktiv sucht.

*Kurz: alles in einem, aber getrennt nach Dringlichkeit — Kern flach, Analyse & Extras in Reichweite ohne mentalen Overhead.*

## Offen

### Einkaufsliste (geplant — noch nicht im Code)
*Status: Spez erfasst, UI/Datenmodell bewusst ausstehend — bei Rückkehr: „was steht noch an?“ hier nachlesen.*

- **Kern**
  - Lebensmittel **direkt aus der App** in eine Einkaufsliste legen
  - In der Liste **Makro-Übersicht** sichtbar (u. a. Carbs, Eiweiß, …) — angebunden an bestehende `Food`-Daten
- **„Läden“ / getrennte Listen (2–3)**
  - Eigene **gespeicherte Namen** (müssen nicht echte unterschiedliche Supermärkte sein — eher 2–3 logische Eimer pro Einkaufs-Setup)
  - Pro „Laden“/Liste: zugehörige Lebensmittel-Einträge
- **Zwei Zeithorizonte (oder -typen)**
  - **Daily-Liste** — Dinge, die man **bald / sofort** holen muss
  - **Monatsliste** — **Mengen-Einkauf / Monat** (Bulk)
- **Nicht-Food & Freitext**
  - Innerhalb (oder parallel) **trennbar** z. B. Sektion **„Alltagseinkauf“** o. ä. — für Dinge **ohne** Essens-Bezug
  - **Freie Textzeilen** möglich (nicht nur verknüpfte `Food`s)

*Hinweis: Optional später UX „extra Gruppe“/Tab in der App — bis dahin nur diese Datei + Chat-Kontext.*

### Krasse Rezepte mit eigenen Bildern + KI-Edits
- Rezept-Datenbank: Eigenkreationen mit echten DON-Werten + epischen Bildern
- Workflow: User schickt eigene Fotos pro Gericht → daraus krasse KI-Bilder im SOL-Stil (dunkel, gold-warm, dramatisch, gallery-quality)
- Schon angelegt:
  - **Eiweißwolken** (mit erstem KI-Generated-Bild im SOL-Stil, Werte vorläufig: 13P/3C/0.5F pro 100g)
  - Infrastruktur: `Food.imagePath`-Feld, neue Kategorie **„Rezepte"** in DE/EN/SR/PT, Thumbnail in Liste, großes Bild im Detail, `assets/recipes/` Ordner in pubspec
- Noch zu tun:
  - User schickt Fotos und echte Werte → existierende Defaults überschreiben + neue Rezepte einpflegen
  - Liste der bekannten Rezepte vom User: **Eiweißwolken**, **Magerquark-Bowl** (eigene Variante), **Protein Shake** (eigene Variante), … weitere folgen
  - Optional: Rezept-Notizen/Schritte pro Eintrag (separates Feld) — falls gewünscht

### Dopamin-Reset-Plan (Food Detox, 1 Woche)
- Ziel: Gehirn darauf trainieren, dass Essen **keine Dopamin-Quelle** mehr ist, sondern neutraler Brennstoff
- Konzept-Skizze:
  - 5 Tage **Wasserfasten** mit ca. 10h-Fenster ohne Nahrung (genauer Modus noch zu definieren — 10h täglich? oder 10h/Tag + Rest?)
  - Danach **Frühstück einführen**, aber bewusst in **Dankbarkeit**, kleine Portion, keine Stimulans-Foods
  - Kein Zucker, keine hochverarbeiteten Foods, keine Snacks zwischendurch
  - Fokus: **Bewusstheit > Genuss**
- Noch zu tun:
  - Genaues Protokoll schreiben (Tag 1–7 Struktur, Fasten-Fenster, erlaubte Foods)
  - Begleitende Notizen/Reflexion pro Tag
  - Integration in SOL: eigener Modus **"Reset"** oder geführter 7-Tage-Plan mit Checklisten pro Tag?
  - Optional: spirituelle Komponente (Gebet/Dank vor dem Essen, Kreuz-Ästhetik passt zum Logo)

### Pre-Workout: KH-Detail + „Prüfung“ (noch **nicht** im Code)
*Chat 2026-04-26: Spez, Umsetzung offen — bei Rückkehr: hier weiterbauen.*

- **UI:** Statt sofort zwei Balken (komplex / einfach) → **ein** gemeinsamer KH-Balken (Pre-Workout) + **Sperr-Hinweis** (z. B. Schloss/„mehr wissen“); Tipp: „Bestehe die Prüfung zu Kohlenhydraten, um diese Funktion freizuschalten.“
- **Lern-Fläche (vor Quiz):** Text zu 30–90 min (komplex: Glykogen, kein harter Zucker-Kick) vs. direkt davor (einfach: schnell ins Blut); **Insulin**; nach Training: Sensitivität, Speicher auffüllen, eher **komplex**; Zitat: großer Performance-Unterschied, wenn man es versteht — **ansprechend** aufbereitet, nicht nur Textwand.
- **Quiz:** ~**10** Frage-Varianten (ähnliches Wissen, andere Formulierung), pro Durchlauf mischen; **3 richtige in Folge** = bestanden; bei falsch **X** + nächste Frage, bei richtig **Haken** + Streak; Fortschritt persistieren (z. B. `SharedPreferences` wie anderes App-State).
- **Nach Bestehen:** komplex/einfach-Balken wie heute; optional Fußnoten/Keys DE/EN/SR/PT ergänzen.

## Erledigt

- **Ernährung im Überblick** (Einleitung): durchgängig in DE/EN/SR/PT, ohne statisches Bild — Farbstreifen pro Makro + 50/30/20-Balken, Cinzel-Titel; altes `nutrition_infographic.png` entfernt
- App-Icon (SOL-Monogramm mit dezentem Kreuz, schwarzer Hintergrund, warmer Schein)
- Tages-Notizen: Feld pro Tag, sichtbar im Kalender-Tag-Dialog und in der Tagesübersicht
- Alltag-Slider: **Performance ↔ Entspannt** (beeinflusst nur die Meal-Verteilung, kcal/Ziele bleiben gleich)
- Modi: **Aggressiv Cut / Lean Bulk / Alltag / Advanced**
- Advanced-Preset-Slider: **Aggressiv Cut ↔ Dirty Bulk** (Makros zuerst, kcal daraus abgeleitet)
- Intro erweitert: **Warum Makros — nicht Kalorien** + **Wie dein Körper arbeitet** (Priorität: Protein → Fett → Carbs)
- Mehrsprachigkeit: DE / EN / SR / PT
- SOL-Rechner (Alltag / Aggressiv Cut / Lean Bulk / Advanced)
- Tages-Reset, Kalender, Wochenbilanz, Gewicht pro Tag
- Segen-Popup nach jedem Meal-Track: 🌞 „Der Mensch lebt nicht vom Brot allein." — 1,5s Fade-in/out mit Scale-Animation
- KFA-Schätzer im SOL-Rechner: Info-Button mit Erklärung + Maßband-Methode (US-Navy, ±3%) und visuelle Einstufung (6 Stufen m/w, ±5%) — Ergebnis geht direkt ins KFA-Feld
- Tagesübersicht Makros: Startet mit nur Kalorien-Bar, klappt auf Tap (Pfeil-Chevron) auf, um Protein, Carbs, Fett mit Bars anzuzeigen
- Kontrast-Fixes im Dark Theme: Dropdown-Texte, Slider-Labels, Notizen, etc. jetzt lesbar
- Makro-Formel-Fix: Fett jetzt 0,75 g/kg Körpergewicht (nicht fettfreie Masse) + Erklärungen angepasst
- Einleitung luftiger: eigener Card-Stil mit mehr Padding, gold-akzentuierter Titel + dünner Trennstrich, größere Body-Schrift, Zeilenhöhe 1.65
- Per-Meal Makro-Verteilung im Tracking nur in **Advanced** sichtbar/änderbar — in Aggressiv Cut / Lean Bulk / Alltag komplett entfernt
- **Disziplin-Verwarnung**: in Aggressiv Cut / Lean Bulk — wenn 2+ Tage in der letzten Woche um >150 kcal vom Plan abweichen, einmal pro Tag Pop-up: „Halt dich an deinen Plan — Fokus, Disziplin!“ (im Cut zusätzlich Achtung-Block: 70 kcal/kg Körperfett max. Fett-Abbau pro Tag, alles drüber kostet Muskel)
