# Kita St. Laurentius Neufang – Website

Statische One-Page-Website (ehemals WordPress) für https://kita-neufang.de/.
Reines HTML/CSS/JS, **kein Build-Schritt, keine Abhängigkeiten**. Sprache der Inhalte: Deutsch (Sie-Form gegenüber Eltern).

## Struktur

- `index.html` – die komplette Startseite. Jeder Abschnitt ist mit einem großen `<!-- ===== ABSCHNITT ===== -->`-Kommentar markiert:
  Header/Navigation · Hero · Über uns · Angebote (+ Detail-Dialoge `dlg-*`) · Leitspruch + Zahlen · Gruppen · Team · Zeiten · Elternbeiträge · Voranmeldung & Kontakt · Footer
- `impressum.html`, `datenschutz.html` – Rechtstexte (enthalten `TODO`-Kommentare für fehlende Angaben)
- `assets/css/style.css` – gesamtes Design; Farben/Schriften als CSS-Variablen in `:root`
- `assets/js/main.js` – Menü, Dialoge, Team-Filter, Scroll-Effekte (gleitende Menü-Markierung, Hero-Tiefeneffekt, Hochzählen der Zahlen, Hervorhebung angesprungener Überschriften, Nach-oben-Knopf), Ausgrauen vergangener Schließtage. Alle Animationen respektieren "Bewegung reduzieren" (prefers-reduced-motion).
- `assets/img/team/vorname-nachname.jpg` – Teamfotos, quadratisch 600×600 (Originale in `bilder-roh/team/`)
- `assets/img/illustrations/*.webp` – aufbereitete Illustrationen (Prompts in `BILDER-PROMPTS.md`)
- `bilder-roh/` – Original-PNGs aus ChatGPT/Codex (nicht in Git, liegt nur lokal/OneDrive)
- `tools/bilder_generieren.py` – erzeugt Bilder per Codex CLI (ChatGPT-Plus) nach `bilder-roh/`
- `tools/bilder_aufbereiten.py` – entfernt Karomuster, verkleinert, speichert WebP
- `tools/hero_ebenen.py <name>` – zerlegt `bilder-roh/<name>.png` in Basis + animierte Ebenen (Sonnenstrahlen, Sonnengesicht) und gibt die %-Positionen für das CSS (`.hero-szene`) aus; Sonnen-Mittelpunkt je Bild in `BILDER` im Skript. Aktuell im Einsatz: `hero-3`
- `tools/aenderungen.ps1` – erzeugt beim `deploy.ps1 -Dev` die Seite https://dev.kita-neufang.de/aenderungen.html (letzte Commits, noch nicht Live-Stände hervorgehoben). Commit-Nachrichten deshalb verständlich auf Deutsch schreiben
- `tools/ebene_ausschneiden.py <name> <teil> <x> <y>` – schneidet einen frei stehenden Bildteil (Fläche unter Punkt x/y der `.webp`) als eigene Ebene aus, z. B. den flatternden Schmetterling `ueber-uns-2-falter.webp`; gibt die %-Position fürs CSS aus
- `assets/img/original/` – Archiv der alten Seite, wird nicht hochgeladen
- `assets/fonts/` – Fraunces und Nunito als lokale `.woff2` (kein Google Fonts)
- `assets/docs/Voranmeldung.pdf` – Anmeldeformular
- `entwurf-rundgang/` – Entwurf des Abschnitts „Rundgang“ (eigene `index.html`, `rundgang.css/.js`, Platzhalter-Fotos in `bilder/`); wird nur per `deploy.ps1 -Dev` hochgeladen → https://dev.kita-neufang.de/entwurf-rundgang/ (zusätzlich `noindex`). Nach Abstimmung in die Startseite übernehmen und Ordner löschen
- `docs/ENTSCHEIDUNGEN.md` – Entscheidungen und offene Punkte; `docs/rundgang-fotos-anleitung.png` – Foto-Anleitung für die Kita-Leitung
- `.htaccess` – Weiterleitungen alter WordPress-URLs, HTTPS, Caching
- `robots.txt` – sperrt den Entwurfsordner für Suchmaschinen
- `deploy.ps1` – verschlüsselter Upload per FTPS (Standard) oder SFTP (`PROTOKOLL` in `deploy.env`; Zugangsdaten nie committen)

## Häufige Änderungen

