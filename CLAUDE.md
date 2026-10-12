# Kita St. Laurentius Neufang – Website

Statische One-Page-Website (ehemals WordPress) für https://kita-neufang.de/.
Reines HTML/CSS/JS, **kein Build-Schritt, keine Abhängigkeiten**. Sprache der Inhalte: Deutsch (Sie-Form gegenüber Eltern).

## Struktur

- `index.html` – die komplette Startseite. Jeder Abschnitt ist mit einem großen `<!-- ===== ABSCHNITT ===== -->`-Kommentar markiert:
  Header/Navigation · Hero · Über uns · Angebote (+ Detail-Dialoge `dlg-*`) · Leitspruch + Zahlen · Gruppen · Team · Zeiten · Elternbeiträge · Voranmeldung & Kontakt · Footer
- `impressum.html`, `datenschutz.html` – Rechtstexte (enthalten `TODO`-Kommentare für fehlende Angaben)
- `assets/css/style.css` – gesamtes Design; Farben/Schriften als CSS-Variablen in `:root`
- `assets/js/main.js` – Menü, Dialoge, Team-Filter, Scroll-Effekte (Fortschrittsbalken, gleitende Menü-Markierung, Hero-Tiefeneffekt, Hochzählen der Zahlen, Hervorhebung angesprungener Überschriften, Nach-oben-Knopf), Ausgrauen vergangener Schließtage. Alle Animationen respektieren "Bewegung reduzieren" (prefers-reduced-motion).
- `assets/img/team/vorname-nachname.jpg` – Teamfotos, quadratisch 600×600 (Originale in `bilder-roh/team/`)
- `assets/img/illustrations/*.webp` – aufbereitete Illustrationen (Prompts in `BILDER-PROMPTS.md`)
- `bilder-roh/` – Original-PNGs aus ChatGPT/Codex (nicht in Git, liegt nur lokal/OneDrive)
- `tools/bilder_generieren.py` – erzeugt Bilder per Codex CLI (ChatGPT-Plus) nach `bilder-roh/`
- `tools/bilder_aufbereiten.py` – entfernt Karomuster, verkleinert, speichert WebP
- `tools/hero_ebenen.py` – zerlegt `bilder-roh/hero.png` in Basis + animierte Ebenen (Sonnenstrahlen, Sonnengesicht, Drache) und gibt die %-Positionen für das CSS (`.hero-szene`) aus
- `assets/img/original/` – Archiv der alten Seite, wird nicht hochgeladen
- `assets/docs/Voranmeldung.pdf` – Anmeldeformular
- `.htaccess` – Weiterleitungen alter WordPress-URLs, HTTPS, Caching
- `deploy.ps1` – verschlüsselter Upload per FTPS (Standard) oder SFTP (`PROTOKOLL` in `deploy.env`; Zugangsdaten nie committen)

## Häufige Änderungen

- **Schließtage** (jährlich): Abschnitt ZEITEN, `<li data-ende="JJJJ-MM-TT">` – `data-ende` ist der letzte geschlossene Tag; vergangene Einträge werden automatisch ausgegraut. Überschrift „Schließtage JJJJ/JJJJ“ und Hinweis „Kindergartenbeginn“ mitpflegen.
- **Team**: `<li class="member" data-gruppen="…">` im Abschnitt TEAM (Gruppen-Schild `<span class="tag t-perlen|t-edelstein|t-goldtaler">`, Leitung: `<b>Gruppenleitung</b>` hinter dem Gruppennamen); neues Foto quadratisch 600×600 als `assets/img/team/vorname-nachname.jpg` (neuer Dateiname statt Überschreiben, wegen Browser-Cache). Zahl „Mitarbeiterinnen“ im Leitspruch-Abschnitt und Text „Zehn Kolleginnen“ anpassen.
- **Zahlen** (Mitarbeiter/Kinder/Gruppen): Abschnitt LEITSPRUCH, `<ul class="stats">`.
- **Beiträge**: Abschnitt ELTERNBEITRÄGE, zwei Tabellen.
- **Neues Angebot**: `<button class="program" data-dialog="dlg-xyz">` + passender `<dialog class="info" id="dlg-xyz">`.
- **E-Mail** steht nie im Klartext: `<a class="js-mail" data-m="ofni.gnafuen#atik">kita [at] neufang.info</a>` (Adresse rückwärts, `#` statt `@`; `main.js` baut den Link).
- **Telefon**: 09260 / 785 (kommt in index, impressum, datenschutz und JSON-LD im `<head>` vor – überall ändern).

## Illustrationen

Muster: `<div class="art"> <img class="ill" src="…webp" onerror="this.remove()"> <svg class="fallback">…</svg> </div>`.
Existiert das Bild, wird die SVG-Ersatzgrafik per CSS (`.art:has(img.ill)`) ausgeblendet. Neue Bilder: PNG nach `bilder-roh/<name>.png`, dann `python tools/bilder_aufbereiten.py <name>`; im HTML immer die `.webp` referenzieren.

## Browser-Cache

CSS/JS werden 7 Tage, Bilder 30 Tage zwischengespeichert (`.htaccess`). Deshalb:
- Nach Änderungen an `style.css` oder `main.js` die Versionsnummer `?v=…` in **allen drei** HTML-Dateien hochzählen.
- Geänderte Bilder unter **neuem Dateinamen** speichern statt die alte Datei zu überschreiben.

## Lokal ansehen & veröffentlichen

- Vorschau: `python -m http.server 8080` im Projektordner → http://localhost:8080
- Upload: `powershell -ExecutionPolicy Bypass -File .\deploy.ps1` (vorher `-DryRun` zum Prüfen)

## Regeln

- Git: alle Änderungen direkt auf `main` committen, keine Feature-Branches.
- Getroffene Entscheidungen und offene Punkte stehen in `docs/ENTSCHEIDUNGEN.md` – neue Abmachungen dort mit Datum ergänzen.
- Keine externen Dienste einbinden (Google Fonts, Maps, CDNs, Tracking) – sonst muss die Datenschutzerklärung angepasst werden.
- Keine erfundenen Inhalte (z. B. Elternzitate, Termine) – nur, was die Kita liefert.
- Barrierearm bleiben: Alt-Texte, echte Überschriften-Hierarchie, ausreichende Kontraste.
