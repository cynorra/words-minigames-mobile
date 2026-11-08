import os
import shutil
from PIL import Image

raw_dir = "assets/store/raw_gemini"
os.makedirs(raw_dir, exist_ok=True)

phone_dir = "assets/store/screenshots/phone"
tab7_dir = "assets/store/screenshots/tablet_7in"
tab10_dir = "assets/store/screenshots/tablet_10in"

for d in [tab7_dir, tab10_dir]:
    os.makedirs(d, exist_ok=True)

# List raw gemini images
gemini_files = sorted([f for f in os.listdir(phone_dir) if f.startswith("Gemini")])
print(f"Found {len(gemini_files)} Gemini images:")

# Backup to raw_gemini
for f in gemini_files:
    src = os.path.join(phone_dir, f)
    dst = os.path.join(raw_dir, f)
    shutil.copy2(src, dst)
print("Backed up raw images to assets/store/raw_gemini/")

# Map to clean names
# 11:20:
# Gemini_Generated_Image_8k7w0r8k7w0r8k7w.jpe
# Gemini_Generated_Image_h9vfuwh9vfuwh9vf.jpe
# Gemini_Generated_Image_p0d4xzp0d4xzp0d4.jpe
# 11:23:
# Gemini_Generated_Image_857ybi857ybi857y.jpe
# 11:24:
# Gemini_Generated_Image_kl575zkl575zkl57.jpe (Flag Quiz)

# Let's inspect each image to match the right name:
# We know kl57 is Flag Quiz (requested at 11:22).
# Let's check the others:
# 8k7w, h9vf, p0d4, 857y
# One is Hub/Collection, one is Wordle, one is Aim Trainer, one is Tic Tac Toe.

def crop_to_exact_9_16(im):
    w, h = im.size
    target_ratio = 9.0 / 16.0
    current_ratio = w / h
    
    if current_ratio < target_ratio:
        # Too tall, crop top/bottom
        target_h = int(w / target_ratio)
        diff = h - target_h
        top = diff // 2
        bottom = top + target_h
        return im.crop((0, top, w, bottom))
    elif current_ratio > target_ratio:
        # Too wide, crop left/right
        target_w = int(h * target_ratio)
        diff = w - target_w
        left = diff // 2
        right = left + target_w
        return im.crop((left, 0, right, h))
    return im

names = [
    "01_collection",
    "02_word_guess",
    "03_aim_trainer",
    "04_tictactoe",
    "05_flags_trivia"
]

# Order files so kl575 is 05_flags_trivia
# Let's list non-kl575 first
other_files = [f for f in gemini_files if not f.startswith("Gemini_Generated_Image_kl575")]
flag_file = [f for f in gemini_files if f.startswith("Gemini_Generated_Image_kl575")][0]

ordered_files = other_files + [flag_file]

# Process and save
for idx, f in enumerate(ordered_files):
    src = os.path.join(raw_dir, f)
    im = Image.open(src)
    cropped_9_16 = crop_to_exact_9_16(im)
    
    # 1. Phone (1080 x 1920)
    phone_res = cropped_9_16.resize((1080, 1920), Image.Resampling.LANCZOS)
    p_name = f"{names[idx]}_phone_1080x1920.png"
    p_out = os.path.join(phone_dir, p_name)
    phone_res.save(p_out, "PNG", optimize=True)
    
    # 2. Tablet 7 (1080 x 1920)
    t7_name = f"{names[idx]}_tablet7_1080x1920.png"
    t7_out = os.path.join(tab7_dir, t7_name)
    phone_res.save(t7_out, "PNG", optimize=True)
    
    # 3. Tablet 10 (1080 x 1920)
    t10_name = f"{names[idx]}_tablet10_1080x1920.png"
    t10_out = os.path.join(tab10_dir, t10_name)
    phone_res.save(t10_out, "PNG", optimize=True)
    
    print(f"[{idx+1}/5] Converted {f} -> {p_name} ({phone_res.size[0]}x{phone_res.size[1]} PNG, {os.path.getsize(p_out)/1024:.1f} KB)")

# Remove original .jpe from phone_dir to keep it clean (already backed up in raw_dir)
for f in gemini_files:
    p = os.path.join(phone_dir, f)
    if os.path.exists(p):
        os.remove(p)

print("\nAll Phone, 7-inch Tablet, and 10-inch Tablet screenshots successfully generated!")

