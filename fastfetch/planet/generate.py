#!/usr/bin/env python3
"""
Animated ringed planet for the fastfetch logo area (kitty graphics protocol).

Renders N frames of a procedurally animated gas-giant planet with an
orbiting ring, then emits a single kitty-graphics escape stream
(animation.esc) that the fastfetch wrapper simply cats to the terminal.

Dependencies: numpy, Pillow (already present on this machine).
"""
import argparse
import base64
import io
import math
import os

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
FRAMES_DIR = os.path.join(HERE, "frames")
ESC_PATH = os.path.join(HERE, "animation.esc")
PLACEHOLDER_PATH = os.path.join(HERE, "placeholder.png")
CONFIG_PATH = os.path.join(HERE, "config")

# ---- layout (must match config.jsonc logo) --------------------------------
COLS = 18            # logo cell width
ROWS = 18            # logo cell height
ROW_TOP = 3          # padding.top (2) + 1  -> first screen row of the logo
CANVAS_W = 360       # 18 cells x ~20 px wide
CANVAS_H = 720       # 18 cells x ~40 px tall (kitty cell aspect ~0.5)

# ---- scene -----------------------------------------------------------------
R = 100             # planet radius (px)
RING_IN1 = R * 1.18
RING_OUT1 = R * 1.40
RING_IN2 = R * 1.47
RING_OUT2 = R * 1.66
TILT_CENTER = 45.0 * math.pi / 180.0
TILT_AMP = 7.0 * math.pi / 180.0
MOON_R = 14
MOON_ORBIT = 172

LIGHT = np.array([-0.42, -0.78, 0.46])
LIGHT = LIGHT / np.linalg.norm(LIGHT)

# Dracula-flavoured palette
P_CYAN = np.array([139, 233, 253])
P_PURPLE = np.array([189, 147, 249])
P_INDIGO = np.array([86, 90, 160])
P_TEAL = np.array([72, 140, 160])
P_WARM = np.array([248, 198, 128])
P_ICE = np.array([168, 200, 255])
P_WHITE = np.array([248, 248, 242])

CX = CANVAS_W / 2.0
CY = CANVAS_H / 2.0


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def make_coords():
    y, x = np.mgrid[0:CANVAS_H, 0:CANVAS_W]
    return x.astype(np.float32), y.astype(np.float32)


def star_field(rng):
    """Static star positions (seeded once)."""
    n = 220
    coords = rng.uniform(0, 1, (n, 2))
    colors = [P_CYAN, P_PURPLE, P_WHITE]
    col = [colors[rng.integers(0, 3)] for _ in range(n)]
    size = rng.uniform(0.6, 1.6, n)
    bright = rng.uniform(0.15, 0.85, n)
    return [(int(coords[k, 0] * CANVAS_W), int(coords[k, 1] * CANVAS_H), col[k], size[k], bright[k]) for k in range(n)]


def draw_stars(img, stars, alpha):
    y, x = np.mgrid[0:CANVAS_H, 0:CANVAS_W].astype(np.float32)
    d = np.hypot(x - CX, (y - CY) * 0.45) / (CANVAS_H * 0.44)
    mask = 1.0 - smoothstep(0.6, 1.0, d)
    for px, py, c, s, b in stars:
        if mask[py, px] <= 0.03:
            continue
        a = 255 * b * mask[py, px] * alpha
        r = max(1, int(s))
        y0, y1 = max(0, py - r), min(CANVAS_H, py + r + 1)
        x0, x1 = max(0, px - r), min(CANVAS_W, px + r + 1)
        for dy in range(y0, y1):
            for dx in range(x0, x1):
                img[dy, dx, 0] = max(img[dy, dx, 0], c[0] / 255.0)
                img[dy, dx, 1] = max(img[dy, dx, 1], c[1] / 255.0)
                img[dy, dx, 2] = max(img[dy, dx, 2], c[2] / 255.0)
                img[dy, dx, 3] = max(img[dy, dx, 3], a / 255.0)


