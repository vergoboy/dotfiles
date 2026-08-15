#!/usr/bin/env python3
"""Validate animation.esc: reassemble base64 chunks and compare to source frames."""
import base64
import os
import sys
from PIL import Image

ESC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "animation.esc")
FRAMES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frames")

data = open(ESC, "rb").read()

cmds = []
ctrls = []
for part in data.split(b"\x1b\\"):
    if not part:
        continue
    if b"\x1b_" in part:
        esc = part.rpartition(b"\x1b_")[2]
        body = esc[1:] if esc[:1] == b"G" else esc
        if b";" in body:
            head, _, payload = body.partition(b";")
        else:
            head, payload = body, b""
        cmds.append((head.decode("ascii", "replace"), payload))
    else:
        ctrls.append(part)

print(f"total escapes: {len(cmds)}, control seqs: {[c.decode() for c in ctrls]}")

import re

groups = []      # (head, [payload chunks])
CONT = re.compile(r"^a=(t|f),q=1,m=[01]$")
for head, payload in cmds:
    if head.startswith("m=") or CONT.match(head):
        groups[-1][1].append(payload)
    else:
        groups.append([head, [payload]])

frames_rebuilt = []
root_found = False
frame_count = 0
gaps = []
anim_ctrl = None
put = None

for head, chunks in groups:
    if head.startswith("m="):
        continue
    cmd = head[2:] if head.startswith("G") else head
    is_data = cmd.startswith(("a=t", "a=T", "a=f"))
    if is_data:
        payload = b"".join(chunks)
        raw = base64.b64decode(payload)
        im = Image.open(__import__("io").BytesIO(raw))
        if cmd.startswith("a=t") or cmd.startswith("a=T"):
            root_found = True
            frames_rebuilt.append(im)
        elif cmd.startswith("a=f"):
            frame_count += 1
            frames_rebuilt.append(im)
    elif cmd.startswith("a=a"):
        anim_ctrl = cmd
    elif cmd.startswith("a=p"):
        put = cmd

print(f"root frame: {root_found}, extra frames: {frame_count}, total: {len(frames_rebuilt)}")

ok = True
for i, im in enumerate(frames_rebuilt):
    src = os.path.join(FRAMES, f"frame_{i:03d}.png")
    if not os.path.exists(src):
        print(f"MISSING source {src}")
        ok = False
        continue
    a = Image.open(src).convert("RGBA")
    if list(im.size) != list(a.size):
        print(f"frame {i}: size mismatch {im.size} vs {a.size}")
        ok = False
        continue
    if im.convert("RGBA").tobytes() != a.tobytes():
        print(f"frame {i}: PIXEL MISMATCH")
        ok = False
    else:
        print(f"frame {i:02d}: ok")
print("RESULT:", "OK" if ok else "FAIL")
print("anim control:", anim_ctrl)
print("put:", put)
