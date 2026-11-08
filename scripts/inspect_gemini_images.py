import os
from PIL import Image

p = "assets/store/screenshots/phone"
files = [f for f in os.listdir(p) if f.startswith("Gemini")]
for f in files:
    full = os.path.join(p, f)
    im = Image.open(full)
    sz_mb = os.path.getsize(full) / (1024 * 1024)
    print(f"{f}: {im.size[0]}x{im.size[1]} ({im.format}), {sz_mb:.2f} MB, aspect={im.size[0]/im.size[1]:.4f}")

