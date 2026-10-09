#!/usr/bin/env python3
"""Generate Android launcher icons for Kaptan Asistani."""
import os
try:
    from PIL import Image, ImageDraw
except ImportError:
    import subprocess, sys
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow", "-q"])
    from PIL import Image, ImageDraw

def make(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m = int(size * 0.08)
    d.rounded_rectangle([m, m, size - m, size - m], radius=int(size * 0.22), fill=(6, 20, 31, 255))
    pad = int(size * 0.22)
    d.ellipse([pad, pad, size - pad, size - pad], outline=(61, 232, 240, 255), width=max(4, size // 40))
    cx = cy = size // 2
    s = size * 0.22
    ship = [(cx, cy - s), (cx + s * 0.72, cy + s * 0.82), (cx, cy + s * 0.45), (cx - s * 0.72, cy + s * 0.82)]
    d.polygon(ship, fill=(61, 232, 240, 255))
    return img

def make_fg(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = int(size * 0.18)
    d.ellipse([pad, pad, size - pad, size - pad], outline=(61, 232, 240, 255), width=max(4, size // 42))
    cx = cy = size // 2
    s = size * 0.22
    ship = [(cx, cy - s), (cx + s * 0.72, cy + s * 0.82), (cx, cy + s * 0.45), (cx - s * 0.72, cy + s * 0.82)]
    d.polygon(ship, fill=(61, 232, 240, 255))
    return img

os.makedirs("assets/icon", exist_ok=True)
make().save("assets/icon/app_icon.png")
make_fg().save("assets/icon/app_icon_fg.png")
print("icons written")
