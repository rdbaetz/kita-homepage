"""Bereitet die Fotos für die Galerie im Entwurf auf.

Quelle:  bilder-roh/galerie/<Ordner>/*.jpg  (Kamera-Originale, nicht in Git)
Ziel:    entwurf-rundgang/bilder/<key>/01.jpg, 02.jpg …

Reihenfolge: das Bild mit dem Präfix "1_" wird 01.jpg (Titelbild der Kachel bzw. erstes
Vorschaubild), danach die übrigen nach Dateinamen. Der Ordner "UnserKindergarten" wird
aufgeteilt: Gebäude-Fotos → aussen, der Rest → weitere.
Die Zielordner werden vorher geleert. Lange Kante 1600 px, JPEG-Qualität 82.

Aufruf:  python tools/galerie_aufbereiten.py
"""
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
ROH = ROOT / "bilder-roh" / "galerie"
ZIEL = ROOT / "entwurf-rundgang" / "bilder"
KANTE = 1600

# key → (Rohordner, Filter auf den Dateinamen oder None, feste Reihenfolge oder None)
BEREICHE = {
    "aussen": ("UnserKindergarten", lambda n: "Gebauede" in n, None),
    "weitere": ("UnserKindergarten", lambda n: "Gebauede" not in n,
                ["6R7A6372.jpg", "6R7A6364.jpg", "6R7A6368.jpg", "6R7A6547.jpg", "Kueche.jpg"]),
    "garten": ("Garten", None, None),
    "turnraum": ("Turnraum", None, None),
    "edelsteine": ("Edelsteingruppe", None, None),
    "goldtaler": ("Goldtalergruppe", None, None),
    "perlen": ("Perlengruppe", None, None),
}


def sortiert(dateien, reihenfolge):
    if reihenfolge:
        nach_name = {d.name: d for d in dateien}
        return [nach_name[n] for n in reihenfolge]
    # "1_…" zuerst, dann nach Name
    return sorted(dateien, key=lambda d: (not d.name.startswith("1_"), d.name.lower()))


def main():
    for key, (ordner, filt, reihenfolge) in BEREICHE.items():
        dateien = [d for d in (ROH / ordner).glob("*.jpg") if filt is None or filt(d.name)]
        ziel = ZIEL / key
        ziel.mkdir(parents=True, exist_ok=True)
        for alt in ziel.glob("*.jpg"):
            alt.unlink()
        for i, quelle in enumerate(sortiert(dateien, reihenfolge), 1):
            im = ImageOps.exif_transpose(Image.open(quelle)).convert("RGB")
            im.thumbnail((KANTE, KANTE), Image.LANCZOS)
            out = ziel / f"{i:02d}.jpg"
            im.save(out, quality=82, optimize=True, progressive=True)
            print(f"{key}/{out.name} <- {ordner}/{quelle.name}  {im.size[0]}x{im.size[1]}")


if __name__ == "__main__":
    main()
