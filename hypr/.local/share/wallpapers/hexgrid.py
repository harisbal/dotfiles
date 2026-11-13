#!/usr/bin/env python3
"""Generate a futuristic hex-grid wallpaper as SVG (stdlib only)."""
import math, random, sys

W, H = 2880, 1800          # 16:10, matches the 1920x1200 panel (rendered 1.5x for crispness)
R = 54                     # hex circumradius
TEAL, ORANGE = "#3a8f93", "#ff7a3d"
CYAN = "#7fe3e8"
random.seed(7)

hw = math.sqrt(3) * R      # pointy-top hex width
vs = 1.5 * R               # vertical spacing

def hex_pts(cx, cy, r=R):
    return [(cx + r * math.cos(math.radians(60 * i - 30)),
             cy + r * math.sin(math.radians(60 * i - 30))) for i in range(6)]

def path(pts):
    return "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in pts) + " Z"

# focal point (off-centre, lower right) -> intensity falls off with distance
FX, FY = W * 0.68, H * 0.58
def glow(cx, cy):
    d = math.hypot(cx - FX, cy - FY) / (W * 0.55)
    return max(0.0, 1 - d) ** 1.6

cells = []
row = 0
y = -R
while y < H + R:
    x = -hw + (hw / 2 if row % 2 else 0)
    while x < W + hw:
        cells.append((x, y))
        x += hw
    y += vs
    row += 1

base, lit, fills = [], [], []
for cx, cy in cells:
    g = glow(cx, cy)
    pts = hex_pts(cx, cy)
    base.append(path(pts))
    # randomly lit outlines, more likely near focus
    if random.random() < 0.05 + 0.35 * g:
        col = ORANGE if random.random() < 0.18 * (0.4 + g) else CYAN
        lit.append((path(pts), col, 0.35 + 0.6 * g))
    # filled cells
    if random.random() < 0.02 + 0.22 * g:
        col = ORANGE if random.random() < 0.15 else TEAL
        fills.append((path(hex_pts(cx, cy, R - 4)), col, 0.10 + 0.38 * g))

# fine square grid (perspective-free, very faint)
step = 36
vlines = "".join(f'<path d="M{x},0 V{H}"/>' for x in range(0, W + 1, step))
hlines = "".join(f'<path d="M0,{y} H{W}"/>' for y in range(0, H + 1, step))

# circuit-style traces: random walks along the hex lattice edges
adj = {}
def key(p): return (round(p[0]), round(p[1]))
for cx, cy in cells:
    pts = hex_pts(cx, cy)
    for i in range(6):
        p, q = pts[i], pts[(i + 1) % 6]
        adj.setdefault(key(p), set()).add(key(q))
        adj.setdefault(key(q), set()).add(key(p))
starts = [k for k in adj if glow(*k) > 0.2]
traces, heads = [], []
for _ in range(16):
    cur = random.choice(starts); prev = None
    pts = [cur]
    for _ in range(random.randint(5, 12)):
        opts = [n for n in adj[cur] if n != prev]
        if not opts: break
        prev, cur = cur, random.choice(opts)
        pts.append(cur)
    traces.append("M" + " L".join(f"{x},{y}" for x, y in pts))
    heads.append((pts[0], pts[-1]))

out = []
a = out.append
a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
a('''<defs>
  <radialGradient id="bg" cx="68%" cy="58%" r="85%">
    <stop offset="0" stop-color="#0f2a33"/>
    <stop offset="0.45" stop-color="#0a1a22"/>
    <stop offset="1" stop-color="#050b10"/>
  </radialGradient>
  <radialGradient id="halo" cx="68%" cy="58%" r="45%">
    <stop offset="0" stop-color="#3a8f93" stop-opacity="0.30"/>
    <stop offset="0.6" stop-color="#3a8f93" stop-opacity="0.06"/>
    <stop offset="1" stop-color="#3a8f93" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="ember" cx="80%" cy="72%" r="30%">
    <stop offset="0" stop-color="#ff7a3d" stop-opacity="0.16"/>
    <stop offset="1" stop-color="#ff7a3d" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="vig" cx="50%" cy="50%" r="75%">
    <stop offset="0.55" stop-color="#000" stop-opacity="0"/>
    <stop offset="1" stop-color="#000" stop-opacity="0.65"/>
  </radialGradient>
  <filter id="blur" x="-10%" y="-10%" width="120%" height="120%"><feGaussianBlur stdDeviation="7"/></filter>
</defs>''')
a(f'<rect width="{W}" height="{H}" fill="url(#bg)"/>')
a(f'<g stroke="{TEAL}" stroke-opacity="0.045" stroke-width="1">{vlines}{hlines}</g>')
a(f'<rect width="{W}" height="{H}" fill="url(#halo)"/>')
a(f'<rect width="{W}" height="{H}" fill="url(#ember)"/>')
# base hex lattice
a(f'<path d="{" ".join(base)}" fill="none" stroke="{TEAL}" stroke-opacity="0.16" stroke-width="1.5"/>')
# filled cells (glow layer + crisp layer)
a('<g filter="url(#blur)">' + "".join(
    f'<path d="{d}" fill="{c}" fill-opacity="{o:.2f}"/>' for d, c, o in fills) + '</g>')
a("<g>" + "".join(
    f'<path d="{d}" fill="{c}" fill-opacity="{o*0.55:.2f}"/>' for d, c, o in fills) + "</g>")
# lit outlines (glow + crisp)
a('<g filter="url(#blur)" fill="none" stroke-width="3">' + "".join(
    f'<path d="{d}" stroke="{c}" stroke-opacity="{o:.2f}"/>' for d, c, o in lit) + '</g>')
a('<g fill="none" stroke-width="1.6" stroke-linejoin="round">' + "".join(
    f'<path d="{d}" stroke="{c}" stroke-opacity="{min(1, o + 0.2):.2f}"/>' for d, c, o in lit) + '</g>')
# traces + nodes
a(f'<g fill="none" stroke="{CYAN}" stroke-opacity="0.7" stroke-width="2.5" stroke-linejoin="round">'
  + "".join(f'<path d="{d}"/>' for d in traces) + '</g>')
a(f'<g fill="{CYAN}">' + "".join(
    f'<circle cx="{p[0]}" cy="{p[1]}" r="5" fill-opacity="0.95"/>' for h in heads for p in h) + '</g>')
a(f'<rect width="{W}" height="{H}" fill="url(#vig)"/>')
a('</svg>')

open(sys.argv[1], "w").write("\n".join(out))
print("cells:", len(cells), "lit:", len(lit), "filled:", len(fills))