- **Schließtage** (jährlich): Abschnitt ZEITEN, `<li data-ende="JJJJ-MM-TT">` – `data-ende` ist der letzte geschlossene Tag; vergangene Einträge werden automatisch ausgegraut. Überschrift „Schließtage JJJJ/JJJJ“ und Hinweis „Kindergartenbeginn“ mitpflegen.
- **Team**: `<li class="member" data-gruppen="…">` im Abschnitt TEAM (Gruppen-Schild `<span class="tag t-perlen|t-edelstein|t-goldtaler">`, Leitung: `<b>Gruppenleitung</b>` hinter dem Gruppennamen); neues Foto quadratisch 600×600 als `assets/img/team/vorname-nachname.jpg` (neuer Dateiname statt Überschreiben, wegen Browser-Cache). Die Zahl „Mitarbeiterinnen“ zählt `main.js` automatisch aus den `.member`-Einträgen (`data-team-anzahl`) – nichts von Hand anpassen.
- **Zahlen** (Gruppen): Abschnitt LEITSPRUCH, `<ul class="stats">` (Kinderzahl bewusst weggelassen; die Leiste passt sich der Anzahl der Kacheln an). Die Mitarbeiterzahl dort ergibt sich automatisch (siehe Team).
- **Beiträge**: Abschnitt ELTERNBEITRÄGE, zwei Tabellen.
- **Neues Angebot**: `<button class="program" data-dialog="dlg-xyz">` + passender `<dialog class="info" id="dlg-xyz">`.
- **E-Mail** steht nie im Klartext: `<a class="js-mail" data-m="ofni.gnafuen#atik">kita [at] neufang.info</a>` (Adresse rückwärts, `#` statt `@`; `main.js` baut den Link).
- **Telefon**: 09260 / 785 (kommt in index, impressum, datenschutz und JSON-LD im `<head>` vor – überall ändern).

## Illustrationen

Muster: `<div class="art"> <img class="ill" src="…webp" onerror="this.remove()"> <svg class="fallback">…</svg> </div>`.
Existiert das Bild, wird die SVG-Ersatzgrafik per CSS (`.art:has(img.ill)`) ausgeblendet. Neue Bilder: PNG nach `bilder-roh/<name>.png`, dann `python tools/bilder_aufbereiten.py <name>`; im HTML immer die `.webp` referenzieren.

## Browser-Cache

CSS/JS werden 7 Tage, Bilder 30 Tage zwischengespeichert (`.htaccess`). Deshalb:
- Nach Änderungen an `style.css` oder `main.js` die Versionsnummer `?v=…` in **allen** HTML-Dateien hochzählen: `index.html`, `impressum.html`, `datenschutz.html` und – solange es ihn gibt – `entwurf-rundgang/index.html`.
- Geänderte Bilder unter **neuem Dateinamen** speichern statt die alte Datei zu überschreiben.

## Lokal ansehen & veröffentlichen

- Vorschau: `python -m http.server 8080` im Projektordner → http://localhost:8080
- Testseite: `powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Dev` → https://dev.kita-neufang.de/ (Ordner `DEV_DIR`, Passwort `DEV_USER`/`DEV_PASS` in `deploy.env`). Statt der Live-`.htaccess`/`robots.txt` werden `tools/dev.htaccess` (Passwortschutz, noindex, kein Cache), eine sperrende `robots.txt` und eine erzeugte `.htpasswd` hochgeladen. Ohne Passwortabfrage: einmal den Freischalt-Link `https://dev.kita-neufang.de/?zugang=<DEV_ZUGANG>` öffnen (Cookie, 1 Jahr). Größere Änderungen erst hier prüfen, dann live.
- Upload: `powershell -ExecutionPolicy Bypass -File .\deploy.ps1` (vorher `-DryRun` zum Prüfen). Bricht ab bei nicht committeten Änderungen an Seiten-Dateien; fragt nach, wenn sich die Seiten-Dateien von dem unterscheiden, was zuletzt per `-Dev` hochgeladen wurde (`-Force` überspringt die Frage). Hochgeladen werden nur Dateien, die sich seit der Markierung `dev`/`live` geändert haben, alle zusammen über eine FTPS-Verbindung; `-Alles` lädt den kompletten Stand. Gelöschte/umbenannte Dateien werden nur gemeldet und müssen auf dem Server von Hand entfernt werden.
- Nach jedem Upload zeigen die lokalen Git-Tags `dev` bzw. `live` auf den hochgeladenen Commit (`git log --oneline --decorate`). Kein lokales Dev-Verzeichnis: der Projektordner *ist* der Entwicklungsstand.

## Regeln

- Git: alle Änderungen direkt auf `main` committen, keine Feature-Branches.
- Getroffene Entscheidungen und offene Punkte stehen in `docs/ENTSCHEIDUNGEN.md` – neue Abmachungen dort mit Datum ergänzen.
- Keine externen Dienste einbinden (Google Fonts, Maps, CDNs, Tracking) – sonst muss die Datenschutzerklärung angepasst werden.
- Keine erfundenen Inhalte (z. B. Elternzitate, Termine) – nur, was die Kita liefert.
- Barrierearm bleiben: Alt-Texte, echte Überschriften-Hierarchie, ausreichende Kontraste.
