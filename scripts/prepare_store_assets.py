import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

os.makedirs("assets/store", exist_ok=True)

print("--- Checking Screenshots in assets/ss ---")
ss_files = [f for f in os.listdir("assets/ss") if f.endswith(".png")]
for f in ss_files:
    p = os.path.join("assets/ss", f)
    im = Image.open(p)
    size_kb = os.path.getsize(p) / 1024
    print(f"{f}: {im.size[0]}x{im.size[1]} ({im.format}), {size_kb:.1f} KB")

# 1. Generate 512x512 App Icon
icon_src = "assets/icon/cynnora_icon.png"
if os.path.exists(icon_src):
    icon_im = Image.open(icon_src).convert("RGBA")
    icon_512 = icon_im.resize((512, 512), Image.Resampling.LANCZOS)
    icon_out = "assets/store/icon_512.png"
    icon_512.save(icon_out, "PNG", optimize=True)
    print(f"\nGenerated 512x512 icon: {icon_out} ({os.path.getsize(icon_out)/1024:.1f} KB)")

# 2. Generate 1024x500 Feature Graphic
fg_width, fg_height = 1024, 500
bg = Image.new("RGBA", (fg_width, fg_height), (15, 23, 42, 255)) # Dark slate (#0f172a)

# Add subtle gradient or glows
draw = ImageDraw.Draw(bg)
for r in range(400, 0, -20):
    alpha = int(25 * (1 - r / 400))
    draw.ellipse((fg_width//2 - r, fg_height//2 - r, fg_width//2 + r, fg_height//2 + r), fill=(99, 102, 241, alpha))

# Let's paste some 3D game icons floating on the sides
icons_to_place = [
    ("assets/icon/joystick.png", (60, 90), 160),
    ("assets/icon/target.png", (140, 270), 140),
    ("assets/icon/tic-tac-toe.png", (50, 310), 110),
    ("assets/icon/winner.png", (800, 70), 170),
    ("assets/icon/memory-game.png", (730, 260), 140),
    ("assets/icon/rock-paper-scissors.png", (840, 300), 130),
    ("assets/icon/cynnora_icon.png", (fg_width//2 - 75, 50), 150),
]

for icon_path, pos, sz in icons_to_place:
    if os.path.exists(icon_path):
        ic = Image.open(icon_path).convert("RGBA")
        ic = ic.resize((sz, sz), Image.Resampling.LANCZOS)
        bg.paste(ic, pos, ic)

# Text placement
# Try loading a system font or default
font_title = None
font_sub = None
for font_name in ["arialbd.ttf", "segoeuib.ttf", "verdana.ttf"]:
    try:
        font_title = ImageFont.truetype(font_name, 52)
        font_sub = ImageFont.truetype(font_name.replace("bd", "").replace("b", ""), 26)
        break
    except Exception:
        pass

if font_title is None:
    font_title = ImageFont.load_default()
    font_sub = ImageFont.load_default()

title_text = "Words & Brain Mini Games"
sub_text = "13 Brain Training, Puzzle & Logic Games in One!"

# Draw title with subtle shadow
t_bbox = draw.textbbox((0, 0), title_text, font=font_title)
t_w = t_bbox[2] - t_bbox[0]
t_x = (fg_width - t_w) // 2
t_y = 220

# Shadow
draw.text((t_x + 2, t_y + 2), title_text, font=font_title, fill=(0, 0, 0, 180))
# Text
draw.text((t_x, t_y), title_text, font=font_title, fill=(255, 255, 255, 255))

# Subtitle
s_bbox = draw.textbbox((0, 0), sub_text, font=font_sub)
s_w = s_bbox[2] - s_bbox[0]
s_x = (fg_width - s_w) // 2
s_y = 290

draw.text((s_x + 1, s_y + 1), sub_text, font=font_sub, fill=(0, 0, 0, 160))
draw.text((s_x, s_y), sub_text, font=font_sub, fill=(199, 210, 254, 255)) # Light indigo

# Badge pill: "Play Offline • Global Leaderboard • Daily Brain Challenge"
badge_text = "★ 100% Free • Offline Play • Global Leaderboard ★"
badge_bbox = draw.textbbox((0, 0), badge_text, font=font_sub)
b_w = badge_bbox[2] - badge_bbox[0]
b_x = (fg_width - b_w) // 2
b_y = 360

draw.rounded_rectangle((b_x - 20, b_y - 6, b_x + b_w + 20, b_y + badge_bbox[3] - badge_bbox[1] + 8), radius=16, fill=(30, 41, 59, 220), outline=(99, 102, 241, 200), width=2)
draw.text((b_x, b_y), badge_text, font=font_sub, fill=(253, 224, 71, 255)) # Amber yellow

fg_out = "assets/store/feature_graphic_1024x500.png"
bg.convert("RGB").save(fg_out, "PNG", optimize=True)
print(f"Generated Feature Graphic: {fg_out} ({os.path.getsize(fg_out)/1024:.1f} KB)")

