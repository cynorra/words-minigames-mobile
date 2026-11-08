import os
from PIL import Image

p = "assets/store/screenshots/phone"
files = sorted([f for f in os.listdir(p) if f.startswith("Gemini")])

for f in files:
    full = os.path.join(p, f)
    im = Image.open(full)
    exif = im.getexif()
    # Check if there's any description or metadata
    desc = exif.get(0x010e) or exif.get(0x9286) or ""
    # Let's inspect dominant colors in regions
    # Sample top, middle, bottom
    top_crop = im.crop((0, 0, im.width, im.height//3)).resize((1, 1))
    mid_crop = im.crop((0, im.height//3, im.width, 2*im.height//3)).resize((1, 1))
    bot_crop = im.crop((0, 2*im.height//3, im.width, im.height)).resize((1, 1))
    print(f"{f}: top={top_crop.getpixel((0,0))}, mid={mid_crop.getpixel((0,0))}, bot={bot_crop.getpixel((0,0))}")

