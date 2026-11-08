import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def get_fonts():
    fonts = {}
    for name in ["segoeuib.ttf", "arialbd.ttf", "calibrib.ttf", "verdana.ttf"]:
        try:
            fonts["badge"] = ImageFont.truetype(name, 26)
            fonts["title"] = ImageFont.truetype(name, 56)
            fonts["subtitle"] = ImageFont.truetype(name.replace("bd", "").replace("b", ""), 30)
            fonts["app_title"] = ImageFont.truetype(name, 36)
            fonts["game_huge"] = ImageFont.truetype(name, 90)
            fonts["game_big"] = ImageFont.truetype(name, 56)
            fonts["game_bold"] = ImageFont.truetype(name, 34)
            fonts["game_med"] = ImageFont.truetype(name.replace("bd", "").replace("b", ""), 26)
            fonts["game_small"] = ImageFont.truetype(name.replace("bd", "").replace("b", ""), 22)
            fonts["key"] = ImageFont.truetype(name, 28)
            break
        except Exception:
            pass
            
    if not fonts:
        default = ImageFont.load_default()
        fonts = {k: default for k in ["badge", "title", "subtitle", "app_title", "game_huge", "game_big", "game_bold", "game_med", "game_small", "key"]}
    return fonts

def draw_header(canvas, badge, title, subtitle, glow_color, accent_color, fonts):
    draw = ImageDraw.Draw(canvas)
    w, h = canvas.size
    
    # Ambient soft glow at top
    for r in range(500, 0, -30):
        alpha = int(35 * (1 - r / 500))
        draw.ellipse((w//2 - r, -80 - r, w//2 + r, -80 + r), fill=(glow_color[0], glow_color[1], glow_color[2], alpha))
        
    # Badge (Pill)
    bbox = draw.textbbox((0, 0), badge, font=fonts["badge"])
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    bx = (w - bw) // 2
    by = 50
    draw.rounded_rectangle((bx - 22, by - 10, bx + bw + 22, by + bh + 10), radius=18, fill=(22, 28, 46, 240), outline=(glow_color[0], glow_color[1], glow_color[2], 200), width=2)
    draw.text((bx, by), badge, font=fonts["badge"], fill=accent_color)
    
    # Title
    t_bbox = draw.textbbox((0, 0), title, font=fonts["title"])
    tw = t_bbox[2] - t_bbox[0]
    tx = (w - tw) // 2
    ty = by + bh + 32
    draw.text((tx + 2, ty + 2), title, font=fonts["title"], fill=(0, 0, 0, 200))
    draw.text((tx, ty), title, font=fonts["title"], fill=(255, 255, 255, 255))
    
    # Subtitle
    s_bbox = draw.textbbox((0, 0), subtitle, font=fonts["subtitle"])
    sw = s_bbox[2] - s_bbox[0]
    sx = (w - sw) // 2
    sy = ty + 72
    draw.text((sx + 1, sy + 1), subtitle, font=fonts["subtitle"], fill=(0, 0, 0, 160))
    draw.text((sx, sy), subtitle, font=fonts["subtitle"], fill=(199, 210, 254, 255))
    
    return sy + 62 # Start Y for game screen

def create_game_screen_container(w, h):
    """Creates a base 1080x1920 dark gaming screen."""
    im = Image.new("RGBA", (w, h), (15, 23, 42, 255)) # Dark slate
    draw = ImageDraw.Draw(im)
    # Subtle gradient
    for y in range(0, h, 4):
        ratio = y / h
        r = int(15 * (1 - ratio) + 10 * ratio)
        g = int(23 * (1 - ratio) + 15 * ratio)
        b = int(42 * (1 - ratio) + 30 * ratio)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255), width=4)
    return im

def build_app_bar(draw, w, title_text, fonts):
    """Draws in-game App Bar."""
    draw.rectangle((0, 0, w, 110), fill=(24, 32, 54, 255))
    draw.line([(0, 110), (w, 110)], fill=(51, 65, 85, 255), width=2)
    # Back arrow
    draw.polygon([(40, 55), (60, 40), (60, 70)], fill=(255, 255, 255, 255))
    # Title
    draw.text((85, 36), title_text, font=fonts["app_title"], fill=(255, 255, 255, 255))
    # Restart icon
    draw.ellipse((w - 75, 35, w - 35, 75), outline=(148, 163, 184, 255), width=3)
    draw.polygon([(w - 45, 35), (w - 35, 45), (w - 35, 30)], fill=(148, 163, 184, 255))

