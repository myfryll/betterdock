#!/usr/bin/env python3
"""Compose the BetterDock Quattro promotional banner from the real dock capture."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parent
WALLPAPER = Path("/home/myfryll/.config/omarchy/backgrounds/tokyo-night/quattro.png")
DOCK_CAPTURE = Path("/tmp/dock_isolated.png")
OUTPUT = ROOT / "preview_candidate.png"
SIZE = (1920, 1080)
MONO_BOLD = "/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Bold.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    name = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    return ImageFont.truetype(f"/usr/share/fonts/TTF/{name}", size)


def mono_bold(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(MONO_BOLD, size)


def add_soft_ellipse(canvas: Image.Image, box, color, blur: int) -> None:
    layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(box, fill=color)
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


# The original wallpaper is exactly 16:9. Cover resampling keeps the entire
# Quattro composition and makes this work if the wallpaper size changes later.
with Image.open(WALLPAPER) as source:
    background = ImageOps.fit(source.convert("RGB"), SIZE, Image.Resampling.LANCZOS)
background = ImageEnhance.Contrast(background).enhance(1.09)
background = ImageEnhance.Color(background).enhance(0.93)
canvas = background.convert("RGBA")

# Soft darkening at both edges keeps the bright sunset while supporting text.
veil = Image.new("RGBA", SIZE, (0, 0, 0, 0))
veil_draw = ImageDraw.Draw(veil)
for y in range(SIZE[1]):
    top = max(0, 1 - y / 520) ** 1.7
    bottom = max(0, (y - 580) / 500) ** 1.55
    alpha = round(120 * top + 103 * bottom + 10)
    veil_draw.line((0, y, SIZE[0], y), fill=(7, 9, 23, min(alpha, 200)))
canvas.alpha_composite(veil)

# A quiet extra wash behind the wordmark protects the letterforms without a card.
header_wash = Image.new("RGBA", SIZE, (0, 0, 0, 0))
ImageDraw.Draw(header_wash).ellipse((-560, -290, 1080, 680), fill=(7, 10, 29, 74))
canvas.alpha_composite(header_wash.filter(ImageFilter.GaussianBlur(150)))

draw = ImageDraw.Draw(canvas)

# Restrained edition marker and a simple, prominent wordmark.
badge = (118, 44, 471, 90)
draw.rounded_rectangle(badge, radius=23, fill=(16, 21, 42, 198), outline=(174, 191, 248, 122), width=1)
draw.ellipse((137, 64, 145, 72), fill=(158, 186, 255, 255))
draw.text((157, 58), "OMARCHY QUATTRO EDITION", font=mono_bold(15), fill=(223, 231, 255, 255))

wordmark_font = mono_bold(91)
wordmark_x, wordmark_y = 113, 105
dock_word_x = wordmark_x + round(draw.textlength("Better", font=wordmark_font))

# A faint blue bloom gives the accent depth while the final text stays crisp.
wordmark_glow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
ImageDraw.Draw(wordmark_glow).text(
    (dock_word_x, wordmark_y), "Dock", font=wordmark_font, fill=(118, 198, 255, 105)
)
canvas.alpha_composite(wordmark_glow.filter(ImageFilter.GaussianBlur(17)))
draw = ImageDraw.Draw(canvas)
draw.text((wordmark_x, wordmark_y), "Better", font=wordmark_font, fill=(249, 251, 255, 255))
draw.text((dock_word_x, wordmark_y), "Dock", font=wordmark_font, fill=(169, 220, 255, 255))
draw.rounded_rectangle((119, 220, 176, 225), radius=2, fill=(169, 220, 255, 245))
draw.text((119, 232), "By myfryll", font=font(23), fill=(221, 231, 255, 255))
draw.text((119, 255), "A theme-integrated application dock for Omarchy", font=font(25), fill=(242, 245, 255, 255))

# Lift just the captured capsule; the tiny surrounding wallpaper strip is
# removed with a rounded alpha mask. Icons and active dots remain untouched.
with Image.open(DOCK_CAPTURE) as captured:
    dock = captured.convert("RGBA").crop((86, 16, 614, 84))
mask = Image.new("L", dock.size, 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, dock.width - 1, dock.height - 1), radius=13, fill=255)
dock.putalpha(mask)
dock_scale = 1.95
dock = dock.resize(
    (round(dock.width * dock_scale), round(dock.height * dock_scale)),
    Image.Resampling.LANCZOS,
)

dx = (SIZE[0] - dock.width) // 2
dy = SIZE[1] - dock.height - 26
add_soft_ellipse(
    canvas,
    (dx - 85, dy - 30, dx + dock.width + 85, dy + dock.height + 48),
    (125, 153, 255, 82),
    62,
)
add_soft_ellipse(
    canvas,
    (dx + 45, dy + dock.height - 31, dx + dock.width - 45, dy + dock.height + 44),
    (8, 5, 28, 178),
    29,
)

shadow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
ImageDraw.Draw(shadow).rounded_rectangle(
    (dx + 5, dy + 18, dx + dock.width - 5, dy + dock.height + 20),
    radius=26,
    fill=(1, 2, 13, 178),
)
canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(25)))
canvas.alpha_composite(dock, (dx, dy))

# One fine edge highlight makes the screenshot capsule read clearly at banner size.
draw = ImageDraw.Draw(canvas)
draw.rounded_rectangle(
    (dx, dy, dx + dock.width - 1, dy + dock.height - 1),
    radius=26,
    outline=(169, 188, 255, 88),
    width=2,
)

canvas.convert("RGB").save(OUTPUT, optimize=True)
print(f"Created {OUTPUT} ({SIZE[0]}x{SIZE[1]})")
