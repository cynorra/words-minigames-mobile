import os
import shutil
from PIL import Image

src = "assets/store/Gemini_Generated_Image_mtjjjtmtjjjtmtjj.jpe"
raw_dir = "assets/store/raw_gemini"
os.makedirs(raw_dir, exist_ok=True)
shutil.copy2(src, os.path.join(raw_dir, os.path.basename(src)))

im = Image.open(src).convert("RGBA")

# 1. 512x512 Store Icon (Google Play Console)
icon_512 = im.resize((512, 512), Image.Resampling.LANCZOS)
store_icon_png = "assets/store/icon_512.png"
store_icon_jpg = "assets/store/icon_512.jpg"

icon_512.save(store_icon_png, "PNG", optimize=True)
icon_512.convert("RGB").save(store_icon_jpg, "JPEG", quality=95)

# Also copy to artifacts dir
art_path = "C:/Users/erens/.gemini/antigravity/brain/5a8d657f-cd1f-4610-84a6-e55c14c612c2/icon_512.png"
shutil.copy2(store_icon_png, art_path)

# 2. 1024x1024 In-App Launcher Icon
icon_1024 = im.resize((1024, 1024), Image.Resampling.LANCZOS)
launcher_icon_path = "assets/icon/cynnora_icon.png"
icon_1024.save(launcher_icon_path, "PNG", optimize=True)

# Clean up raw .jpe files in store and phone
for p in ["assets/store/Gemini_Generated_Image_mtjjjtmtjjjtmtjj.jpe", "assets/store/screenshots/phone/Gemini_Generated_Image_mtjjjtmtjjjtmtjj.jpe"]:
    if os.path.exists(p):
        os.remove(p)

print(f"Generated Play Store Icon: {store_icon_png} ({os.path.getsize(store_icon_png)/1024:.1f} KB)")
print(f"Generated Play Store Icon (JPG): {store_icon_jpg} ({os.path.getsize(store_icon_jpg)/1024:.1f} KB)")
print(f"Updated App Launcher Icon: {launcher_icon_path} ({os.path.getsize(launcher_icon_path)/1024:.1f} KB)")

