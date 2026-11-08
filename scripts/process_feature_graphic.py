import os
import shutil
from PIL import Image

src = "assets/store/Gemini_Generated_Image_btkrd5btkrd5btkr.jpe"
raw_dir = "assets/store/raw_gemini"
os.makedirs(raw_dir, exist_ok=True)
shutil.copy2(src, os.path.join(raw_dir, os.path.basename(src)))

im = Image.open(src)
w, h = im.size
target_w, target_h = 1024, 500
target_ratio = target_w / target_h # 2.048

# To get 2.048 ratio without distortion:
# crop height from 1536 to int(2752 / 2.048) = 1344
crop_h = int(w / target_ratio)
diff_y = h - crop_h
top = diff_y // 2
bottom = top + crop_h

cropped = im.crop((0, top, w, bottom))
feature_1024x500 = cropped.resize((target_w, target_h), Image.Resampling.LANCZOS)

out_png = "assets/store/feature_graphic_1024x500.png"
feature_1024x500.save(out_png, "PNG", optimize=True)

out_jpg = "assets/store/feature_graphic_1024x500.jpg"
feature_1024x500.convert("RGB").save(out_jpg, "JPEG", quality=95)

# Also copy to artifacts dir so user can view thumbnail
art_path = "C:/Users/erens/.gemini/antigravity/brain/5a8d657f-cd1f-4610-84a6-e55c14c612c2/feature_graphic_1024x500.png"
shutil.copy2(out_png, art_path)

print(f"Generated: {out_png} ({os.path.getsize(out_png)/1024:.1f} KB)")
print(f"Generated: {out_jpg} ({os.path.getsize(out_jpg)/1024:.1f} KB)")