# ==================== GAME 1: TIC-TAC-TOE ====================
def render_tictactoe_screen(fonts):
    w, h = 1080, 1920
    im = create_game_screen_container(w, h)
    draw = ImageDraw.Draw(im)
    build_app_bar(draw, w, "Tic Tac Toe (XOX)", fonts)
    
    # Score Banner
    draw.rounded_rectangle((60, 150, w - 60, 270), radius=24, fill=(30, 41, 59, 255), outline=(99, 102, 241, 150), width=2)
    # Player 1
    draw.text((100, 175), "YOU (X)", font=fonts["game_bold"], fill=(56, 189, 248, 255))
    draw.text((120, 215), "Score: 4", font=fonts["game_med"], fill=(226, 232, 240, 255))
    # VS Round
    draw.text((w//2 - 60, 175), "ROUND 5", font=fonts["game_bold"], fill=(253, 224, 71, 255))
    draw.text((w//2 - 50, 215), "Best of 7", font=fonts["game_small"], fill=(148, 163, 184, 255))
    # AI
    draw.text((w - 230, 175), "AI (O)", font=fonts["game_bold"], fill=(244, 63, 94, 255))
    draw.text((w - 210, 215), "Score: 1", font=fonts["game_med"], fill=(226, 232, 240, 255))
    
    # Turn Status
    draw.rounded_rectangle((w//2 - 160, 310, w//2 + 160, 370), radius=20, fill=(16, 185, 129, 40), outline=(16, 185, 129, 200), width=2)
    draw.text((w//2 - 120, 325), "★ YOUR TURN (X) ★", font=fonts["game_bold"], fill=(52, 211, 153, 255))
    
    # 3x3 Grid
    grid_size = 720
    gx = (w - grid_size) // 2
    gy = 420
    cell = grid_size // 3 # 240
    
    # Board Background
    draw.rounded_rectangle((gx - 20, gy - 20, gx + grid_size + 20, gy + grid_size + 20), radius=36, fill=(24, 32, 54, 255), outline=(71, 85, 105, 200), width=3)
    
    # Grid lines
    for i in range(1, 3):
        lx = gx + i * cell
        draw.line([(lx, gy + 10), (lx, gy + grid_size - 10)], fill=(71, 85, 105, 255), width=8)
        ly = gy + i * cell
        draw.line([(gx + 10, ly), (gx + grid_size - 10, ly)], fill=(71, 85, 105, 255), width=8)
        
    # Cells Content:
    # Row 0: X, O, X
    # Row 1: O, X,  
    # Row 2:  , O, X  (Diagonal Win!)
    moves = [
        ("X", (0, 0)), ("O", (0, 1)), ("X", (0, 2)),
        ("O", (1, 0)), ("X", (1, 1)), (" ", (1, 2)),
        (" ", (2, 0)), ("O", (2, 1)), ("X", (2, 2))
    ]
    
    for mark, (row, col) in moves:
        if mark == " ":
            continue
        cx = gx + col * cell + cell // 2
        cy = gy + row * cell + cell // 2
        color = (56, 189, 248, 255) if mark == "X" else (244, 63, 94, 255)
        m_bbox = draw.textbbox((0, 0), mark, font=fonts["game_huge"])
        mw, mh = m_bbox[2] - m_bbox[0], m_bbox[3] - m_bbox[1]
        draw.text((cx - mw//2, cy - mh//2 - 10), mark, font=fonts["game_huge"], fill=color)
        
    # Diagonal Win Strike Line!
    draw.line([(gx + 30, gy + 30), (gx + grid_size - 30, gy + grid_size - 30)], fill=(52, 211, 153, 255), width=14)
    # Win Glow
    draw.line([(gx + 30, gy + 30), (gx + grid_size - 30, gy + grid_size - 30)], fill=(52, 211, 153, 100), width=26)
    
    # Win notification banner
    draw.rounded_rectangle((100, 1200, w - 100, 1310), radius=28, fill=(16, 185, 129, 230), outline=(255, 255, 255, 200), width=3)
    draw.text((w//2 - 190, 1235), "🎉 YOU WIN! THREE IN A ROW! 🎉", font=fonts["game_bold"], fill=(255, 255, 255, 255))
    
    # Difficulty Selector & Stats
    draw.rounded_rectangle((60, 1360, w - 60, 1460), radius=20, fill=(30, 41, 59, 200), outline=(51, 65, 85, 255), width=2)
    draw.text((90, 1395), "Difficulty: SMART AI (HARD)", font=fonts["game_med"], fill=(226, 232, 240, 255))
    draw.text((w - 270, 1395), "Win Rate: 78%", font=fonts["game_bold"], fill=(56, 189, 248, 255))
    
    return im

# ==================== GAME 2: WORD GUESS ====================
def render_word_guess_screen(fonts):
    w, h = 1080, 1920
    im = create_game_screen_container(w, h)
    draw = ImageDraw.Draw(im)
    build_app_bar(draw, w, "Word Guess (Wordle Style)", fonts)
    
    # Top Stats
    draw.rounded_rectangle((60, 140, w - 60, 240), radius=20, fill=(30, 41, 59, 255), outline=(99, 102, 241, 150), width=2)
    draw.text((100, 172), "Tries: 2/6", font=fonts["game_bold"], fill=(253, 224, 71, 255))
    draw.text((w//2 - 60, 172), "STREAK: 12 🔥", font=fonts["game_bold"], fill=(249, 115, 22, 255))
    draw.text((w - 230, 172), "POINTS: 1,420", font=fonts["game_bold"], fill=(56, 189, 248, 255))
    
    # 5x6 Matrix
    start_y = 270
    cols, rows = 5, 6
    box_sz = 140
    gap = 20
    grid_w = cols * box_sz + (cols - 1) * gap
    start_x = (w - grid_w) // 2
    
    board = [
        [("B", "G"), ("R", "Y"), ("A", "X"), ("I", "X"), ("N", "G")], # BRAIN
        [("B", "G"), ("L", "G"), ("E", "G"), ("N", "G"), ("D", "G")], # BLEND (Solved!)
        [("", ""), ("", ""), ("", ""), ("", ""), ("", "")],
        [("", ""), ("", ""), ("", ""), ("", ""), ("", "")],
        [("", ""), ("", ""), ("", ""), ("", ""), ("", "")],
        [("", ""), ("", ""), ("", ""), ("", ""), ("", "")],
    ]
    
    color_map = {
        "G": ((34, 197, 94, 255), (22, 163, 74, 255)),   # Green (Correct spot)
        "Y": ((234, 179, 8, 255), (202, 138, 4, 255)),    # Yellow (Wrong spot)
        "X": ((71, 85, 105, 255), (51, 65, 85, 255)),     # Grey (Absent)
        "": ((30, 41, 59, 200), (51, 65, 85, 255))        # Empty
    }
    
    for r in range(rows):
        for c in range(cols):
            bx = start_x + c * (box_sz + gap)
            by = start_y + r * (box_sz + gap)
            letter, status = board[r][c]
            bg_col, border_col = color_map[status]
            
            draw.rounded_rectangle((bx, by, bx + box_sz, by + box_sz), radius=16, fill=bg_col, outline=border_col, width=3)
            if letter:
                m_bbox = draw.textbbox((0, 0), letter, font=fonts["game_big"])
                mw, mh = m_bbox[2] - m_bbox[0], m_bbox[3] - m_bbox[1]
                draw.text((bx + (box_sz - mw)//2, by + (box_sz - mh)//2 - 6), letter, font=fonts["game_big"], fill=(255, 255, 255, 255))

    # Solved celebration toast
    toast_y = start_y + 6 * (box_sz + gap) + 15
    draw.rounded_rectangle((120, toast_y, w - 120, toast_y + 80), radius=24, fill=(16, 185, 129, 240), outline=(255, 255, 255, 200), width=3)
    draw.text((w//2 - 200, toast_y + 22), "🎉 GENIUS! SOLVED IN 2 TRIES! 🎉", font=fonts["game_bold"], fill=(255, 255, 255, 255))

    # Keyboard at bottom
    keys_rows = [
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    ]
    key_y = toast_y + 110
    for r_idx, row_str in enumerate(keys_rows):
        k_w = 88 if r_idx < 2 else 96
        k_h = 76
        k_gap = 12
        r_w = len(row_str) * k_w + (len(row_str) - 1) * k_gap
        rx = (w - r_w) // 2
        for c_idx, ch in enumerate(row_str):
            kx = rx + c_idx * (k_w + k_gap)
            ky = key_y + r_idx * (k_h + 14)
            # Color active keys
            k_col = (51, 65, 85, 255)
            if ch in "BLEND":
                k_col = (34, 197, 94, 255)
            elif ch in "R":
                k_col = (234, 179, 8, 255)
            elif ch in "AI":
                k_col = (71, 85, 105, 255)
            draw.rounded_rectangle((kx, ky, kx + k_w, ky + k_h), radius=12, fill=k_col)
            draw.text((kx + k_w//2 - 10, ky + 20), ch, font=fonts["key"], fill=(255, 255, 255, 255))
            
    return im

# ==================== GAME 3: AIM TRAINER / REFLEX ====================
def render_aim_trainer_screen(fonts):
    w, h = 1080, 1920
    im = create_game_screen_container(w, h)
    draw = ImageDraw.Draw(im)
    build_app_bar(draw, w, "Aim Trainer & Reflex Test", fonts)
    
    # Top Stats Dashboard
    draw.rounded_rectangle((50, 140, w - 50, 260), radius=24, fill=(30, 41, 59, 255), outline=(6, 182, 212, 160), width=2)
    # Target count
    draw.text((90, 165), "TARGETS", font=fonts["game_small"], fill=(148, 163, 184, 255))
    draw.text((90, 195), "24 / 30", font=fonts["game_big"], fill=(255, 255, 255, 255))
    # Accuracy
    draw.text((w//2 - 60, 165), "ACCURACY", font=fonts["game_small"], fill=(148, 163, 184, 255))
    draw.text((w//2 - 60, 195), "98.4%", font=fonts["game_big"], fill=(52, 211, 153, 255))
    # Score
    draw.text((w - 230, 165), "SCORE", font=fonts["game_small"], fill=(148, 163, 184, 255))
    draw.text((w - 230, 195), "3,850", font=fonts["game_big"], fill=(253, 224, 71, 255))
    
    # Gaming grid arena with targets
    arena_y = 290
    arena_h = 1150
    draw.rounded_rectangle((40, arena_y, w - 40, arena_y + arena_h), radius=32, fill=(18, 26, 46, 255), outline=(51, 65, 85, 255), width=3)
    
    # Draw subtle arena crosshairs / grid
    for gx in range(120, w - 40, 160):
        draw.line([(gx, arena_y + 20), (gx, arena_y + arena_h - 20)], fill=(30, 41, 69, 120), width=1)
    for gy in range(arena_y + 80, arena_y + arena_h, 160):
        draw.line([(60, gy), (w - 60, gy)], fill=(30, 41, 69, 120), width=1)
        
    def draw_bullseye(cx, cy, radius, primary_color, secondary_color):
        # Outer glow
        for r in range(radius + 40, radius, -10):
            draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(primary_color[0], primary_color[1], primary_color[2], 25))
        # Outer ring
        draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=primary_color, outline=(255, 255, 255, 200), width=3)
        # Ring 2
        r2 = int(radius * 0.68)
        draw.ellipse((cx - r2, cy - r2, cx + r2, cy + r2), fill=secondary_color, outline=(255, 255, 255, 160), width=2)
        # Bullseye center
        r3 = int(radius * 0.35)
        draw.ellipse((cx - r3, cy - r3, cx + r3, cy + r3), fill=(255, 255, 255, 255))
        # Crosshair lines
        draw.line([(cx - radius - 15, cy), (cx + radius + 15, cy)], fill=(255, 255, 255, 200), width=3)
        draw.line([(cx, cy - radius - 15), (cx, cy + radius + 15)], fill=(255, 255, 255, 200), width=3)

    # Target 1 (Active Center-Right)
    draw_bullseye(cx=360, cy=680, radius=95, primary_color=(239, 68, 68, 255), secondary_color=(255, 255, 255, 255))
    
    # Target 2 (Active Upper Right)
    draw_bullseye(cx=760, cy=480, radius=85, primary_color=(6, 182, 212, 255), secondary_color=(15, 23, 42, 255))
    
    # Target 3 (Active Lower Right)
    draw_bullseye(cx=720, cy=960, radius=80, primary_color=(245, 158, 11, 255), secondary_color=(255, 255, 255, 255))
    
    # Hit marker & Floating Score (+150 PERFECT!)
    draw.rounded_rectangle((280, 520, 500, 580), radius=16, fill=(16, 185, 129, 230), outline=(255, 255, 255, 255), width=2)
    draw.text((295, 532), "🎯 +150 PERFECT!", font=fonts["game_bold"], fill=(255, 255, 255, 255))
    
    # Combo streak badge
    draw.rounded_rectangle((w//2 - 180, 1150, w//2 + 180, 1230), radius=24, fill=(249, 115, 22, 230), outline=(253, 224, 71, 255), width=3)
    draw.text((w//2 - 145, 1172), "🔥 8x COMBO STREAK! 🔥", font=fonts["game_bold"], fill=(255, 255, 255, 255))
    
    # Bottom Reaction Speed Callout
    draw.rounded_rectangle((50, 1480, w - 50, 1590), radius=24, fill=(30, 41, 59, 240), outline=(6, 182, 212, 200), width=2)
    draw.text((90, 1515), "AVG REACTION TIME: 184 ms", font=fonts["game_bold"], fill=(56, 189, 248, 255))
    draw.text((w - 260, 1515), "RANK: PRO ⚡", font=fonts["game_bold"], fill=(253, 224, 71, 255))
    
    return im

# ==================== GAME 4: GUESS THE FLAG ====================
def render_flag_quiz_screen(fonts):
    w, h = 1080, 1920
    im = create_game_screen_container(w, h)
    draw = ImageDraw.Draw(im)
    build_app_bar(draw, w, "World Flags Quiz", fonts)
    
    # Top Stats
    draw.rounded_rectangle((60, 140, w - 60, 240), radius=20, fill=(30, 41, 59, 255), outline=(16, 185, 129, 150), width=2)
    draw.text((100, 172), "QUESTION: 7 / 15", font=fonts["game_bold"], fill=(255, 255, 255, 255))
    draw.text((w//2 - 50, 172), "STREAK: 6 🔥", font=fonts["game_bold"], fill=(249, 115, 22, 255))
    draw.text((w - 230, 172), "SCORE: 950", font=fonts["game_bold"], fill=(52, 211, 153, 255))
    
    # Question Header
    draw.text((w//2 - 270, 280), "Which country does this flag belong to?", font=fonts["game_bold"], fill=(226, 232, 240, 255))
    
    # Flag Display Card
    card_w, card_h = 760, 480
    cx = (w - card_w) // 2
    cy = 350
    # Flag card shadow & border
    draw.rounded_rectangle((cx - 10, cy - 10, cx + card_w + 10, cy + card_h + 10), radius=28, fill=(24, 32, 54, 255), outline=(71, 85, 105, 255), width=3)
    
    # Render Flag (United Kingdom Union Jack Flag)
    # Blue background
    flag = Image.new("RGBA", (card_w, card_h), (1, 33, 105, 255))
    f_draw = ImageDraw.Draw(flag)
    # White diagonal crosses
    f_draw.line([(0, 0), (card_w, card_h)], fill=(255, 255, 255, 255), width=65)
    f_draw.line([(0, card_h), (card_w, 0)], fill=(255, 255, 255, 255), width=65)
    # Red diagonal crosses
    f_draw.line([(0, 0), (card_w, card_h)], fill=(200, 16, 46, 255), width=24)
    f_draw.line([(0, card_h), (card_w, 0)], fill=(200, 16, 46, 255), width=24)
    # White straight cross
    f_draw.line([(card_w//2, 0), (card_w//2, card_h)], fill=(255, 255, 255, 255), width=100)
    f_draw.line([(0, card_h//2), (card_w, card_h//2)], fill=(255, 255, 255, 255), width=100)
    # Red straight cross
    f_draw.line([(card_w//2, 0), (card_w//2, card_h)], fill=(200, 16, 46, 255), width=60)
    f_draw.line([(0, card_h//2), (card_w, card_h//2)], fill=(200, 16, 46, 255), width=60)
    
    # Mask rounded flag
    flag_mask = Image.new("L", (card_w, card_h), 0)
    ImageDraw.Draw(flag_mask).rounded_rectangle((0, 0, card_w, card_h), radius=22, fill=255)
    im.paste(flag, (cx, cy), flag_mask)
    
    # 4 Option Choice Cards
    options = [
        ("A", "United Kingdom", True),   # Correct option selected!
        ("B", "Australia", False),
        ("C", "New Zealand", False),
        ("D", "Iceland", False)
    ]
    
    btn_y = cy + card_h + 50
    for idx, (letter, text, is_correct) in enumerate(options):
        by = btn_y + idx * 115
        bg_col = (16, 185, 129, 230) if is_correct else (30, 41, 59, 230)
        border_col = (52, 211, 153, 255) if is_correct else (71, 85, 105, 255)
        
        draw.rounded_rectangle((100, by, w - 100, by + 95), radius=22, fill=bg_col, outline=border_col, width=3)
        # Option Badge
        draw.rounded_rectangle((125, by + 18, 185, by + 78), radius=14, fill=(15, 23, 42, 200))
        draw.text((144, by + 26), letter, font=fonts["game_bold"], fill=(255, 255, 255, 255))
        
        # Country text
        draw.text((215, by + 28), text, font=fonts["game_bold"], fill=(255, 255, 255, 255))
        if is_correct:
            draw.text((w - 180, by + 28), "✓ CORRECT", font=fonts["game_bold"], fill=(255, 255, 255, 255))

    # Bottom helper info
    draw.rounded_rectangle((60, 1370, w - 60, 1460), radius=20, fill=(30, 41, 59, 200), outline=(51, 65, 85, 255), width=2)
    draw.text((100, 1400), "Capital: London  •  Continent: Europe", font=fonts["game_med"], fill=(148, 163, 184, 255))
    draw.text((w - 260, 1400), "+100 PTS ⭐", font=fonts["game_bold"], fill=(253, 224, 71, 255))
    
    return im

def build_game_focused_screenshots():
    out_dir_phone = "assets/store/screenshots/phone"
    out_dir_tablet7 = "assets/store/screenshots/tablet_7in"
    out_dir_tablet10 = "assets/store/screenshots/tablet_10in"
    for d in [out_dir_phone, out_dir_tablet7, out_dir_tablet10]:
        os.makedirs(d, exist_ok=True)
        
    fonts = get_fonts()
    
    # 5 Game-Focused Screenshots
    screens_data = [
        {
            "id": "01_collection",
            "badge": "★ 100% OFFLINE • NO WIFI REQUIRED ★",
            "title": "13 ADDICTIVE MINI GAMES",
            "subtitle": "All Your Favorite Brain Games in One Pocket App",
            "glow": (99, 102, 241),
            "accent": (253, 224, 71),
            "screen_generator": lambda: Image.open("assets/ss/Home.png").convert("RGBA")
        },
        {
            "id": "02_word_guess",
            "badge": "🔤 WORDLE STYLE WORD PUZZLE",
            "title": "GUESS THE SECRET WORD",
            "subtitle": "6 Tries to Find the Hidden Word & Build Vocabulary",
            "glow": (34, 197, 94),
            "accent": (253, 224, 71),
            "screen_generator": lambda: render_word_guess_screen(fonts)
        },
        {
            "id": "03_aim_trainer",
            "badge": "⚡ MILLISECOND SPEED ACCURACY",
            "title": "AIM TRAINER & REFLEX SPEED",
            "subtitle": "Test Reaction Time, Accuracy & Hand-Eye Coordination",
            "glow": (6, 182, 212),
            "accent": (253, 224, 71),
            "screen_generator": lambda: render_aim_trainer_screen(fonts)
        },
        {
            "id": "04_tictactoe",
            "badge": "🧠 CLASSIC LOGIC & STRATEGY",
            "title": "TIC-TAC-TOE & TACTICS",
            "subtitle": "Outsmart Smart AI or Challenge Friends in Classic Duels",
            "glow": (168, 85, 247),
            "accent": (253, 224, 71),
            "screen_generator": lambda: render_tictactoe_screen(fonts)
        },
        {
            "id": "05_flags_trivia",
            "badge": "🌍 WORLD GEOGRAPHY QUIZ",
            "title": "GUESS THE COUNTRY FLAG",
            "subtitle": "Test Your Geography & Flag Trivia from 190+ Nations",
            "glow": (245, 158, 11),
            "accent": (253, 224, 71),
            "screen_generator": lambda: render_flag_quiz_screen(fonts)
        },
    ]

    print("\n--- Generating Clean, Close-Up Game-Focused Screenshots ---")

    for cfg in screens_data:
        screen_img = cfg["screen_generator"]()
        
        # 1. PHONE (1080 x 1920)
        phone_canvas = Image.new("RGBA", (1080, 1920), (11, 15, 26, 255))
        start_y = draw_header(
            phone_canvas, cfg["badge"], cfg["title"], cfg["subtitle"],
            cfg["glow"], cfg["accent"], fonts
        )
        
        # HERO SCREEN: Fills 96% of width, right up close!
        margin_x = 22
        frame_w = 1080 - (margin_x * 2) # 1036 px wide!
        frame_h = 1920 - start_y + 30
        
        # Rounded mask for screen
        mask = Image.new("L", (frame_w, frame_h), 0)
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, frame_w, frame_h), radius=36, fill=255)
        
        # Resize screen to fit inner hero container
        screen_fitted = screen_img.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
        
        # Hero frame with sleek subtle titanium border
        hero_frame = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
        hero_frame.paste(screen_fitted, (0, 0), mask)
        ImageDraw.Draw(hero_frame).rounded_rectangle((0, 0, frame_w - 1, frame_h - 1), radius=36, outline=(71, 85, 105, 255), width=3)
        
        # Shadow
        shadow = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0))
        s_box = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 200))
        shadow.paste(s_box, (margin_x, start_y + 12))
        shadow = shadow.filter(ImageFilter.GaussianBlur(28))
        
        phone_canvas.paste(shadow, (0, 0), shadow)
        phone_canvas.paste(hero_frame, (margin_x, start_y), hero_frame)
        
        p_path = os.path.join(out_dir_phone, f"{cfg['id']}_phone_1080x1920.png")
        phone_canvas.convert("RGB").save(p_path, "PNG", optimize=True)
        print(f"Generated Phone: {p_path}")
        
        # 2. TABLET 7 & 10 (1200 x 1920)
        tab_canvas = Image.new("RGBA", (1200, 1920), (11, 15, 26, 255))
        t_start_y = draw_header(
            tab_canvas, cfg["badge"], cfg["title"], cfg["subtitle"],
            cfg["glow"], cfg["accent"], fonts
        )
        t_margin_x = 40
        t_frame_w = 1200 - (t_margin_x * 2) # 1120 px wide
        t_frame_h = 1920 - t_start_y + 30
        
        t_mask = Image.new("L", (t_frame_w, t_frame_h), 0)
        ImageDraw.Draw(t_mask).rounded_rectangle((0, 0, t_frame_w, t_frame_h), radius=36, fill=255)
        
        t_screen_fitted = screen_img.resize((t_frame_w, t_frame_h), Image.Resampling.LANCZOS)
        t_hero_frame = Image.new("RGBA", (t_frame_w, t_frame_h), (0, 0, 0, 0))
        t_hero_frame.paste(t_screen_fitted, (0, 0), t_mask)
        ImageDraw.Draw(t_hero_frame).rounded_rectangle((0, 0, t_frame_w - 1, t_frame_h - 1), radius=36, outline=(71, 85, 105, 255), width=3)
        
        t_shadow = Image.new("RGBA", (1200, 1920), (0, 0, 0, 0))
        t_s_box = Image.new("RGBA", (t_frame_w, t_frame_h), (0, 0, 0, 200))
        t_shadow.paste(t_s_box, (t_margin_x, t_start_y + 12))
        t_shadow = t_shadow.filter(ImageFilter.GaussianBlur(28))
        
        tab_canvas.paste(t_shadow, (0, 0), t_shadow)
        tab_canvas.paste(t_hero_frame, (t_margin_x, t_start_y), t_hero_frame)
        
        t7_path = os.path.join(out_dir_tablet7, f"{cfg['id']}_tablet7_1200x1920.png")
        t10_path = os.path.join(out_dir_tablet10, f"{cfg['id']}_tablet10_1200x1920.png")
        tab_canvas.convert("RGB").save(t7_path, "PNG", optimize=True)
        tab_canvas.convert("RGB").save(t10_path, "PNG", optimize=True)
        print(f"Generated Tablet: {t7_path}")

if __name__ == "__main__":
    build_game_focused_screenshots()

