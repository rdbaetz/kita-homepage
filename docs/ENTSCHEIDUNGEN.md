# Entscheidungen – Relaunch kita-neufang.de

Protokoll der Abmachungen zum Umstieg von WordPress auf eine statische Website.
Neue Entscheidungen bitte unten ergänzen (mit Datum).

---

## 2026-10-12 – Relaunch als statische One-Page

### Ziel
Die bisherige WordPress-Seite https://kita-neufang.de/ wird durch eine **statische Website** ersetzt, damit alle Inhalte direkt mit KI (Claude Code) im Git-Repository bearbeitet werden können.

### Technik
| Entscheidung | Begründung |
|---|---|
| Reines HTML/CSS/JS, **kein Build-Tool, kein Framework** | Einfachste Bearbeitung durch KI und Menschen, keine Abhängigkeiten, die veralten |
| **One-Page** (`index.html`) mit Sprungmarken | Wunsch nach neuem, intuitivem One-Page-Design |
| Impressum und Datenschutz als **eigene Seiten** | Rechtlich üblich, von jeder Seite aus direkt erreichbar |
| Schriften (Fraunces, Nunito) **lokal gehostet** | Kein Google-Fonts-Abruf → keine Datenübertragung an Dritte (DSGVO) |
| **Keine externen Dienste** (kein Google Maps, kein Facebook, kein Tracking, keine Cookies) | Datenschutz; Karte nur als Link zu OpenStreetMap |
| `.htaccess` mit 301-Weiterleitungen der alten WordPress-URLs | Bestehende Links, Lesezeichen und Google-Treffer bleiben gültig |
| Detailtexte der Angebote in nativen `<dialog>`-Fenstern | Seite bleibt kompakt, Details auf Klick |
| Vergangene Schließtage werden per JS automatisch ausgegraut | Weniger Pflegeaufwand |

### Hosting & Veröffentlichung
- Hosting bleibt beim **bisherigen Webhoster**, Upload per **FTP(S)** mit `deploy.ps1`.
- Zugangsdaten stehen in `deploy.env` (lokal, per `.gitignore` ausgeschlossen – **nie committen**).
- Vor dem ersten Upload: WordPress auf dem Server sichern und entfernen.

### Design
- Gestaltung nach dem vorgegebenen Referenz-Screenshot: Salbeigrün, Creme, Pastell-Kreise, Wellen-Übergänge, Serifen-Überschriften.
- **Bisheriges Logo bleibt** (Wiedererkennung); die Seite nutzt das ruhige Grün-Design, Logo-Rot/-Gelb nur als kleine Akzente.
- Die Sektion „Was Eltern sagen“ aus der Vorlage wird **nicht** umgesetzt, da es keine echten Elternstimmen gibt. Stattdessen: grünes Band mit dem Leitspruch **„Man ist nie zu klein, um großartig zu sein“** und den Zahlen 10 Mitarbeiterinnen / 45 Kinder / 3 Gruppen.
- Grundsatz: **keine erfundenen Inhalte** (Zitate, Termine, Angaben) – nur, was die Kita liefert.

### Inhalte & Bilder
- Alle Texte wurden von der alten Seite übernommen (Startseite, „Lernen, entdecken und wachsen“, Elternbeiträge, Voranmeldung, Impressum).
- **Team-Fotos werden weiterhin gezeigt** (übernommen von der alten Seite).
- Voranmeldung bleibt ein PDF zum Ausdrucken (`assets/docs/Voranmeldung.pdf`).
- Illustrationen (Hero, Über uns, Angebote, Gruppen) werden **mit ChatGPT generiert**; Prompts in `BILDER-PROMPTS.md`. Bis sie vorliegen, zeigt die Seite SVG-Ersatzgrafiken.

### Kontaktdaten
- **Telefon: 09260 / 785** ist korrekt. Die abweichende Nummer 786 aus dem alten Impressum/Datenschutz wurde überall ersetzt.

### Rechtstexte
- Impressum: Rechtsgrundlage auf **§ 5 DDG** aktualisiert (TMG ist seit Mai 2024 abgelöst); veralteter Hinweis auf die EU-Streitschlichtungsplattform entfernt.
- Datenschutzerklärung neu und schlank formuliert, passend zur Seite ohne Cookies und Drittdienste.

---

## 2026-10-12 – Bilderzeugung ohne Zusatzkosten

- **Keine OpenAI-API** (kostet pro Bild extra) und **keine Fernsteuerung der ChatGPT-App/-Webseite** (Grauzone laut Nutzungsbedingungen).
- Stattdessen: **Codex CLI** mit ChatGPT-Plus-Login; Bilder laufen über das Plus-Kontingent. Skript `tools/bilder_generieren.py` liest die Prompts aus `BILDER-PROMPTS.md`.
- Das Skript wird **vom Nutzer selbst gestartet**, nicht von Claude Code (Claude darf keinen weiteren autonomen Agenten starten). Danach übernimmt Claude Code Prüfung, Optimierung und Einbau.

---

## Offene Punkte

- [ ] **Schließtage 2026/2027** von der Kita einholen (alle Termine 2025/26 sind vergangen).
- [ ] **Träger** der Kita im Impressum ergänzen (TODO in `impressum.html`).
- [ ] **Webhoster** in der Datenschutzerklärung nennen (TODO in `datenschutz.html`).
- [ ] Klären, ob bei kirchlicher Trägerschaft das **KDG** statt der DSGVO gilt; ggf. Datenschutzbeauftragten nennen.
- [ ] ChatGPT-Illustrationen erzeugen und in `assets/img/illustrations/` ablegen.
- [ ] Zahlen (Mitarbeiterinnen/Kinder/Gruppen) auf Aktualität prüfen.
- [ ] Erster Upload: WordPress sichern, entfernen, `deploy.ps1` ausführen, Weiterleitungen testen.
