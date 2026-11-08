import os
from PIL import Image

# We can crop center or smart-fit to exact 9:16
# Original: 1536 x 2752
# Exact 9:16 from 1536 width: height = 1536 * 16 // 9 = 2730
# That means cropping (2752 - 2730) = 22 pixels off the height (11 px top, 11 px bottom). That is virtually 0 distortion!
# Then scaling to 1080 x 1920 for Phone & Tablets!

p = "assets/store/screenshots/phone"
files = sorted([f for f in os.listdir(p) if f.startswith("Gemini")])
print(files)

