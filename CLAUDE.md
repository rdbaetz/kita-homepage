# Kita St. Laurentius Neufang – Website

Statische One-Page-Website (ehemals WordPress) für https://kita-neufang.de/.
Reines HTML/CSS/JS, **kein Build-Schritt, keine Abhängigkeiten**. Sprache der Inhalte: Deutsch (Sie-Form gegenüber Eltern).

## Struktur

- `index.html` – die komplette Startseite. Jeder Abschnitt ist mit einem großen `<!-- ===== ABSCHNITT ===== -->`-Kommentar markiert:
  Header/Navigation · Hero · Über uns · Angebote (+ Detail-Dialoge `dlg-*`) · Leitspruch + Zahlen · Unser Haus · Gruppen (+ Foto-Galerie) · Team · Zeiten · Elternbeiträge · Gut zu wissen (Entwurf, ausgeblendet) · Voranmeldung & Kontakt · Footer
- `impressum.html`, `datenschutz.html` – Rechtstexte (enthalten `TODO`-Kommentare für fehlende Angaben)
- `404.html` – Fehlerseite für falsche Adressen (`ErrorDocument` in `.htaccess` und `tools/dev.htaccess`); nutzt als einzige Seite **absolute** Pfade (`/assets/…`), weil sie unter beliebigen Adressen ausgeliefert wird
- `assets/css/style.css` – gesamtes Design; Farben/Schriften als CSS-Variablen in `:root`
- `assets/js/main.js` – Menü, Dialoge, Team-Filter, Scroll-Effekte (gleitende Menü-Markierung, Hero-Tiefeneffekt, Hochzählen der Zahlen, Nach-oben-Knopf, Jahreszeit im Hero: im Frühling Schmetterlinge, im Sommer Pusteblumen-Samen, im Herbst Blätter und im Winter Schnee, die kurz auf der Wiese liegen bleiben; Test mit `?jahreszeit=fruehling|sommer|herbst|winter`), Ausgrauen vergangener Schließtage. Alle Animationen respektieren "Bewegung reduzieren" (prefers-reduced-motion).
- `assets/img/team/vorname-nachname.jpg` – Teamfotos, quadratisch 600×600 (Originale in `bilder-roh/team/`)
- `assets/img/illustrations/*.webp` – aufbereitete Illustrationen (Prompts in `BILDER-PROMPTS.md`)
- `bilder-roh/` – Original-PNGs aus ChatGPT/Codex (nicht in Git, liegt nur lokal/OneDrive)
- `tools/bilder_generieren.py` – erzeugt Bilder per Codex CLI (ChatGPT-Plus) nach `bilder-roh/`
- `tools/bilder_aufbereiten.py` – entfernt Karomuster, verkleinert, speichert WebP
- `tools/hero_ebenen.py <name>` – zerlegt `bilder-roh/<name>.png` in Basis + animierte Ebenen (Sonnenstrahlen, Sonnengesicht) und gibt die %-Positionen für das CSS (`.hero-szene`) aus; Sonnen-Mittelpunkt je Bild in `BILDER` im Skript. Aktuell im Einsatz: `hero-3`, im Winter (Dez.–Feb.) `hero-3-winter` – den Tausch und die Jahreszeit bestimmt ein kleines Skript direkt hinter dem Titelbild in `index.html` (`<html data-jahreszeit>`), `main.js` liest sie mit
- `tools/aenderungen.ps1` – erzeugt beim `deploy.ps1 -Dev` die Seite https://dev.kita-neufang.de/aenderungen.html (letzte Commits, noch nicht Live-Stände hervorgehoben, Links zu den Commits auf GitHub). Commit-Nachrichten deshalb verständlich auf Deutsch schreiben
- `tools/teilen_bild.py` – erzeugt das Vorschaubild für geteilte Links `assets/img/teilen.jpg` (1200×630, `og:image`) aus Hero-Illustration, Logo und Slogan
- `tools/ebene_ausschneiden.py <name> <teil> <x> <y>` – schneidet einen frei stehenden Bildteil (Fläche unter Punkt x/y der `.webp`) als eigene Ebene aus, z. B. den flatternden Schmetterling `ueber-uns-2-falter.webp`; gibt die %-Position fürs CSS aus
- `assets/img/original/` – Archiv der alten Seite, wird nicht hochgeladen
- `assets/fonts/` – Fraunces und Nunito als lokale `.woff2` (kein Google Fonts)
- `assets/docs/Voranmeldung.pdf` – Anmeldeformular
- `assets/img/galerie/<bereich>/01.jpg …` – Fotos für die Galerien (Bereiche `aussen`, `garten`, `turnraum`, `weitere`, `edelsteine`, `goldtaler`, `perlen`); erzeugt mit `python tools/galerie_aufbereiten.py` aus `bilder-roh/galerie/<Ordner>/` (Bild mit Präfix `1_` wird `01.jpg`, Gesichter/Namen werden über `VERWISCHEN` im Skript unkenntlich gemacht)
- `docs/ENTSCHEIDUNGEN.md` – Entscheidungen und offene Punkte; `docs/rundgang-fotos-anleitung.png` – Foto-Anleitung für die Kita-Leitung
- `.htaccess` – Weiterleitungen alter WordPress-URLs, HTTPS, Caching
- `robots.txt` – erlaubt Suchmaschinen alles
- `deploy.ps1` – verschlüsselter Upload per FTPS (Standard) oder SFTP (`PROTOKOLL` in `deploy.env`; Zugangsdaten nie committen)

