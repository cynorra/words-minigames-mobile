import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_phone_mockup(screen_img_path, target_width=720, target_height=1440, corner_radius=36):
    """
    Creates a modern 2026 smartphone mockup with slim bezel, glass glare,
    camera punch hole, and rounded corners.
    """
    # Open and resize screen image
    screen = Image.open(screen_img_path).convert("RGBA")
    
    # Calculate screen inner size
    inner_w = target_width - 24
    inner_h = target_height - 24
    screen_resized = screen.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    # Rounded mask for screen
    mask = Image.new("L", (inner_w, inner_h), 0)
    draw_mask = ImageDraw.Draw(mask)
    draw_mask.rounded_rectangle((0, 0, inner_w, inner_h), radius=corner_radius - 8, fill=255)
    
    # Phone frame (body)
    phone_body = Image.new("RGBA", (target_width, target_height), (0, 0, 0, 0))
    draw_body = ImageDraw.Draw(phone_body)
    
    # Outer dark titanium bezel
    draw_body.rounded_rectangle(
        (0, 0, target_width, target_height),
        radius=corner_radius,
        fill=(18, 22, 32, 255),
        outline=(55, 65, 81, 255),
        width=3
    )
    
    # Inner metallic bezel rim
    draw_body.rounded_rectangle(
        (6, 6, target_width - 6, target_height - 6),
        radius=corner_radius - 4,
        fill=(10, 14, 20, 255),
        outline=(99, 102, 241, 60),
        width=2
    )
    
    # Paste masked screen
    phone_body.paste(screen_resized, (12, 12), mask)
    
    # Add top punch-hole / dynamic island
    pill_w, pill_h = 100, 24
    pill_x = (target_width - pill_w) // 2
    draw_body.rounded_rectangle(
        (pill_x, 20, pill_x + pill_w, 20 + pill_h),
        radius=12,
        fill=(5, 5, 8, 255)
    )
    # Camera lens reflection
    draw_body.ellipse((pill_x + 16, 26, pill_x + 28, 38), fill=(20, 30, 60, 255))
    
    # Subtle diagonal glass reflection sheen
    sheen = Image.new("RGBA", (inner_w, inner_h), (0, 0, 0, 0))
    draw_sheen = ImageDraw.Draw(sheen)
    draw_sheen.polygon([(0, 0), (inner_w // 2, 0), (0, inner_h // 2)], fill=(255, 255, 255, 12))
    phone_body.paste(sheen, (12, 12), sheen)
    
    return phone_body

def add_drop_shadow(image, offset=(0, 30), blur=40, shadow_color=(0, 0, 0, 160)):
    """Creates a deep realistic drop shadow for an RGBA image."""
    total_w = image.width + blur * 4
    total_h = image.height + blur * 4 + abs(offset[1])
    
    shadow_canvas = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    alpha = image.split()[3]
    
    # Create colored shadow from alpha
    shadow = Image.new("RGBA", image.size, shadow_color)
    shadow.putalpha(alpha)
    
    shadow_pos = (blur * 2 + offset[0], blur * 2 + offset[1])
    shadow_canvas.paste(shadow, shadow_pos, shadow)
    shadow_blurred = shadow_canvas.filter(ImageFilter.GaussianBlur(blur))
    
    # Paste actual image on top
    shadow_blurred.paste(image, (blur * 2, blur * 2), image)
    return shadow_blurred, blur * 2

def get_fonts():
    """Tries loading modern system fonts."""
    font_bold = None
    font_sub = None
    font_badge = None
    
    for f in ["segoeuib.ttf", "arialbd.ttf", "calibrib.ttf", "tahomabd.ttf"]:
        try:
            font_bold = ImageFont.truetype(f, 62)
            font_sub = ImageFont.truetype(f.replace("bd", "").replace("b", ""), 32)
            font_badge = ImageFont.truetype(f, 22)
            break
        except Exception:
            pass
            
    if font_bold is None:
        font_bold = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_badge = ImageFont.load_default()
        
    return font_bold, font_sub, font_badge

def create_market_screenshot(
    canvas_w, canvas_h,
    badge_text, title_line1, title_line2, subtitle,
    screen_path,
    floating_icons, # list of (icon_path, (rel_x, rel_y), size, shadow_offset)
    glow_color=(99, 102, 241),
    accent_color=(253, 224, 71)
):
    """
    Renders a single 2026-standard store screenshot.
    """
    # 1. Background gradient canvas
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (11, 15, 26, 255)) # Deep obsidian
    draw = ImageDraw.Draw(canvas)
    
    # Ambient radial glow behind phone
    glow_center_x = canvas_w // 2
    glow_center_y = int(canvas_h * 0.65)
    for r in range(500, 0, -25):
        alpha = int(40 * (1 - r / 500))
        draw.ellipse(
            (glow_center_x - r, glow_center_y - r, glow_center_x + r, glow_center_y + r),
            fill=(glow_color[0], glow_color[1], glow_color[2], alpha)
        )
        
    # Top ambient soft glow
    for r in range(400, 0, -30):
        alpha = int(25 * (1 - r / 400))
        draw.ellipse(
            (glow_center_x - r, -50 - r, glow_center_x + r, -50 + r),
            fill=(glow_color[0], glow_color[1], glow_color[2], alpha)
        )

    # 2. Render Text Elements (Top Section)
    font_bold, font_sub, font_badge = get_fonts()
    
    # Badge (Pill)
    badge_bbox = draw.textbbox((0, 0), badge_text, font=font_badge)
    bw = badge_bbox[2] - badge_bbox[0]
    bh = badge_bbox[3] - badge_bbox[1]
    bx = (canvas_w - bw) // 2
    by = int(canvas_h * 0.055)
    
    # Pill background
    pad_x, pad_y = 22, 9
    draw.rounded_rectangle(
        (bx - pad_x, by - pad_y, bx + bw + pad_x, by + bh + pad_y),
        radius=18,
        fill=(24, 30, 48, 240),
        outline=(glow_color[0], glow_color[1], glow_color[2], 180),
        width=2
    )
    draw.text((bx, by), badge_text, font=font_badge, fill=accent_color)
    
    # Title Line 1
    t1_bbox = draw.textbbox((0, 0), title_line1, font=font_bold)
    t1_w = t1_bbox[2] - t1_bbox[0]
    t1_x = (canvas_w - t1_w) // 2
    t1_y = by + bh + pad_y + 18
    # Subtle text shadow
    draw.text((t1_x + 2, t1_y + 3), title_line1, font=font_bold, fill=(0, 0, 0, 200))
    draw.text((t1_x, t1_y), title_line1, font=font_bold, fill=(255, 255, 255, 255))
    
    # Title Line 2 (Colored / Highlighted)
    t2_bbox = draw.textbbox((0, 0), title_line2, font=font_bold)
    t2_w = t2_bbox[2] - t2_bbox[0]
    t2_x = (canvas_w - t2_w) // 2
    t2_y = t1_y + 70
    draw.text((t2_x + 2, t2_y + 3), title_line2, font=font_bold, fill=(0, 0, 0, 200))
    draw.text((t2_x, t2_y), title_line2, font=font_bold, fill=(165, 180, 252, 255)) # Soft violet/indigo
    
    # Subtitle
    sub_bbox = draw.textbbox((0, 0), subtitle, font=font_sub)
    sub_w = sub_bbox[2] - sub_bbox[0]
    sub_x = (canvas_w - sub_w) // 2
    sub_y = t2_y + 75
    draw.text((sub_x + 1, sub_y + 2), subtitle, font=font_sub, fill=(0, 0, 0, 160))
    draw.text((sub_x, sub_y), subtitle, font=font_sub, fill=(203, 213, 225, 255))
    
    # 3. Create Phone Mockup & Position
    phone_w = int(canvas_w * 0.72)
    phone_h = int(phone_w * 2.02)
    mockup = create_phone_mockup(screen_path, target_width=phone_w, target_height=phone_h)
    
    # Add deep shadow to phone
    mockup_with_shadow, offset_pad = add_drop_shadow(
        mockup, offset=(0, 35), blur=50, shadow_color=(0, 0, 0, 210)
    )
    
    mockup_x = (canvas_w - mockup.width) // 2 - offset_pad
    mockup_y = sub_y + 65 - offset_pad
    
    # Paste phone mockup
    canvas.paste(mockup_with_shadow, (mockup_x, mockup_y), mockup_with_shadow)
    
    # 4. Floating 3D Elements
    for icon_path, (rel_x, rel_y), sz, rot in floating_icons:
        if os.path.exists(icon_path):
            ic = Image.open(icon_path).convert("RGBA")
            ic = ic.resize((sz, sz), Image.Resampling.LANCZOS)
            if rot != 0:
                ic = ic.rotate(rot, resample=Image.Resampling.BICUBIC, expand=True)
            
            ic_shadow, ic_pad = add_drop_shadow(
                ic, offset=(0, 16), blur=24, shadow_color=(0, 0, 0, 180)
            )
            
            target_x = int(canvas_w * rel_x) - ic_pad
            target_y = int(canvas_h * rel_y) - ic_pad
            canvas.paste(ic_shadow, (target_x, target_y), ic_shadow)

    return canvas.convert("RGB")

def build_all_screenshots():
    out_dir_phone = "assets/store/screenshots/phone"
    out_dir_tablet7 = "assets/store/screenshots/tablet_7in"
    out_dir_tablet10 = "assets/store/screenshots/tablet_10in"
    
    for d in [out_dir_phone, out_dir_tablet7, out_dir_tablet10]:
        os.makedirs(d, exist_ok=True)
        
    screens_config = [
        {
            "id": "01_collection",
            "badge": "★ 100% OFFLINE • NO WIFI REQUIRED ★",
            "t1": "13 ADDICTIVE GAMES",
            "t2": "ALL IN ONE APP",
            "sub": "Play Anywhere, Anytime with Zero Data",
            "screen": "assets/ss/Home.png",
            "glow": (99, 102, 241),
            "accent": (253, 224, 71),
            "icons": [
                ("assets/icon/joystick.png", (0.02, 0.42), 190, -12),
                ("assets/icon/winner.png", (0.76, 0.38), 210, 14),
                ("assets/icon/tic-tac-toe.png", (0.78, 0.70), 160, -8),
                ("assets/icon/target.png", (0.04, 0.72), 160, 10),
            ]
        },
        {
            "id": "02_brain_training",
            "badge": "🧠 DAILY COGNITIVE WORKOUT",
            "t1": "BOOST YOUR MEMORY",
            "t2": "& SHARPEN LOGIC",
            "sub": "Train Focus, Pattern Recall & Spatial Thinking",
            "screen": "assets/ss/game_detail.png",
            "glow": (168, 85, 247),
            "accent": (147, 197, 253),
            "icons": [
                ("assets/icon/memory-game.png", (0.02, 0.40), 200, -10),
                ("assets/icon/pattern.png", (0.76, 0.42), 190, 12),
                ("assets/icon/color-circle.png", (0.04, 0.70), 170, 8),
            ]
        },
        {
            "id": "03_reflexes",
            "badge": "⚡ MILLISECOND SPEED ACCURACY",
            "t1": "TEST YOUR REFLEXES",
            "t2": "& AIM ACCURACY",
            "sub": "Lightning Reaction Times & Rapid Flick Taps",
            "screen": "assets/ss/favorites.png",
            "glow": (6, 182, 212),
            "accent": (253, 224, 71),
            "icons": [
                ("assets/icon/quick-response.png", (0.02, 0.40), 200, -12),
                ("assets/icon/target.png", (0.76, 0.42), 200, 10),
                ("assets/icon/rock-paper-scissors.png", (0.78, 0.70), 160, -10),
            ]
        },
        {
            "id": "04_words_trivia",
            "badge": "🌍 VOCABULARY & GEOGRAPHY",
            "t1": "WORDS & TRIVIA",
            "t2": "CHALLENGES",
            "sub": "Master Word Guesses, Flags & Classic Tactics",
            "screen": "assets/ss/Home.png",
            "glow": (16, 185, 129),
            "accent": (253, 224, 71),
            "icons": [
                ("assets/icon/flag.png", (0.02, 0.42), 190, -8),
                ("assets/icon/blackjack.png", (0.76, 0.40), 190, 12),
                ("assets/icon/tic-tac-toe.png", (0.04, 0.72), 160, 10),
            ]
        },
        {
            "id": "05_leaderboard",
            "badge": "🏆 REAL-TIME WORLD COMPETITION",
            "t1": "CLIMB THE RANKS",
            "t2": "& SET RECORDS",
            "sub": "Compete with Puzzle Masters Globally",
            "screen": "assets/ss/global_leaderboard.png",
            "glow": (245, 158, 11),
            "accent": (253, 224, 71),
            "icons": [
                ("assets/icon/winner.png", (0.02, 0.40), 220, -12),
                ("assets/icon/cynnora_icon.png", (0.76, 0.42), 180, 10),
                ("assets/icon/joystick.png", (0.78, 0.70), 170, -8),
            ]
        }
    ]
    
    print("\n--- Generating 2026+ Premium Store Screenshots ---")
    
    for cfg in screens_config:
        # 1. Phone Screenshots: 1080 x 1920
        phone_img = create_market_screenshot(
            canvas_w=1080, canvas_h=1920,
            badge_text=cfg["badge"],
            title_line1=cfg["t1"],
            title_line2=cfg["t2"],
            subtitle=cfg["sub"],
            screen_path=cfg["screen"],
            floating_icons=cfg["icons"],
            glow_color=cfg["glow"],
            accent_color=cfg["accent"]
        )
        p_path = os.path.join(out_dir_phone, f"{cfg['id']}_phone_1080x1920.png")
        phone_img.save(p_path, "PNG", optimize=True)
        print(f"Generated Phone Screenshot: {p_path}")
        
        # 2. 7-inch & 10-inch Tablet Screenshots: 1200 x 1920 (9:16 - 16:10 compliant)
        tablet_img = create_market_screenshot(
            canvas_w=1200, canvas_h=1920,
            badge_text=cfg["badge"],
            title_line1=cfg["t1"],
            title_line2=cfg["t2"],
            subtitle=cfg["sub"],
            screen_path=cfg["screen"],
            floating_icons=cfg["icons"],
            glow_color=cfg["glow"],
            accent_color=cfg["accent"]
        )
        t7_path = os.path.join(out_dir_tablet7, f"{cfg['id']}_tablet7_1200x1920.png")
        t10_path = os.path.join(out_dir_tablet10, f"{cfg['id']}_tablet10_1200x1920.png")
        tablet_img.save(t7_path, "PNG", optimize=True)
        tablet_img.save(t10_path, "PNG", optimize=True)
        print(f"Generated Tablet Screenshots: {t7_path}")

if __name__ == "__main__":
    build_all_screenshots()

