"""Zerlegt das Hero-Bild in Ebenen für die Animation (Sonne, Drache).

Eingang:  bilder-roh/hero.png  (Original mit Transparenz, 1374×1145)
Ausgang:  assets/img/illustrations/hero-basis.webp      – Szene ohne Sonne und Drachen
          assets/img/illustrations/hero-strahlen.webp   – Sonnenstrahlen (drehen sich)
          assets/img/illustrations/hero-gesicht.webp    – Sonnengesicht (pulsiert)
          assets/img/illustrations/hero-drache.webp     – Drache mit Schwänzen (wiegt sich)
Ausgabe der Positionen (in % des Gesamtbilds) für das CSS.

Aufruf:   python tools/hero_ebenen.py
"""

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
QUELLE = ROOT / "bilder-roh" / "hero.png"
ZIEL = ROOT / "assets" / "img" / "illustrations"

SONNE_MITTE = (315, 215)   # Mittelpunkt der Sonnenscheibe (px im Original)
SONNE_SCHEIBE = 116        # Radius Gesicht/Scheibe
SONNE_AUSSEN = 215         # bis hierhin zählen Teile zur Sonne
DRACHE_PIVOT = (1129, 327) # Schnittstelle der Schnur unter der 1. Schleife = Drehpunkt


def komponenten(maske, w, h, box):
    """Zusammenhängende Flächen (4er-Nachbarschaft) innerhalb box."""
    x0, y0, x1, y1 = box
    gesehen = set()
    for sy in range(y0, y1):
        for sx in range(x0, x1):
            if (sx, sy) in gesehen or not maske(sx, sy):
                continue
            teil, q = [], deque([(sx, sy)])
            gesehen.add((sx, sy))
            while q:
                x, y = q.popleft()
                teil.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if x0 <= nx < x1 and y0 <= ny < y1 and (nx, ny) not in gesehen and maske(nx, ny):
                        gesehen.add((nx, ny))
                        q.append((nx, ny))
            yield teil


def main():
    im = Image.open(QUELLE).convert("RGBA")
    w, h = im.size
    px = im.load()
    sichtbar = lambda x, y: px[x, y][3] > 10
    cx, cy = SONNE_MITTE

    # --- Sonne: alle Teile, deren Schwerpunkt nah an der Sonnenmitte liegt (Bäume/Wolke liegen weiter weg)
    box = (max(0, cx - SONNE_AUSSEN - 20), 0, min(w, cx + SONNE_AUSSEN + 20), min(h, cy + SONNE_AUSSEN + 20))
    sonne = []
    for teil in komponenten(sichtbar, w, h, box):
        mx = sum(p[0] for p in teil) / len(teil)
        my = sum(p[1] for p in teil) / len(teil)
        beruehrt_rand = any(p[1] >= box[3] - 1 for p in teil)
        if not beruehrt_rand and ((mx - cx) ** 2 + (my - cy) ** 2) ** 0.5 < SONNE_AUSSEN:
            sonne.extend(teil)
    gesicht = [p for p in sonne if (p[0] - cx) ** 2 + (p[1] - cy) ** 2 <= SONNE_SCHEIBE ** 2]
    strahlen = [p for p in sonne if (p[0] - cx) ** 2 + (p[1] - cy) ** 2 > SONNE_SCHEIBE ** 2]

    # --- Drache: alles oberhalb der Schnittstelle (inkl. 1. Schleife) + Schwänze rechts,
    #     ohne Wolke links und ohne die Schleifen der unteren Schnur
    ox = 950
    def im_drachen(x, y):
        lx = x - ox
        return lx > 120 and (y < DRACHE_PIVOT[1] or (x > 1235 and y < 400) or (x > 1250 and y < 415))
    drache = [(x, y) for y in range(0, 415) for x in range(ox, w) if im_drachen(x, y) and sichtbar(x, y)]

    def ebene(punkte, name):
        xs = [p[0] for p in punkte]; ys = [p[1] for p in punkte]
        b = (min(xs) - 2, min(ys) - 2, max(xs) + 3, max(ys) + 3)
        lay = Image.new("RGBA", (b[2] - b[0], b[3] - b[1]), (0, 0, 0, 0))
        lp = lay.load()
        for x, y in punkte:
            lp[x - b[0], y - b[1]] = px[x, y]
        lay.save(ZIEL / f"hero-{name}.webp", "WEBP", quality=88, method=6)
        return b

    boxen = {n: ebene(p, n) for n, p in (("strahlen", strahlen), ("gesicht", gesicht), ("drache", drache))}

    basis = im.copy()
    bp = basis.load()
    for x, y in sonne + drache:
        bp[x, y] = (0, 0, 0, 0)
    basis.save(ZIEL / "hero-basis.webp", "WEBP", quality=84, method=6)

    print(f"Gesamtbild {w}×{h}")
    for n, (x0, y0, x1, y1) in boxen.items():
        bw, bh = x1 - x0, y1 - y0
        extra = ""
        if n in ("strahlen", "gesicht"):
            extra = f"  origin {100 * (cx - x0) / bw:.2f}% {100 * (cy - y0) / bh:.2f}%"
        if n == "drache":
            extra = f"  origin {100 * (DRACHE_PIVOT[0] - x0) / bw:.2f}% {100 * (DRACHE_PIVOT[1] - y0) / bh:.2f}%"
        print(f"{n:9s} left {100 * x0 / w:.3f}%  top {100 * y0 / h:.3f}%  width {100 * bw / w:.3f}%{extra}")


if __name__ == "__main__":
    main()