## Häufige Änderungen

- **Schließtage** (jährlich): Abschnitt ZEITEN, `<li data-ende="JJJJ-MM-TT">` – `data-ende` ist der letzte geschlossene Tag; vergangene Einträge werden automatisch ausgegraut. Überschrift „Schließtage JJJJ/JJJJ“ und Hinweis „Kindergartenbeginn“ mitpflegen.
- **Team**: `<li class="member" data-gruppen="…">` im Abschnitt TEAM (Gruppen-Schild `<span class="tag t-perlen|t-edelstein|t-goldtaler">`, Leitung: `<b>Gruppenleitung</b>` hinter dem Gruppennamen); neues Foto quadratisch 600×600 als `assets/img/team/vorname-nachname.jpg` (neuer Dateiname statt Überschreiben, wegen Browser-Cache). Die Zahl „Mitarbeiterinnen“ zählt `main.js` automatisch aus den `.member`-Einträgen (`data-team-anzahl`) – nichts von Hand anpassen.
- **Zahlen** (Gruppen): Abschnitt LEITSPRUCH, `<ul class="stats">` (Kinderzahl bewusst weggelassen; die Leiste passt sich der Anzahl der Kacheln an). Die Mitarbeiterzahl dort ergibt sich automatisch (siehe Team).
- **Beiträge**: Abschnitt ELTERNBEITRÄGE, zwei Tabellen.
- **Fotos** (Abschnitte UNSER HAUS und GRUPPEN): Knopf/Kachel mit `data-raum="KEY"` öffnet die Galerie; die Bilder stehen in `<template id="galerie-KEY">` als `<figure><img><figcaption>`. Bildunterschriften und die Anzahl „N Fotos“ von Hand pflegen. Neue Fotos: in `bilder-roh/galerie/` ablegen, Skript laufen lassen – wegen Browser-Cache (30 Tage) bei geänderten Bildern das Ziel unter neuem Namen speichern bzw. Bild-URL mit `?v=` versehen.
- **Gut zu wissen** (Abschnitt GUT ZU WISSEN): je Frage ein `<details class="frage" name="gut-zu-wissen">` mit `<summary>`; noch ausgeblendet (`hidden data-entwurf`), sichtbar mit `?entwurf` an der Adresse.
- **Neues Angebot**: `<button class="program" data-dialog="dlg-xyz">` + passender `<dialog class="info" id="dlg-xyz">`. Den farbigen Kreis im Dialog-Kopf (`<span class="dot bg-…"></span>`) leer lassen – `main.js` setzt beim Öffnen das Bild der Kachel ein.
- **E-Mail** steht nie im Klartext: `<a class="js-mail" data-m="ofni.gnafuen#atik">kita [at] neufang.info</a>` (Adresse rückwärts, `#` statt `@`; `main.js` baut den Link).
- **Telefon**: 09260 / 785 (kommt in index, impressum, datenschutz und JSON-LD im `<head>` vor – überall ändern).

## Illustrationen

Muster: `<div class="art"> <img class="ill" src="…webp" onerror="this.remove()"> <svg class="fallback">…</svg> </div>`.
Existiert das Bild, wird die SVG-Ersatzgrafik per CSS (`.art:has(img.ill)`) ausgeblendet. Neue Bilder: PNG nach `bilder-roh/<name>.png`, dann `python tools/bilder_aufbereiten.py <name>`; im HTML immer die `.webp` referenzieren.

## Browser-Cache

CSS/JS werden 7 Tage, Bilder 30 Tage zwischengespeichert (`.htaccess`). Deshalb:
- Nach Änderungen an `style.css` oder `main.js` die Versionsnummer `?v=…` in **allen** HTML-Dateien hochzählen: `index.html`, `impressum.html`, `datenschutz.html`, `404.html`.
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
- Seite nicht überladen: Leitlinie in `docs/ENTSCHEIDUNGEN.md` (2026-10-13) beachten – höchstens ein neuer Abschnitt, Längeres zugeklappt, Menü wächst nicht.
- Keine erfundenen Inhalte (z. B. Elternzitate, Termine) – nur, was die Kita liefert.
- Barrierearm bleiben: Alt-Texte, echte Überschriften-Hierarchie, ausreichende Kontraste.
