"""Erzeugt die Illustrationen über die Codex CLI (ChatGPT-Plus-Login, keine API-Kosten).

Voraussetzung: Codex CLI installiert und per `codex login` mit dem ChatGPT-Konto angemeldet,
Feature `image_generation` aktiv (`codex features list`).

Prompts kommen aus BILDER-PROMPTS.md (Stil-Block + Abschnitte mit `dateiname.png`).

Aufruf im Projektordner:
    python tools/bilder_generieren.py              # alle fehlenden Bilder
    python tools/bilder_generieren.py hero         # nur bestimmte (Name ohne .png)
    python tools/bilder_generieren.py --neu hero   # vorhandenes Bild überschreiben
    python tools/bilder_generieren.py --liste      # nur anzeigen, was erzeugt würde
"""

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROMPTS = ROOT / "BILDER-PROMPTS.md"
ZIEL = ROOT / "bilder-roh"  # Originale; danach tools/bilder_aufbereiten.py


def lade_prompts():
    text = PROMPTS.read_text(encoding="utf-8")
    stil = re.search(r"## Stil-Block.*?```\n(.*?)```", text, re.S).group(1).strip()
    bilder = {}
    # Abschnitt mit `name.png` in der Überschrift, gefolgt vom ersten Codeblock
    for m in re.finditer(r"^#{2,3} [^\n]*?`([\w-]+)\.png`[^\n]*\n(.*?)```\n(.*?)```", text, re.S | re.M):
        name, zwischen, motiv = m.group(1), m.group(2), m.group(3).strip()
        fmt = re.search(r"Format: ([^\n]+)", zwischen)
        bilder[name] = (motiv, fmt.group(1).strip() if fmt else "quadratisch 1024x1024")
    return stil, bilder


def main(args):
    neu = "--neu" in args
    nur_liste = "--liste" in args
    namen = [a for a in args if not a.startswith("--")]

    stil, bilder = lade_prompts()
    auswahl = namen or list(bilder)
    unbekannt = [n for n in auswahl if n not in bilder]
    if unbekannt:
        sys.exit(f"Unbekannt: {', '.join(unbekannt)}. Verfügbar: {', '.join(bilder)}")

    ZIEL.mkdir(parents=True, exist_ok=True)
    for name in auswahl:
        datei = ZIEL / f"{name}.png"
        if datei.exists() and not neu:
            print(f"✓ {name}.png existiert schon (mit --neu überschreiben)")
            continue
        if nur_liste:
            print(f"→ würde erzeugen: {name}.png")
            continue
        motiv, fmt = bilder[name]
        rel = datei.relative_to(ROOT).as_posix()
        prompt = (
            f"Erzeuge mit deinem Bildgenerierungs-Werkzeug genau EIN Bild und speichere es als PNG unter {rel}. "
            "Ändere keine anderen Dateien.\n\n"
            f"Stil:\n{stil}\n\nMotiv:\n{motiv}\n\nFormat: {fmt}, transparenter Hintergrund."
        )
        print(f"… erzeuge {name}.png (kann 1–3 Minuten dauern)")
        r = subprocess.run(
            ["codex", "exec", "--skip-git-repo-check", "-s", "workspace-write", "-C", str(ROOT), "-"],
            input=prompt, text=True, encoding="utf-8",
        )
        if r.returncode != 0 or not datei.exists():
            print(f"✗ {name}.png wurde nicht erzeugt (Exit {r.returncode})")
        else:
            print(f"✓ {name}.png gespeichert")
            subprocess.run([sys.executable, str(ROOT / "tools" / "bilder_aufbereiten.py"), name])


if __name__ == "__main__":
    main(sys.argv[1:])
