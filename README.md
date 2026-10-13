# Kita St. Laurentius Neufang – Website

Statische One-Page-Website für https://kita-neufang.de/ – reines HTML/CSS/JS, ohne Build-Schritt und ohne externe Dienste.

- **Lokal ansehen:** `python -m http.server 8080` im Projektordner, dann http://localhost:8080
- **Veröffentlichen:** `powershell -ExecutionPolicy Bypass -File .\deploy.ps1` (vorher mit `-DryRun` prüfen; Zugangsdaten in `deploy.env`, Vorlage `deploy.env.example`)
- **Testseite:** `powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Test` → https://test.kita-neufang.de/ (passwortgeschützt, nicht in Suchmaschinen)

Weitere Infos:
- [CLAUDE.md](CLAUDE.md) – Aufbau der Seite, häufige Änderungen (Schließtage, Team, Beiträge …) und Regeln
- [docs/ENTSCHEIDUNGEN.md](docs/ENTSCHEIDUNGEN.md) – getroffene Entscheidungen und offene Punkte
- [BILDER-PROMPTS.md](BILDER-PROMPTS.md) – Prompts für die Illustrationen
