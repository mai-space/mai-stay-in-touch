"""Erzeugt das App-Icon (Android, iOS) aus einer Vorlage.

    pip install cairosvg pillow && python3 tool/generate_icons.py

Motiv: weißer Telefonhörer mit zwei Rufwellen auf dem grünen Markenverlauf —
gleiche Bildsprache wie die anderen Mai-Apps.
"""

import io
import json
from pathlib import Path

import cairosvg

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android/app/src/main/res"

SEED = "#2E7D5B"
ACCENT = "#5DBB8E"

# 108×108 = Android-Adaptive-Icon-Raster; Motiv bleibt in der 66er-Schutzzone.
# Material-Symbole „call“ und Rufwellen (24er-Raster), mittig auf 42 Einheiten.
PHONE = """
  <g transform="translate(54 54) scale(1.75) translate(-12 -12)" fill="{c}">
    <path d="M6.62,10.79c1.44,2.83 3.76,5.14 6.59,6.59l2.2,-2.2c0.27,-0.27 0.67,-0.36 1.02,-0.24 1.12,0.37 2.33,0.57 3.57,0.57 0.55,0 1,0.45 1,1V20c0,0.55 -0.45,1 -1,1 -9.39,0 -17,-7.61 -17,-17 0,-0.55 0.45,-1 1,-1h3.5c0.55,0 1,0.45 1,1 0,1.25 0.2,2.45 0.57,3.57 0.11,0.35 0.03,0.74 -0.25,1.02l-2.2,2.2z"/>
    <path d="M15,12h2c0,-2.76 -2.24,-5 -5,-5v2c1.66,0 3,1.34 3,3zM19,12h2c0,-4.97 -4.03,-9 -9,-9v2c3.87,0 7,3.13 7,7z"/>
  </g>
"""
BACKGROUND = f"""
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{ACCENT}"/>
      <stop offset="1" stop-color="{SEED}"/>
    </linearGradient>
  </defs>
"""


def svg(body, view="0 0 108 108"):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}">{body}</svg>'
    )


MOTIF = PHONE.format(c="#fff")
FOREGROUND = svg(MOTIF)
# Volles Bild (Legacy-Icon): abgerundetes Quadrat + Motiv.
ROUNDED = svg(
    BACKGROUND
    + '<rect x="14" y="14" width="80" height="80" rx="20" fill="url(#bg)"/>'
    + MOTIF,
    view="14 14 80 80",
)
# iOS: vollflächig, engerer Ausschnitt (keine 66er-Schutzzone nötig).
IOS = svg(
    BACKGROUND + '<rect width="108" height="108" fill="url(#bg)"/>' + MOTIF,
    view="20 20 68 68",
)


def png(source, path, size):
    path.parent.mkdir(parents=True, exist_ok=True)
    cairosvg.svg2png(
        bytestring=source.encode(),
        write_to=str(path),
        output_width=size,
        output_height=size,
    )


def ios_icons():
    """iOS-AppIcon ohne Alphakanal (App Store lehnt Transparenz ab)."""
    from PIL import Image

    folder = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((folder / "Contents.json").read_text())
    for image in contents["images"]:
        name = image.get("filename")
        if not name:
            continue
        points = float(image["size"].split("x")[0])
        size = round(points * int(image["scale"].rstrip("x")))
        data = cairosvg.svg2png(
            bytestring=IOS.encode(), output_width=size, output_height=size
        )
        rgba = Image.open(io.BytesIO(data)).convert("RGBA")
        flat = Image.new("RGB", rgba.size, SEED)
        flat.paste(rgba, mask=rgba.split()[3])
        flat.save(folder / name, optimize=True)


def watch_icon():
    """watchOS-AppIcon (1024, ohne Alpha; das System schneidet rund aus)."""
    from PIL import Image

    path = ROOT / "ios/Watch/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    data = cairosvg.svg2png(bytestring=IOS.encode(), output_width=1024, output_height=1024)
    rgba = Image.open(io.BytesIO(data)).convert("RGBA")
    flat = Image.new("RGB", rgba.size, SEED)
    flat.paste(rgba, mask=rgba.split()[3])
    flat.save(path, optimize=True)


def main():
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, factor in densities.items():
        folder = RES / f"mipmap-{name}"
        png(ROUNDED, folder / "ic_launcher.png", round(48 * factor))
        png(FOREGROUND, folder / "ic_launcher_foreground.png", round(108 * factor))
        # Themed Icons (Android 13+) nutzen nur Alpha: der Hörer selbst.
        png(FOREGROUND, folder / "ic_launcher_monochrome.png", round(108 * factor))
    ios_icons()
    watch_icon()


if __name__ == "__main__":
    main()
