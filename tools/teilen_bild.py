"""Erzeugt das Vorschaubild für geteilte Links (WhatsApp, Facebook, …).

Aufruf:  python tools/teilen_bild.py [ziel]
Ziel:    assets/img/teilen.jpg (Standard), 1200×630 px

Setzt die Hero-Illustration (Basis + Sonnenstrahlen + Sonnengesicht, Positionen wie
in .hero-szene in style.css), das Logo und den Slogan in den Schriften der Seite
zusammen. Braucht Pillow und fontTools (+ brotli) zum Lesen der .woff2-Schriften.
Bei geändertem Bild unter neuem Dateinamen speichern (Cache) und og:image anpassen.
"""
import io
import sys
from pathlib import Path

from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ILL = ROOT / "assets/img/illustrations"
ZIEL = ROOT / (sys.argv[1] if len(sys.argv) > 1 else "assets/img/teilen.jpg")

B, H = 1200, 630
CREME = "#f8f6ee"
GRUEN_100 = "#dfeccf"
GRUEN_700 = "#3d6648"
TINTE_SOFT = "#4a554c"

# Positionen der Sonnen-Ebenen in % des Gesamtbilds (aus style.css, .hero-szene)
EBENEN = [  # (Datei, left %, top %, width %, vor der Basis?)
    ("hero-3-strahlen.webp", 9.316, 0.873, 23.799, False),
    ("hero-3-gesicht.webp", 14.702, 7.424, 13.61, True),
]


def schrift(name, groesse, gewicht):
    """Lädt eine lokale variable .woff2-Schrift in der gewünschten Stärke."""
    tt = TTFont(ROOT / "assets/fonts" / name)
    tt.flavor = None
    puffer = io.BytesIO()
    tt.save(puffer)
    puffer.seek(0)
    f = ImageFont.truetype(puffer, groesse)
    f.set_variation_by_axes([gewicht])
    return f


def hero_szene():
    basis = Image.open(ILL / "hero-3-basis.webp").convert("RGBA")
    w, h = basis.size
    szene = Image.new("RGBA", basis.size, (0, 0, 0, 0))
    vorne = []
    for datei, left, top, width, davor in EBENEN:
        ebene = Image.open(ILL / datei).convert("RGBA")
        ew = round(w * width / 100)
        ebene = ebene.resize((ew, round(ebene.height * ew / ebene.width)), Image.LANCZOS)
        pos = (round(w * left / 100), round(h * top / 100))
        if davor:
            vorne.append((ebene, pos))
        else:
            szene.alpha_composite(ebene, pos)
    szene.alpha_composite(basis)
    for ebene, pos in vorne:
        szene.alpha_composite(ebene, pos)
    return szene


def main():
    bild = Image.new("RGBA", (B, H), CREME)

    # Weicher grüner Kreis hinter der Illustration (wie die Pastell-Kreise der Seite)
    kreis = Image.new("RGBA", (B, H), (0, 0, 0, 0))
    ImageDraw.Draw(kreis).ellipse((610, 40, 1250, 680), fill=GRUEN_100)
    bild.alpha_composite(kreis.filter(ImageFilter.GaussianBlur(2)))

    # Illustration rechts, unten bündig
    szene = hero_szene()
    sh = 600
    sw = round(szene.width * sh / szene.height)
    szene = szene.resize((sw, sh), Image.LANCZOS)
    bild.alpha_composite(szene, (B - sw + 10, H - sh))

    # Logo links oben
    logo = Image.open(ROOT / "assets/img/logo-gross.webp").convert("RGBA")
    lw = 400
    logo = logo.resize((lw, round(logo.height * lw / logo.width)), Image.LANCZOS)
    x0 = 56
    bild.alpha_composite(logo, (x0 - 8, 52))

    # Slogan als "Treppe" wie im Hero
    d = ImageDraw.Draw(bild)
    klein = schrift("nunito-latin-wght-normal.woff2", 30, 800)
    gross = schrift("fraunces-latin-wght-normal.woff2", 58, 600)
    y = 290
    d.text((x0, y), "Gemeinsam", font=klein, fill=TINTE_SOFT)
    y += 44
    for i, zeile in enumerate(["lernen,", "entdecken", "und wachsen"]):
        d.text((x0 + i * 22, y), zeile, font=gross, fill=GRUEN_700)
        y += 68

    unter = schrift("nunito-latin-wght-normal.woff2", 24, 700)
    d.text((x0, H - 58), "Krippe & Kindergarten in Neufang", font=unter, fill=TINTE_SOFT)

    ZIEL.parent.mkdir(parents=True, exist_ok=True)
    bild.convert("RGB").save(ZIEL, "JPEG", quality=86, optimize=True, progressive=True)
    print(f"{ZIEL.relative_to(ROOT)}: {B}×{H}, {ZIEL.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