def draw_glow(img, alpha):
    y, x = np.mgrid[0:CANVAS_H, 0:CANVAS_W].astype(np.float32)
    d = np.hypot(x - CX, y - CY)
    fall = 1.0 - smoothstep(0.25, 1.0, d / (R * 2.9))
    a = fall * 0.16 * alpha
    img[..., 0] += a * (P_PURPLE[0] * 0.7 + P_CYAN[0] * 0.3) / 255.0
    img[..., 1] += a * (P_PURPLE[1] * 0.7 + P_CYAN[1] * 0.3) / 255.0
    img[..., 2] += a * (P_PURPLE[2] * 0.7 + P_CYAN[2] * 0.3) / 255.0
    img[..., 3] = np.maximum(img[..., 3], a)


def planet_texture(lat, lon, noise):
    latf = lat * 2.0
    b1 = 0.5 + 0.5 * np.sin(latf * 4.1 + 1.2)
    b2 = 0.5 + 0.5 * np.sin(latf * 6.3 - 2.0)
    b3 = 0.5 + 0.5 * np.sin(latf * 10.5 + 0.4)
    c = (P_INDIGO / 255.0)[None, None, :] * 0.55 + np.zeros((CANVAS_H, CANVAS_W, 3), np.float32)
    c = c + (P_PURPLE / 255.0)[None, None, :] * (0.55 * b1)[..., None]
    c = c + (P_TEAL / 255.0)[None, None, :] * (0.5 * b2 * b2)[..., None]
    c = c + (P_CYAN / 255.0)[None, None, :] * (0.20 * b2 * b3 * b3)[..., None]
    c = c + (P_WARM / 255.0)[None, None, :] * (0.10 * b3)[..., None]
    belt = 0.5 + 0.5 * np.sin(lon * 3.0 + 6.0 * b1)
    streak = np.sin(lon * 7.0 + 12.0 * b2 + 1.7)
    c = c * (0.82 + 0.18 * belt)[..., None]
    c = c + (P_CYAN / 255.0)[None, None, :] * (np.clip(streak, 0, 1) * 0.06 * b2)[..., None]
    c = c + noise[..., None] * 0.03
    return c


def draw_planet(img, rot, noise):
    x, y = make_coords()
    dx = x - CX
    dy = y - CY
    d2 = dx * dx + dy * dy
    mask = d2 <= R * R
    if not mask.any():
        return
    Z = np.sqrt(np.maximum(R * R - d2, 0.0))
    nz = Z / R
    nx = dx / R
    ny = dy / R
    lat = np.arcsin(np.clip(ny, -1, 1))
    lon = np.arctan2(dx, Z) + rot

    nd = nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
    diff = np.clip(nd, 0.0, 1.0)

    tex = planet_texture(lat, lon, noise)
    shade = 0.20 + 0.80 * np.power(diff, 0.8)
    rgb = tex * shade[..., None]

    limb = np.exp(-(np.maximum(1.0 - nz, 0.0) * 2.6) ** 2)
    limb *= smoothstep(-0.05, 0.35, nd)
    rgb += (P_CYAN / 255.0) * limb[..., None] * 0.35

    term = np.exp(-(np.maximum(diff - 0.08, 0.0) / 0.22) ** 2) * 0.18
    rgb += (P_WARM / 255.0) * term[..., None]

    spec = np.clip(2.0 * nd * nz - LIGHT[2], 0, 1)
    spec = np.power(spec, 26.0) * 0.85
    rgb += (P_WHITE / 255.0) * spec[..., None]
    rgb += (P_CYAN / 255.0) * (np.power(spec, 6.0) * 0.2)[..., None]

    img[mask, 0] = np.maximum(img[mask, 0], rgb[mask, 0])
    img[mask, 1] = np.maximum(img[mask, 1], rgb[mask, 1])
    img[mask, 2] = np.maximum(img[mask, 2], rgb[mask, 2])
    img[mask, 3] = 1.0


