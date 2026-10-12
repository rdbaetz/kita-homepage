"""Bereitet generierte Illustrationen für die Website auf.

- Entfernt ein ins Bild "gemaltes" Transparenz-Karomuster (typisch für ChatGPT-Bilder):
  graue, ungesättigte Flächen, die mit dem Bildrand verbunden sind, werden transparent.
- Glättet die Kanten, beschneidet leere Ränder, verkleinert und speichert als WebP mit Transparenz.

Eingang:  bilder-roh/*.png         (Originale, nicht in Git)
Ausgang:  assets/img/illustrations/<name>.webp

Aufruf:   python tools/bilder_aufbereiten.py [name ...]
"""

import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
ROH = ROOT / "bilder-roh"
ZIEL = ROOT / "assets" / "img" / "illustrations"

MAX_BREITE = {"hero": 1400, "ueber-uns": 1200, "ueber-uns-2": 1200}  # alle anderen: 520 px (Icons)
SAETTIGUNG_MAX = 14       # max. Unterschied zwischen R, G, B für "grau"
HELL_MIN, HELL_MAX = 110, 215


def ist_karo(p):
    r, g, b = p[:3]
    return max(r, g, b) - min(r, g, b) <= SAETTIGUNG_MAX and HELL_MIN <= (r + g + b) / 3 <= HELL_MAX


def entferne_karo(im):
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
    bg = bytearray(w * h)
    q = deque()
    for x in range(w):
        q.extend(((x, 0), (x, h - 1)))
    for y in range(h):
        q.extend(((0, y), (w - 1, y)))
    while q:
        x, y = q.popleft()
        i = y * w + x
        if bg[i]:
            continue
        p = px[x, y]
        if p[3] != 0 and not ist_karo(p):
            continue
        bg[i] = 1
        if x > 0: q.append((x - 1, y))
        if x < w - 1: q.append((x + 1, y))
        if y > 0: q.append((x, y - 1))
        if y < h - 1: q.append((x, y + 1))

    # Eingeschlossene Karo-Flächen (z. B. Henkel, Ringmitte): zusammenhängende graue Bereiche,
    # in denen beide Karo-Töne (dunkel + hell) nennenswert vorkommen.
    besucht = bytearray(bg)
    for start in range(w * h):
        if besucht[start]:
            continue
        sx, sy = start % w, start // w
        if not ist_karo(px[sx, sy]):
            continue
        teil, dunkel, hell = [], 0, 0
        q = deque([(sx, sy)])
        besucht[start] = 1
        while q:
            x, y = q.popleft()
            teil.append(y * w + x)
            v = sum(px[x, y][:3]) / 3
            if v < 160: dunkel += 1
            else: hell += 1
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny * w + nx
                    if not besucht[j] and ist_karo(px[nx, ny]):
                        besucht[j] = 1
                        q.append((nx, ny))
        if len(teil) >= 300 and min(dunkel, hell) >= 0.25 * len(teil):
            for j in teil:
                bg[j] = 1

    maske = Image.frombytes("L", (w, h), bytes(0 if b else 255 for b in bg))
    # 1 px Saum entfernen (grauer Rand), dann weich auslaufen lassen
    maske = maske.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    im.putalpha(ImageChops.multiply(im.getchannel("A"), maske))
    return im


def verarbeite(datei):
    name = datei.stem
    im = Image.open(datei)
    hat_alpha = "A" in im.getbands() and im.getchannel("A").getextrema()[0] < 255
    im = im.convert("RGBA") if hat_alpha else entferne_karo(im)
    bbox = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    if bbox:
        rand = 8
        bbox = (max(0, bbox[0] - rand), max(0, bbox[1] - rand), min(im.width, bbox[2] + rand), min(im.height, bbox[3] + rand))
        im = im.crop(bbox)
    breite = MAX_BREITE.get(name, 520)
    if im.width > breite:
        im = im.resize((breite, round(im.height * breite / im.width)), Image.LANCZOS)
    ziel = ZIEL / f"{name}.webp"
    im.save(ziel, "WEBP", quality=84, method=6)
    print(f"{name}: {'Alpha vorhanden' if hat_alpha else 'Karo entfernt'} -> {ziel.name} {im.size} {ziel.stat().st_size // 1024} KB")


def main(namen):
    ZIEL.mkdir(parents=True, exist_ok=True)
    dateien = sorted(ROH.glob("*.png"))
    if namen:
        dateien = [d for d in dateien if d.stem in namen]
    for d in dateien:
        verarbeite(d)


if __name__ == "__main__":
    main(sys.argv[1:])
