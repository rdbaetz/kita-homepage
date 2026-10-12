"""Schneidet einen frei stehenden Bildteil (z. B. Schmetterling) als eigene Ebene aus einer
aufbereiteten Illustration aus, damit er per CSS animiert werden kann.

Eingang:  assets/img/illustrations/<name>.webp
Ausgang:  assets/img/illustrations/<name>-basis.webp   – Bild ohne den Teil
          assets/img/illustrations/<name>-<teil>.webp  – nur der Teil
Ausgabe der Position (in % des Gesamtbilds) für das CSS.

Ausgeschnitten wird die zusammenhängende Fläche unter dem Punkt x y (px in der .webp)
plus kleine Splitter (z. B. Fühler), die ganz in ihrem Rahmen liegen.

Aufruf:   python tools/ebene_ausschneiden.py ueber-uns-2 falter 948 530
"""

import sys
from pathlib import Path

from PIL import Image

from hero_ebenen import komponenten

ORDNER = Path(__file__).resolve().parent.parent / "assets" / "img" / "illustrations"


def main(name, teil, x, y):
    im = Image.open(ORDNER / f"{name}.webp").convert("RGBA")
    w, h = im.size
    px = im.load()
    sichtbar = lambda a, b: px[a, b][3] > 10

    suche = (max(0, x - 200), max(0, y - 200), min(w, x + 200), min(h, y + 200))
    teile = list(komponenten(sichtbar, w, h, suche))
    haupt = next(t for t in teile if (x, y) in t)
    x0 = min(p[0] for p in haupt); y0 = min(p[1] for p in haupt)
    x1 = max(p[0] for p in haupt) + 1; y1 = max(p[1] for p in haupt) + 1
    punkte = list(haupt)
    for t in teile:
        if t is not haupt and len(t) < 50 and all(x0 <= a < x1 and y0 <= b < y1 for a, b in t):
            punkte += t

    lay = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    lp = lay.load()
    basis = im.copy()
    bp = basis.load()
    for a, b in punkte:
        lp[a - x0, b - y0] = px[a, b]
        bp[a, b] = (0, 0, 0, 0)
    # Fast unsichtbaren Schimmer (Alpha <= 10) im Rahmen ebenfalls entfernen
    for b in range(y0, y1):
        for a in range(x0, x1):
            if bp[a, b][3] <= 10:
                bp[a, b] = (0, 0, 0, 0)
    lay.save(ORDNER / f"{name}-{teil}.webp", "WEBP", quality=90, method=6)
    basis.save(ORDNER / f"{name}-basis.webp", "WEBP", quality=84, method=6)

    print(f"Gesamtbild {w}×{h}")
    print(f"{teil}: left {100 * x0 / w:.3f}%  top {100 * y0 / h:.3f}%  width {100 * (x1 - x0) / w:.3f}%")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))
