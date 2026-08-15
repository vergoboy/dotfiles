#!/usr/bin/env python3
"""ASCII preview of a generated frame (shape/layout only, no color)."""
import sys
import numpy as np
from PIL import Image

path = sys.argv[1]
im = Image.open(path).convert("RGBA")
a = np.asarray(im).astype(np.float32)
H, W = a.shape[:2]
COLS = 18
ROWS = 36  # 2 terminal-rows per cell-height, using half-block approximation

# downsample: group pixel rows into 2 per terminal row
ch = H / ROWS
cw = W / COLS
ramp = " .:-=+*#%@"

rows = []
for r in range(ROWS):
    y0, y1 = int(r * ch), int((r + 1) * ch)
    line = []
    for c in range(COLS):
        x0, x1 = int(c * cw), int((c + 1) * cw)
        block = a[y0:y1, x0:x1]
        alpha = block[:, :, 3].mean()
        if alpha < 0.06:
            line.append(" ")
            continue
        lum = (block[:, :, 0] * 0.3 + block[:, :, 1] * 0.59 + block[:, :, 2] * 0.11).mean()
        # boost: planet is dark indigo; normalize
        idx = min(len(ramp) - 1, int((lum / 255.0) ** 0.7 * (len(ramp) - 1)))
        line.append(ramp[idx])
    rows.append("".join(line))

for r in range(ROWS):
    print(rows[r])
