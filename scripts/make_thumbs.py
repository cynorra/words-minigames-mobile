import os
from PIL import Image

p = "assets/store/screenshots/phone"
files = sorted([f for f in os.listdir(p) if f.startswith("Gemini")])

for idx, f in enumerate(files):
    full = os.path.join(p, f)
    im = Image.open(full)
    # create small thumbnail to copy to artifact dir so we can reference
    thumb = im.resize((300, int(300 * im.size[1] / im.size[0])), Image.Resampling.LANCZOS)
    art_path = f"C:/Users/erens/.gemini/antigravity/brain/5a8d657f-cd1f-4610-84a6-e55c14c612c2/thumb_{idx}_{f}.jpg"
    thumb.convert("RGB").save(art_path, "JPEG", quality=85)
    print(f"Index {idx+1}: {f} -> thumb saved")

