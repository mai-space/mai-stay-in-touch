"""Erzeugt App-Icon (512 × 512) und Feature-Grafik (1024 × 500) für den
Play Store unter store/android/.

    pip install cairosvg pillow && python3 tool/generate_store_graphics.py

Gleiches Motiv wie tool/generate_icons.py. Schrift: Roboto aus dem
Flutter-SDK (FLUTTER_ROOT oder `flutter` im PATH), sonst DejaVu Sans.
"""

import io
import os
import shutil
from pathlib import Path

import cairosvg
from PIL import Image, ImageDraw, ImageFont

from generate_icons import ACCENT, IOS, MOTIF, SEED, svg

ROOT = Path(__file__).resolve().parent.parent
STORE = ROOT / "store/android"

# Texte der Feature-Grafik je Sprache (passend zu den Store-Texten).
TEXTS = {
    "de": ("Ruf durch", "Jeden Tag ein Mensch zum Anrufen", "Lokal · ohne Konto · verschlüsselt"),
    "en": ("Ruf durch", "One person to call, every day", "Local · no account · encrypted"),
}


def font(weight):
    """Roboto aus dem Flutter-SDK, sonst eine Systemschrift."""
    root = os.environ.get("FLUTTER_ROOT")
    if not root and shutil.which("flutter"):
        root = str(Path(shutil.which("flutter")).resolve().parent.parent)
    if root:
        path = Path(root) / f"bin/cache/artifacts/material_fonts/Roboto-{weight}.ttf"
        if path.exists():
            return str(path)
    bold = "-Bold" if weight in ("Bold", "Black") else ""
    return f"/usr/share/fonts/truetype/dejavu/DejaVuSans{bold}.ttf"


def render(source, width, height):
    data = cairosvg.svg2png(
        bytestring=source.encode(), output_width=width, output_height=height
    )
    return Image.open(io.BytesIO(data)).convert("RGBA")


def icon():
    """512 × 512, vollflächig ohne Transparenz — Play rundet selbst ab."""
    rgba = render(IOS, 512, 512)
    flat = Image.new("RGB", rgba.size, SEED)
    flat.paste(rgba, mask=rgba.split()[3])
    flat.save(STORE / "icon-512.png", optimize=True)


def feature_graphic(lang):
    title, tagline, note = TEXTS[lang]
    w, h = 1024, 500
    background = render(
        f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">
          <defs>
            <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stop-color="{ACCENT}"/>
              <stop offset="1" stop-color="{SEED}"/>
            </linearGradient>
          </defs>
          <rect width="{w}" height="{h}" fill="url(#bg)"/>
          <circle cx="215" cy="250" r="150" fill="#fff" fill-opacity="0.14"/>
          <circle cx="215" cy="250" r="205" fill="none" stroke="#fff"
                  stroke-opacity="0.12" stroke-width="18"/>
        </svg>""",
        w,
        h,
    )
    # Hörer mit Rufwellen, weiß, links.
    phone = render(svg(MOTIF, view="27 27 54 54"), 210, 210)
    background.alpha_composite(phone, (110, 145))

    draw = ImageDraw.Draw(background)
    x = 440
    draw.text((x, 128), title, font=ImageFont.truetype(font("Bold"), 88), fill="white")
    draw.text(
        (x, 250), tagline, font=ImageFont.truetype(font("Medium"), 32), fill="white"
    )
    draw.text(
        (x, 310),
        note,
        font=ImageFont.truetype(font("Regular"), 28),
        fill=(255, 255, 255, 215),
    )
    out = STORE / lang / "feature-graphic.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    background.convert("RGB").save(out, optimize=True)


def main():
    STORE.mkdir(parents=True, exist_ok=True)
    icon()
    for lang in TEXTS:
        feature_graphic(lang)


if __name__ == "__main__":
    main()
