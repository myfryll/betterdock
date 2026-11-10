#!/usr/bin/env python3
"""Create a 1920 × 1080 BetterDock promotional banner with Pillow.

Run from anywhere: python create_banner.py
The banner is saved beside this script as preview_banner.png.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "preview_banner.png"
SOURCE = ROOT / "preview.png"
W, H = 1920, 1080


def font(size, bold=False, mono=False):
    if mono:
        names = ["/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf"]
    elif bold:
        names = [
            "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        ]
    else:
        names = [
            "/usr/share/fonts/TTF/DejaVuSans.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        ]
    for name in names:
        if Path(name).exists():
            return ImageFont.truetype(name, size)
    return ImageFont.load_default(size=size)


def rounded(im, box, radius, fill, outline=None, width=1):
    ImageDraw.Draw(im).rounded_rectangle(box, radius, fill=fill, outline=outline, width=width)


def glow(im, box, color, blur=90):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(box, fill=color)
    im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def shadow(im, box, radius=28, blur=40, offset=(0, 28), alpha=105):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    b = tuple(v + offset[i % 2] for i, v in enumerate(box))
    ImageDraw.Draw(layer).rounded_rectangle(b, radius, fill=(0, 0, 0, alpha))
    im.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def line(draw, xy, fill, width=1):
    draw.line(xy, fill=fill, width=width)


def text(draw, xy, value, size, color, bold=False, mono=False, spacing=4):
    draw.multiline_text(xy, value, font=font(size, bold, mono), fill=color, spacing=spacing)


# Deep ink background with a faint blue gradient and quiet technical grid.
im = Image.new("RGBA", (W, H), "#080d1a")
d = ImageDraw.Draw(im)
for y in range(H):
    t = y / H
    d.line((0, y, W, y), fill=(int(9 + 5 * t), int(14 + 7 * t), int(28 + 15 * t), 255))
glow(im, (1130, 20, 2230, 830), (59, 95, 210, 54), 150)
glow(im, (1090, 365, 1960, 1120), (105, 59, 184, 32), 145)
glow(im, (-490, 545, 590, 1520), (32, 101, 157, 24), 150)
d = ImageDraw.Draw(im)
for x in range(48, W, 80):
    line(d, (x, 0, x, H), (26, 38, 63, 255))
for y in range(40, H, 80):
    line(d, (0, y, W, y), (26, 38, 63, 255))

# Top wordmark and slim framing rules.
rounded(im, (115, 91, 167, 143), 14, (86, 119, 248, 255))
d = ImageDraw.Draw(im)
for cx, cy in [(130, 106), (146, 106), (130, 122), (146, 122)]:
    d.rounded_rectangle((cx, cy, cx + 7, cy + 7), 2, fill="#eaf0ff")
text(d, (183, 98), "betterdock", 28, "#f4f6ff", bold=True)
text(d, (1678, 105), "BY MYFRYLL", 17, "#9aa7c1", mono=True)
line(d, (115, 172, 1805, 172), (55, 70, 107, 255))

# Main message.
rounded(im, (116, 239, 320, 279), 20, (28, 44, 88, 255), (61, 85, 151, 255))
d = ImageDraw.Draw(im)
text(d, (135, 250), "FOR OMARCHY", 15, "#a8baff", mono=True)
text(d, (104, 325), "Your desktop,", 83, "#f5f7ff", bold=True)
text(d, (104, 423), "in flow.", 87, "#9db7ff", bold=True)
line(d, (117, 558, 191, 558), (120, 151, 255, 255), 5)
text(d, (116, 599), "A refined dock that feels right at home", 27, "#c3ccdf")
text(d, (116, 640), "in your workspace.", 27, "#c3ccdf")

# Feature pills remain concise and readable at thumbnail size.
pill_data = [
    (116, 742, 311, "THEME AWARE"),
    (327, 742, 527, "SMART AUTO-HIDE"),
    (543, 742, 737, "INSTANT SEARCH"),
]
for x1, y1, x2, label in pill_data:
    rounded(im, (x1, y1, x2, y1 + 48), 24, (27, 37, 62, 255), (54, 72, 112, 255))
    dd = ImageDraw.Draw(im)
    dd.ellipse((x1 + 17, y1 + 19, x1 + 25, y1 + 27), fill="#8eabff")
    text(dd, (x1 + 35, y1 + 16), label, 13, "#bfcbed", mono=True)

# The showcase is a desktop-inspired glass card. The actual project preview
# is used in its lower section so the dock appearance stays faithful.
card = (891, 227, 1805, 853)
shadow(im, card, 36, 55, (0, 35), 145)
rounded(im, card, 36, (18, 26, 47, 247), (115, 146, 225, 95), 2)
show = Image.new("RGBA", (W, H), (0, 0, 0, 0))
sd = ImageDraw.Draw(show)
sd.rounded_rectangle((907, 243, 1789, 837), 27, fill=(17, 25, 43, 255))
sd.rounded_rectangle((928, 264, 1768, 815), 21, fill=(22, 31, 52, 255))
# Abstract wallpaper: soft horizon and mountain silhouettes.
for y in range(264, 815):
    t = (y - 264) / 551
    sd.line((928, y, 1768, y), fill=(int(27 + 13 * t), int(40 + 18 * t), int(69 + 28 * t), 255))
sd.ellipse((1350, 292, 1810, 752), fill=(35, 51, 85, 255))
sd.polygon([(928, 680), (1110, 465), (1230, 596), (1415, 400), (1610, 653), (1768, 490), (1768, 815), (928, 815)], fill=(22, 34, 58, 255))
sd.polygon([(928, 750), (1150, 570), (1350, 735), (1600, 544), (1768, 690), (1768, 815), (928, 815)], fill=(17, 27, 48, 255))
im.alpha_composite(show)

# Small glass window adds scale and suggests the dock's desktop context.
shadow(im, (1020, 330, 1667, 611), 23, 25, (0, 15), 105)
rounded(im, (1020, 330, 1667, 611), 23, (17, 24, 41, 236), (159, 181, 232, 75))
d = ImageDraw.Draw(im)
for cx, col in [(1052, "#ff6b85"), (1077, "#f4bb65"), (1102, "#6ed5b7")]:
    d.ellipse((cx, 351, cx + 11, 362), fill=col)
text(d, (1254, 347), "WORKSPACE", 12, "#8b9ab8", mono=True)
line(d, (1021, 383, 1666, 383), (48, 59, 86, 255))
text(d, (1054, 421), "Everything in reach.", 32, "#ecf1ff", bold=True)
text(d, (1055, 470), "Apps when you need them.", 17, "#a5b2cd")
rounded(im, (1054, 526, 1210, 566), 12, (81, 116, 238, 230))
d = ImageDraw.Draw(im)
text(d, (1073, 536), "OPEN APP GRID", 12, "#eef2ff", mono=True)
for x in (1497, 1531, 1565):
    d.rounded_rectangle((x, 520, x + 22, 542), 6, fill=(91, 112, 165, 95))

if SOURCE.exists():
    with Image.open(SOURCE) as src:
        src = src.convert("RGBA")
        # Crop off the empty top strip and keep the real dock plus wallpaper.
        src = src.crop((0, 55, 800, 180)).resize((800, 125), Image.Resampling.LANCZOS)
        im.alpha_composite(src, (948, 682))
else:
    # The script remains useful if the README screenshot is unavailable.
    rounded(im, (1003, 711, 1693, 791), 15, (27, 33, 52, 245), (120, 147, 228, 110))
    dd = ImageDraw.Draw(im)
    for i, col in enumerate(["#b4bce3", "#a895ed", "#66cbad", "#eaae84", "#6eafff", "#d78ac5", "#9fc8ef"]):
        x = 1040 + i * 89
        dd.rounded_rectangle((x, 729, x + 42, 771), 10, fill=col)

# A precise halo and callout point to the actual dock.
d = ImageDraw.Draw(im)
line(d, (1492, 827, 1645, 910), (112, 149, 246, 170), 2)
d.ellipse((1485, 820, 1499, 834), fill="#a1b6ff")
text(d, (1657, 900), "BETTERDOCK", 16, "#b8c8ff", mono=True)

# Footer balances the large visual without competing with the headline.
line(d, (115, 931, 1805, 931), (55, 70, 107, 255))
text(d, (116, 963), "A LITTLE MORE BEAUTY IN EVERY WORKSPACE.", 16, "#7f8ba8", mono=True)
text(d, (1675, 963), "2026  /  01", 15, "#7f8ba8", mono=True)

im.convert("RGB").save(OUT, optimize=True)
print(f"Created {OUT} ({W}x{H})")
