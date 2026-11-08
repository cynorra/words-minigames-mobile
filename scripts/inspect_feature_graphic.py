import os
from PIL import Image

f = "assets/store/Gemini_Generated_Image_btkrd5btkrd5btkr.jpe"
im = Image.open(f)
sz_mb = os.path.getsize(f) / (1024 * 1024)
print(f"File: {f}")
print(f"Size: {im.size[0]}x{im.size[1]} ({im.format}), {sz_mb:.2f} MB")
print(f"Aspect Ratio: {im.size[0] / im.size[1]:.4f} (Target 1024/500 = {1024/500:.4f})")