def draw_ring(img, tilt, half):
    st = math.sin(tilt)
    if st <= 0.02:
        return
    x, y = make_coords()
    y_ring = (y - CY) / st
    rr = np.hypot(x - CX, y_ring)
    phi = np.arctan2(y_ring, x - CX)
    in_band = ((rr >= RING_IN1) & (rr <= RING_OUT1)) | ((rr >= RING_IN2) & (rr <= RING_OUT2))
    if half == "back":
        in_band &= y_ring < 0
    else:
        in_band &= y_ring >= 0
    if not in_band.any():
        return
    frac = np.where(rr <= RING_IN1, (rr - RING_IN1) / (RING_OUT1 - RING_IN1),
                    (rr - RING_IN2) / (RING_OUT2 - RING_IN2))
    edge = np.sin(frac * np.pi)

    light_ang = math.atan2(LIGHT[1] / st, LIGHT[0])
    lit = 0.70 + 0.30 * np.maximum(0.0, np.cos(phi - light_ang))
    a1 = (x - CX) * LIGHT[0] + y_ring * LIGHT[1]
    cr = np.abs((x - CX) * LIGHT[1] - y_ring * LIGHT[0])
    lit[(a1 > 0) & (cr < R)] *= 0.18

    warm = 0.5 + 0.5 * np.cos(phi - 0.9)
    c = (P_ICE / 255.0)[None, None, :] * (1.0 - 0.35 * warm)[..., None]
    c = c + (P_WARM / 255.0)[None, None, :] * (0.30 * warm)[..., None]
    c = c + (P_CYAN / 255.0)[None, None, :] * (0.10 * (0.5 + 0.5 * np.sin(phi * 2.0)))[..., None]
    c = c + (P_PURPLE / 255.0)[None, None, :] * (0.06 * (0.5 + 0.5 * np.cos(phi * 3.0 + 2.0)))[..., None]

    alpha = np.clip((0.70 + 0.22 * edge) * lit, 0.0, 0.97)
    sel = in_band
    rgb = np.clip(c[sel], 0.0, 1.0) * alpha[sel, None]
    img[sel, 0] = np.maximum(img[sel, 0], rgb[:, 0])
    img[sel, 1] = np.maximum(img[sel, 1], rgb[:, 1])
    img[sel, 2] = np.maximum(img[sel, 2], rgb[:, 2])
    img[sel, 3] = np.maximum(img[sel, 3], alpha[sel])


def draw_moon(img, tilt, ang):
    st = math.sin(tilt)
    if st <= 0.02:
        return
    px = CX + MOON_ORBIT * math.cos(ang)
    py = CY + MOON_ORBIT * st * math.sin(ang)
    x0, x1 = max(0, int(px - MOON_R * 2)), min(CANVAS_W, int(px + MOON_R * 2) + 1)
    y0, y1 = max(0, int(py - MOON_R * 2)), min(CANVAS_H, int(py + MOON_R * 2) + 1)
    if x1 <= x0 or y1 <= y0:
        return
    sy, sx = np.mgrid[y0:y1, x0:x1].astype(np.float32)
    d = np.hypot(sx - px, sy - py)
    m = d <= MOON_R
    if not m.any():
        return
    z = np.sqrt(np.maximum(MOON_R * MOON_R - d * d, 0)) / MOON_R
    nd = (sx - px) / MOON_R * LIGHT[0] + (sy - py) / MOON_R * LIGHT[1] + z * LIGHT[2]
    lit = np.clip(0.22 + 0.78 * nd, 0.0, 1.0)
    glow = np.exp(-np.maximum(d - MOON_R, 0) / 9.0) * 0.45
    sel = m | (glow > 0.02)
    a = np.where(m, 1.0, glow)
    rgb = (P_WHITE / 255.0) * lit[..., None]
    rgb += (P_CYAN / 255.0) * glow[..., None]
    v = img[y0:y1, x0:x1]
    v[sel, 0] = np.maximum(v[sel, 0], rgb[sel, 0] * a[sel])
    v[sel, 1] = np.maximum(v[sel, 1], rgb[sel, 1] * a[sel])
    v[sel, 2] = np.maximum(v[sel, 2], rgb[sel, 2] * a[sel])
    v[sel, 3] = np.maximum(v[sel, 3], a[sel])


def ring_shadow_on_planet(img, tilt):
    """Crescent shadow the front ring arc casts onto the planet's disk."""
    st = math.sin(tilt)
    if st <= 0.02:
        return
    x, y = make_coords()
    dx = x - CX
    dy = y - CY
    disk = dx * dx + dy * dy <= R * R
    if not disk.any():
        return
    half = np.sqrt(np.maximum(RING_OUT2 * RING_OUT2 - dx * dx, 0.0))
    below = y > CY + st * half
    sel = disk & below
    if not sel.any():
        return
    # soft vertical falloff under the ring
    depth = np.clip((y - (CY + st * half)) / (R * 0.55), 0.0, 1.0)
    k = 0.42 * (1.0 - depth * 0.5)
    img[sel, 0] -= k[sel] * img[sel, 0]
    img[sel, 1] -= k[sel] * img[sel, 1]
    img[sel, 2] -= k[sel] * img[sel, 2]


