import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def get_fonts():
    """Load system fonts with fallback."""
    fonts = {}
    for name in ["segoeuib.ttf", "arialbd.ttf", "calibrib.ttf", "verdana.ttf"]:
        try:
            fonts["badge"] = ImageFont.truetype(name, 24)
            fonts["title"] = ImageFont.truetype(name, 54)
            fonts["subtitle"] = ImageFont.truetype(name.replace("bd", "").replace("b", ""), 30)
            fonts["game_title"] = ImageFont.truetype(name, 40)
            fonts["game_bold"] = ImageFont.truetype(name, 32)
            fonts["game_med"] = ImageFont.truetype(name.replace("bd", "").replace("b", ""), 26)
            fonts["game_big"] = ImageFont.truetype(name, 64)
            fonts["game_huge"] = ImageFont.truetype(name, 80)
            break
        except Exception:
            pass
            
    if not fonts:
        default = ImageFont.load_default()
        fonts = {k: default for k in ["badge", "title", "subtitle", "game_title", "game_bold", "game_med", "game_big", "game_huge"]}
    return fonts

def create_top_header(canvas, badge_text, title_text, subtitle_text, glow_color, accent_color, fonts):
    """Draws a sleek, modern, professional header banner at top 18% of canvas."""
    draw = ImageDraw.Draw(canvas)
    w, h = canvas.size
    
    # Subtle top ambient radial glow
    for r in range(450, 0, -25):
        alpha = int(35 * (1 - r / 450))
        draw.ellipse((w//2 - r, -80 - r, w//2 + r, -80 + r), fill=(glow_color[0], glow_color[1], glow_color[2], alpha))
        
    # Badge (Pill)
    bbox = draw.textbbox((0, 0), badge_text, font=fonts["badge"])
    bw = bbox[2] - bbox[0]
    bh = bbox[3] - bbox[1]
    bx = (w - bw) // 2
    by = 55
    
    draw.rounded_rectangle((bx - 20, by - 8, bx + bw + 20, by + bh + 8), radius=16, fill=(20, 26, 42, 230), outline=(glow_color[0], glow_color[1], glow_color[2], 180), width=2)
    draw.text((bx, by), badge_text, font=fonts["badge"], fill=accent_color)
    
    # Title
    t_bbox = draw.textbbox((0, 0), title_text, font=fonts["title"])
    tw = t_bbox[2] - t_bbox[0]
    tx = (w - tw) // 2
    ty = by + bh + 30
    draw.text((tx + 2, ty + 2), title_text, font=fonts["title"], fill=(0, 0, 0, 180))
    draw.text((tx, ty), title_text, font=fonts["title"], fill=(255, 255, 255, 255))
    
    # Subtitle
    s_bbox = draw.textbbox((0, 0), subtitle_text, font=fonts["subtitle"])
    sw = s_bbox[2] - s_bbox[0]
    sx = (w - sw) // 2
    sy = ty + 68
    draw.text((sx, sy), subtitle_text, font=fonts["subtitle"], fill=(199, 210, 254, 255))
    
    return sy + 60 # Bottom Y of header

def create_device_frame(canvas, screen_img, start_y):
    """
    Renders the game screen in an ultra close-up hero frame filling 95% of screen width.
    No tiny miniature phone; the game is right in front of the user!
    """
    w, h = canvas.size
    margin_x = 24
    frame_w = w - (margin_x * 2) # 1032 px
    frame_h = h - start_y + 40 # reaches bottom with margin
    
    # Create phone container
    phone = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    draw_phone = ImageDraw.Draw(phone)
    
    # Titanium border
    draw_phone.rounded_rectangle((0, 0, frame_w, frame_h), radius=38, fill=(15, 20, 32, 255), outline=(51, 65, 85, 255), width=3)
    # Inner border
    draw_phone.rounded_rectangle((4, 4, frame_w - 4, frame_h - 4), radius=34, fill=(10, 14, 23, 255))
    
    # Resize screen to fit inside
    inner_w = frame_w - 16
    inner_h = frame_h - 16
    
    # Mask rounded corners
    mask = Image.new("L", (inner_w, inner_h), 0)
    draw_mask = ImageDraw.Draw(mask)
    draw_mask.rounded_rectangle((0, 0, inner_w, inner_h), radius=30, fill=255)
    
    screen_fitted = screen_img.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    phone.paste(screen_fitted, (8, 8), mask)
    
    # Top dynamic island pill
    pill_w, pill_h = 130, 26
    px = (frame_w - pill_w) // 2
    draw_phone.rounded_rectangle((px, 16, px + pill_w, 16 + pill_h), radius=13, fill=(5, 7, 12, 255))
    draw_phone.ellipse((px + 22, 22, px + 36, 36), fill=(18, 28, 48, 255)) # Camera lens
    
    # Shadow
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    s_alpha = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 160))
    shadow.paste(s_alpha, (margin_x, start_y + 15))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    
    canvas.paste(shadow, (0, 0), shadow)
    canvas.paste(phone, (margin_x, start_y), phone)

print("Helper defined.")