def render_frame(i, n_frames, noise, stars):
    rot = 2.0 * math.pi * 2.0 * i / n_frames       # planet spins twice per loop
    tilt = TILT_CENTER + TILT_AMP * math.sin(2.0 * math.pi * i / n_frames - math.pi / 2.0)
    moon = 2.0 * math.pi * i / n_frames            # moon completes one orbit per loop

    img = np.zeros((CANVAS_H, CANVAS_W, 4), np.float32)
    draw_glow(img, 1.0)
    draw_stars(img, stars, 1.0)
    draw_ring(img, tilt, "back")
    if math.sin(moon) < 0:                          # moon in the back half of the ring plane
        draw_moon(img, tilt, moon)
    draw_planet(img, rot, noise)
    ring_shadow_on_planet(img, tilt)
    if math.sin(moon) >= 0:
        draw_moon(img, tilt, moon)
    draw_ring(img, tilt, "front")

    arr = np.clip(img * 255.0, 0, 255).astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


def quantize(im, colors=224):
    return im.quantize(colors=colors, method=Image.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)


def graphic_chunks(cmd, data, action):
    b64 = base64.b64encode(data).decode("ascii")
    out = []
    i = 0
    while i < len(b64):
        piece = b64[i:i + 4096]
        more = 1 if i + 4096 < len(b64) else 0
        if i == 0:
            out.append(f"\x1b_G{cmd},m={more};{piece}\x1b\\")
        else:
            out.append(f"\x1b_Ga={action},q=1,m={more};{piece}\x1b\\")
        i += 4096
    return "".join(out)


def build_esc(frames, gap_ms):
    lines = []
    payloads = []
    for f in frames:
        buf = io.BytesIO()
        f.save(buf, format="PNG", optimize=True)
        payloads.append(buf.getvalue())

    lines.append(graphic_chunks("a=t,f=100,s=%d,v=%d,i=1,q=1" % (CANVAS_W, CANVAS_H), payloads[0], "t"))
    for k, data in enumerate(payloads[1:], start=2):
        lines.append(graphic_chunks("a=f,f=100,i=1,r=%d,z=%d,q=1" % (k, gap_ms), data, "f"))
    lines.append(f"\x1b_Ga=a,i=1,s=3,v=1,r=1,z={gap_ms},q=1\x1b\\")
    lines.append(f"\x1b_Ga=p,i=1,c={COLS},r={ROWS},C=1,z=1,q=1\x1b\\")
    return "".join(lines)


def load_gap():
    gap = 110
    try:
        with open(CONFIG_PATH, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    try:
                        gap = int(line.split("=", 1)[1].strip())
                    except ValueError:
                        pass
    except FileNotFoundError:
        pass
    return gap


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gap", type=int, default=None, help="ms between frames (default: config file)")
    ap.add_argument("--frames", type=int, default=60, help="number of frames")
    args = ap.parse_args()

    gap = args.gap if args.gap is not None else load_gap()
    n = args.frames
    os.makedirs(FRAMES_DIR, exist_ok=True)

    noise = np.random.default_rng(11).normal(0, 1, (CANVAS_H, CANVAS_W)).astype(np.float32)
    stars = star_field(np.random.default_rng(42))

    frames = []
    for i in range(n):
        im = render_frame(i, n, noise, stars)
        im = quantize(im)
        path = os.path.join(FRAMES_DIR, f"frame_{i:03d}.png")
        im.save(path, format="PNG", optimize=True)
        frames.append(im)
        if i % 15 == 0:
            print(f"  rendered {i}/{n}")

    placeholder = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    placeholder.save(PLACEHOLDER_PATH, format="PNG")

    esc = build_esc(frames, gap)
    with open(ESC_PATH, "w") as f:
        f.write(esc)

    total = sum(os.path.getsize(os.path.join(FRAMES_DIR, f"frame_{i:03d}.png")) for i in range(n))
    print(f"done: {n} frames, gap={gap}ms, frames={total // 1024}KB, esc={len(esc) // 1024}KB")


if __name__ == "__main__":
    main()
