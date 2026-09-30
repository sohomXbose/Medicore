"""
MediCore — Chen ER Diagram Generator (v2 — No Overlaps)
Generates a clean, properly-spaced Chen-notation ER diagram using matplotlib.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Polygon
import numpy as np
import math

# ─── CONFIG ──────────────────────────────────────────────────────────────
FIG_W, FIG_H = 72, 58
BG = "#FFFFFF"

# Colors
C_ENT     = ("#D6EAF8", "#2471A3")   # Strong entity fill, border
C_WEAK    = ("#D1F2EB", "#17A589")   # Weak entity
C_REL     = ("#FADBD8", "#C0392B")   # Relationship
C_IDREL   = ("#FCF3CF", "#B7950B")   # Identifying relationship
C_KEY     = ("#FEF9E7", "#B7950B")   # Key attribute
C_ATTR    = ("#F4ECF7", "#7D3C98")   # Normal attribute
C_DER     = ("#F2F3F4", "#616A6B")   # Derived attribute
C_LINE    = "#34495E"
C_TXT     = "#1B2631"
C_CARD    = "#C0392B"

ENT_W, ENT_H = 3.6, 1.3
REL_S = 1.15
ATTR_RX, ATTR_RY = 1.25, 0.45


# ─── DRAWING PRIMITIVES ─────────────────────────────────────────────────

def draw_entity(ax, x, y, label, weak=False):
    fc, ec = C_WEAK if weak else C_ENT
    lw = 2.8 if weak else 2
    rect = FancyBboxPatch((x - ENT_W/2, y - ENT_H/2), ENT_W, ENT_H,
                           boxstyle="round,pad=0.08", facecolor=fc,
                           edgecolor=ec, linewidth=lw, zorder=10)
    ax.add_patch(rect)
    if weak:
        inner = FancyBboxPatch((x - ENT_W/2 + 0.14, y - ENT_H/2 + 0.1),
                                ENT_W - 0.28, ENT_H - 0.2,
                                boxstyle="round,pad=0.05", facecolor=fc,
                                edgecolor=ec, linewidth=1.8, zorder=11)
        ax.add_patch(inner)
    ax.text(x, y, label, ha='center', va='center', fontsize=9,
            fontweight='bold', color=C_TXT, zorder=12, fontfamily='serif')


def draw_diamond(ax, x, y, label, identifying=False):
    s = REL_S
    verts = [(x, y+s), (x+s*1.5, y), (x, y-s), (x-s*1.5, y)]
    fc, ec = C_IDREL if identifying else C_REL
    lw = 2.8 if identifying else 2
    poly = Polygon(verts, closed=True, facecolor=fc, edgecolor=ec,
                   linewidth=lw, zorder=10)
    ax.add_patch(poly)
    if identifying:
        s2 = s * 0.76
        v2 = [(x, y+s2), (x+s2*1.5, y), (x, y-s2), (x-s2*1.5, y)]
        p2 = Polygon(v2, closed=True, facecolor=fc, edgecolor=ec,
                     linewidth=1.5, zorder=11)
        ax.add_patch(p2)
    ax.text(x, y, label, ha='center', va='center', fontsize=7,
            fontweight='bold', color=C_TXT, zorder=12, fontfamily='serif',
            style='italic')


def draw_attr(ax, x, y, label, key=False, derived=False, partial_key=False):
    ls = '--' if derived else '-'
    if key or partial_key:
        fc, ec = C_KEY
    elif derived:
        fc, ec = C_DER
    else:
        fc, ec = C_ATTR
    lw = 2 if key else 1.3
    ell = mpatches.Ellipse((x, y), ATTR_RX*2, ATTR_RY*2,
                            facecolor=fc, edgecolor=ec,
                            linewidth=lw, linestyle=ls, zorder=8)
    ax.add_patch(ell)
    ax.text(x, y, label, ha='center', va='center', fontsize=6.2,
            fontweight='bold' if key else 'normal', color=C_TXT,
            zorder=9, fontfamily='serif')
    if key or partial_key:
        tw = len(label) * 0.06
        uls = '--' if partial_key else '-'
        ax.plot([x-tw, x+tw], [y-0.16, y-0.16], color=ec,
                linewidth=1.5, linestyle=uls, zorder=10)


def draw_line(ax, x1, y1, x2, y2, total=False):
    ax.plot([x1, x2], [y1, y2], color=C_LINE, linewidth=1.3, zorder=3)
    if total:
        dx, dy = x2-x1, y2-y1
        l = math.hypot(dx, dy)
        if l > 0:
            nx, ny = -dy/l*0.07, dx/l*0.07
            ax.plot([x1+nx, x2+nx], [y1+ny, y2+ny], color=C_LINE, linewidth=2, zorder=3)
            ax.plot([x1-nx, x2-nx], [y1-ny, y2-ny], color=C_LINE, linewidth=2, zorder=3)


def draw_card(ax, x, y, label):
    ax.text(x, y, label, ha='center', va='center', fontsize=8,
            fontweight='bold', color=C_CARD, zorder=15, fontfamily='serif',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white',
                      edgecolor=C_CARD, linewidth=0.8, alpha=0.95))


def connect_to_entity(ax, ex, ey, ax_, ay):
    """Smart edge-point on entity rect boundary towards (ax_, ay)."""
    dx, dy = ax_ - ex, ay - ey
    if abs(dx) < 0.01 and abs(dy) < 0.01:
        return ex, ey
    sx = ENT_W/2 / abs(dx) if abs(dx) > 0.01 else 999
    sy = ENT_H/2 / abs(dy) if abs(dy) > 0.01 else 999
    s = min(sx, sy)
    return ex + dx*s, ey + dy*s


def connect_to_diamond(ax, dx, dy, tx, ty):
    """Get edge point of diamond towards target."""
    ddx, ddy = tx - dx, ty - dy
    if abs(ddx) < 0.01 and abs(ddy) < 0.01:
        return dx, dy
    ang = math.atan2(ddy, ddx)
    # Diamond shape: |x|/1.5s + |y|/s = 1
    ca, sa = abs(math.cos(ang)), abs(math.sin(ang))
    denom = ca / (REL_S * 1.5) + sa / REL_S
    r = 1.0 / denom if denom > 0 else REL_S
    return dx + r * math.cos(ang), dy + r * math.sin(ang)


def fan_attrs(ax, ex, ey, attrs, start_ang, end_ang, radius=2.5):
    """Place attributes in a fan arc around entity."""
    n = len(attrs)
    if n == 0:
        return
    angles = np.linspace(np.radians(start_ang), np.radians(end_ang), n)
    for i, (name, atype) in enumerate(attrs):
        a = angles[i]
        ax_, ay = ex + radius * np.cos(a), ey + radius * np.sin(a)
        is_key = atype == 'key'
        is_der = atype == 'derived'
        is_pk  = atype == 'partial'
        draw_attr(ax, ax_, ay, name, key=is_key, derived=is_der, partial_key=is_pk)
        # line from entity edge to attribute
        bx, by = connect_to_entity(ax, ex, ey, ax_, ay)
        draw_line(ax, bx, by, ax_, ay)


def connect_rel(ax, e1x, e1y, e2x, e2y, rx, ry, c1, c2,
                identifying=False, total_e1=False, total_e2=False,
                c1_offset=(0, 0.4), c2_offset=(0, 0.4)):
    """Draw two lines from entities to relationship diamond, with cardinality."""
    # Entity1 -> Diamond
    b1 = connect_to_entity(ax, e1x, e1y, rx, ry)
    d1 = connect_to_diamond(ax, rx, ry, e1x, e1y)
    draw_line(ax, b1[0], b1[1], d1[0], d1[1], total=total_e1)
    # Diamond -> Entity2
    d2 = connect_to_diamond(ax, rx, ry, e2x, e2y)
    b2 = connect_to_entity(ax, e2x, e2y, rx, ry)
    draw_line(ax, d2[0], d2[1], b2[0], b2[1], total=total_e2)
    # Cardinality labels near entities
    cx1 = b1[0]*0.65 + d1[0]*0.35 + c1_offset[0]
    cy1 = b1[1]*0.65 + d1[1]*0.35 + c1_offset[1]
    cx2 = b2[0]*0.65 + d2[0]*0.35 + c2_offset[0]
    cy2 = b2[1]*0.65 + d2[1]*0.35 + c2_offset[1]
    draw_card(ax, cx1, cy1, c1)
    draw_card(ax, cx2, cy2, c2)


# ══════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════
fig, ax = plt.subplots(1, 1, figsize=(FIG_W, FIG_H))
ax.set_xlim(-3, 69)
ax.set_ylim(-3, 55)
ax.set_aspect('equal')
ax.axis('off')
fig.patch.set_facecolor(BG)
ax.set_facecolor(BG)

# Title
ax.text(33, 54, "MediCore — Entity-Relationship Diagram (Chen Notation)",
        ha='center', va='center', fontsize=24, fontweight='bold',
        color='#1B2631', fontfamily='serif')
ax.text(33, 53, "Rectangle = Strong Entity  |  Double Rectangle = Weak Entity  |  "
        "Diamond = Relationship  |  Double Diamond = Identifying Relationship",
        ha='center', va='center', fontsize=10, color='#5D6D7E', fontfamily='serif')
ax.text(33, 52.2, "Underlined = Primary Key  |  Dashed underline = Partial Key  |  "
        "Dashed oval = Derived  |  Double line (==) = Total Participation  |  "
        "Red = Cardinality",
        ha='center', va='center', fontsize=10, color='#5D6D7E', fontfamily='serif')

# ══════════════════════════════════════════════════════════════════════════
# ENTITY POSITIONS — spread out generously
# ══════════════════════════════════════════════════════════════════════════
E = {
    # Administration cluster (top)
    'DEPARTMENT':       ( 8, 49),
    'STAFF':            (28, 49),
    'USER_SESSION':     (46, 49),

    # Medical staff cluster
    'DOCTOR':           (18, 42),
    'DOCTOR_SCHEDULE':  ( 5, 37),

    # Clinical core cluster (center)
    'PATIENT':          (35, 38),
    'APPOINTMENT':      (18, 33),
    'TREATMENT':        (25, 26),
    'LAB_TEST':         (50, 33),

    # Ward cluster (right)
    'ROOM':             (58, 46),
    'BED':              (64, 40),
    'ADMISSION':        (55, 27),

    # Pharmacy cluster (left)
    'PRESCRIPTION':     (12, 20),
    'PRESCRIPTION_ITEM':( 5, 12),
    'MEDICINE':         (18, 8),

    # Billing cluster (bottom-center)
    'BILL':             (38, 15),
    'BILL_ITEM':        (50, 8),
    'PAYMENT':          (28, 8),

    # Misc (bottom-right)
    'NOTIFICATION':     (60, 18),
    'AUDIT_LOG':        (64, 10),
}

# Draw entities
WEAK = {'BED', 'PRESCRIPTION_ITEM', 'BILL_ITEM'}
for name, (x, y) in E.items():
    draw_entity(ax, x, y, name, weak=(name in WEAK))

# ══════════════════════════════════════════════════════════════════════════
# ATTRIBUTES — fanned out away from crowded areas
# ══════════════════════════════════════════════════════════════════════════

# DEPARTMENT — attrs fan upward-left
fan_attrs(ax, *E['DEPARTMENT'], [
    ('department_id', 'key'),
    ('department_name', 'normal'),
], start_ang=100, end_ang=160, radius=2.6)

# STAFF — attrs fan upward
fan_attrs(ax, *E['STAFF'], [
    ('staff_id', 'key'),
    ('full_name', 'normal'),
    ('email', 'normal'),
    ('password_hash', 'normal'),
    ('role', 'normal'),
    ('created_at', 'normal'),
], start_ang=60, end_ang=160, radius=2.8)

# USER_SESSION — attrs fan upward-right
fan_attrs(ax, *E['USER_SESSION'], [
    ('session_id', 'key'),
    ('login_time', 'normal'),
    ('logout_time', 'normal'),
], start_ang=30, end_ang=135, radius=2.5)

# DOCTOR — attrs fan left-upward
fan_attrs(ax, *E['DOCTOR'], [
    ('doctor_id', 'key'),
    ('specialization', 'normal'),
], start_ang=110, end_ang=160, radius=2.5)

# DOCTOR_SCHEDULE — attrs fan left and down
fan_attrs(ax, *E['DOCTOR_SCHEDULE'], [
    ('schedule_id', 'key'),
    ('day_of_week', 'normal'),
    ('start_time', 'normal'),
    ('end_time', 'normal'),
], start_ang=150, end_ang=250, radius=2.6)

# PATIENT — attrs fan upward and right (away from center)
fan_attrs(ax, *E['PATIENT'], [
    ('patient_id', 'key'),
    ('full_name', 'normal'),
    ('dob', 'normal'),
    ('gender', 'normal'),
    ('phone', 'normal'),
    ('blood_group', 'normal'),
    ('balance_due', 'derived'),
], start_ang=30, end_ang=160, radius=3.0)

# APPOINTMENT — attrs fan left
fan_attrs(ax, *E['APPOINTMENT'], [
    ('appointment_id', 'key'),
    ('appt_date', 'normal'),
    ('appt_time', 'normal'),
    ('reason', 'normal'),
    ('status', 'normal'),
], start_ang=170, end_ang=280, radius=2.7)

# TREATMENT — attrs fan downward-left
fan_attrs(ax, *E['TREATMENT'], [
    ('treatment_id', 'key'),
    ('diagnosis', 'normal'),
    ('treatment_notes', 'normal'),
    ('treatment_date', 'normal'),
], start_ang=200, end_ang=330, radius=2.7)

# LAB_TEST — attrs fan right
fan_attrs(ax, *E['LAB_TEST'], [
    ('lab_test_id', 'key'),
    ('test_type', 'normal'),
    ('requested_date', 'normal'),
    ('result', 'normal'),
    ('status', 'normal'),
], start_ang=30, end_ang=150, radius=2.7)

# ROOM — attrs fan upward
fan_attrs(ax, *E['ROOM'], [
    ('room_id', 'key'),
    ('room_number', 'normal'),
    ('ward_type', 'normal'),
], start_ang=50, end_ang=140, radius=2.5)

# BED — attrs fan right
fan_attrs(ax, *E['BED'], [
    ('bed_number', 'partial'),
    ('is_occupied', 'normal'),
], start_ang=10, end_ang=70, radius=2.5)

# ADMISSION — attrs fan right and down
fan_attrs(ax, *E['ADMISSION'], [
    ('admission_id', 'key'),
    ('admission_date', 'normal'),
    ('discharge_date', 'normal'),
], start_ang=-30, end_ang=50, radius=2.6)

# PRESCRIPTION — attrs fan left
fan_attrs(ax, *E['PRESCRIPTION'], [
    ('prescription_id', 'key'),
    ('prescribed_date', 'normal'),
], start_ang=130, end_ang=200, radius=2.5)

# PRESCRIPTION_ITEM — attrs fan left-down
fan_attrs(ax, *E['PRESCRIPTION_ITEM'], [
    ('presc_item_id', 'key'),
    ('dosage', 'normal'),
    ('frequency', 'normal'),
    ('duration_days', 'normal'),
], start_ang=180, end_ang=300, radius=2.6)

# MEDICINE — attrs fan down and left
fan_attrs(ax, *E['MEDICINE'], [
    ('medicine_id', 'key'),
    ('medicine_name', 'normal'),
    ('unit_price', 'normal'),
    ('stock_qty', 'normal'),
    ('reorder_level', 'normal'),
], start_ang=150, end_ang=330, radius=2.7)

# BILL — attrs fan upward-left (away from billing area)
fan_attrs(ax, *E['BILL'], [
    ('bill_id', 'key'),
    ('bill_date', 'normal'),
    ('total_amount', 'derived'),
], start_ang=100, end_ang=180, radius=2.5)

# BILL_ITEM — attrs fan right and down
fan_attrs(ax, *E['BILL_ITEM'], [
    ('bill_item_id', 'key'),
    ('item_type', 'normal'),
    ('description', 'normal'),
    ('amount', 'normal'),
], start_ang=-20, end_ang=90, radius=2.6)

# PAYMENT — attrs fan down
fan_attrs(ax, *E['PAYMENT'], [
    ('payment_id', 'key'),
    ('payment_date', 'normal'),
    ('amount_paid', 'normal'),
    ('payment_mode', 'normal'),
], start_ang=200, end_ang=340, radius=2.6)

# NOTIFICATION — attrs fan right
fan_attrs(ax, *E['NOTIFICATION'], [
    ('notification_id', 'key'),
    ('message', 'normal'),
    ('notif_type', 'normal'),
    ('is_read', 'normal'),
], start_ang=-30, end_ang=80, radius=2.6)

# AUDIT_LOG — attrs fan right and down
fan_attrs(ax, *E['AUDIT_LOG'], [
    ('audit_id', 'key'),
    ('table_name', 'normal'),
    ('record_id', 'normal'),
    ('operation', 'normal'),
    ('old_data', 'normal'),
    ('changed_by', 'normal'),
], start_ang=-60, end_ang=80, radius=2.8)

# ══════════════════════════════════════════════════════════════════════════
# RELATIONSHIPS — diamonds placed midway between connected entities
# ══════════════════════════════════════════════════════════════════════════

def mid(e1, e2, bias=0.5, ox=0, oy=0):
    x1, y1 = E[e1]; x2, y2 = E[e2]
    return x1 + (x2-x1)*bias + ox, y1 + (y2-y1)*bias + oy

# 1) DEPARTMENT (1) -- BELONGS_TO -- (N) DOCTOR
rx, ry = mid('DEPARTMENT', 'DOCTOR', 0.5)
draw_diamond(ax, rx, ry, "BELONGS\nTO")
connect_rel(ax, *E['DEPARTMENT'], *E['DOCTOR'], rx, ry, "1", "N",
            c1_offset=(0.5, 0.3), c2_offset=(-0.5, 0.3))

# 2) STAFF (1) -- IS_A -- (0..1) DOCTOR
rx, ry = mid('STAFF', 'DOCTOR', 0.5)
draw_diamond(ax, rx, ry, "IS_A")
connect_rel(ax, *E['STAFF'], *E['DOCTOR'], rx, ry, "1", "0..1",
            c1_offset=(0.5, 0.3), c2_offset=(-0.5, 0.3))

# 3) STAFF (1) -- CREATES -- (N) USER_SESSION
rx, ry = mid('STAFF', 'USER_SESSION', 0.5)
draw_diamond(ax, rx, ry, "CREATES")
connect_rel(ax, *E['STAFF'], *E['USER_SESSION'], rx, ry, "1", "N",
            c1_offset=(0, 0.5), c2_offset=(0, 0.5))

# 4) DOCTOR (1) -- HAS_SCHEDULE -- (N) DOCTOR_SCHEDULE
rx, ry = mid('DOCTOR', 'DOCTOR_SCHEDULE', 0.5, ox=0, oy=1)
draw_diamond(ax, rx, ry, "HAS\nSCHED.")
connect_rel(ax, *E['DOCTOR'], *E['DOCTOR_SCHEDULE'], rx, ry, "1", "N",
            c1_offset=(-0.5, 0.5), c2_offset=(0.5, 0.5))

# 5) PATIENT (1) -- BOOKS -- (N) APPOINTMENT
rx, ry = mid('PATIENT', 'APPOINTMENT', 0.45, oy=1)
draw_diamond(ax, rx, ry, "BOOKS")
connect_rel(ax, *E['PATIENT'], *E['APPOINTMENT'], rx, ry, "1", "N",
            c1_offset=(-0.5, 0.4), c2_offset=(0.5, 0.4))

# 6) DOCTOR (1) -- ATTENDS -- (N) APPOINTMENT
rx, ry = mid('DOCTOR', 'APPOINTMENT', 0.5, ox=-1)
draw_diamond(ax, rx, ry, "ATTENDS")
connect_rel(ax, *E['DOCTOR'], *E['APPOINTMENT'], rx, ry, "1", "N",
            c1_offset=(0.5, 0.3), c2_offset=(-0.5, 0.3))

# 7) APPOINTMENT (1) -- LEADS_TO -- (0..1) TREATMENT
rx, ry = mid('APPOINTMENT', 'TREATMENT', 0.5)
draw_diamond(ax, rx, ry, "LEADS\nTO")
connect_rel(ax, *E['APPOINTMENT'], *E['TREATMENT'], rx, ry, "1", "0..1",
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 8) PATIENT (1) -- UNDERGOES -- (N) TREATMENT
rx, ry = mid('PATIENT', 'TREATMENT', 0.5, ox=2)
draw_diamond(ax, rx, ry, "UNDER-\nGOES")
connect_rel(ax, *E['PATIENT'], *E['TREATMENT'], rx, ry, "1", "N",
            c1_offset=(0.6, 0.2), c2_offset=(0.6, 0.2))

# 9) DOCTOR (1) -- CONDUCTS -- (N) TREATMENT
rx, ry = mid('DOCTOR', 'TREATMENT', 0.5, ox=-2, oy=0)
draw_diamond(ax, rx, ry, "CON-\nDUCTS")
connect_rel(ax, *E['DOCTOR'], *E['TREATMENT'], rx, ry, "1", "N",
            c1_offset=(-0.5, 0.3), c2_offset=(0.5, 0.3))

# 10) TREATMENT (1) -- PRESCRIBES -- (0..1) PRESCRIPTION
rx, ry = mid('TREATMENT', 'PRESCRIPTION', 0.5)
draw_diamond(ax, rx, ry, "PRE-\nSCRIBES")
connect_rel(ax, *E['TREATMENT'], *E['PRESCRIPTION'], rx, ry, "1", "0..1",
            c1_offset=(-0.5, 0.4), c2_offset=(0.5, 0.4))

# 11) PRESCRIPTION (1) --<<HAS_ITEM>>-- (N) PRESCRIPTION_ITEM [Identifying]
rx, ry = mid('PRESCRIPTION', 'PRESCRIPTION_ITEM', 0.5)
draw_diamond(ax, rx, ry, "HAS\nITEM", identifying=True)
connect_rel(ax, *E['PRESCRIPTION'], *E['PRESCRIPTION_ITEM'], rx, ry,
            "1", "N", total_e2=True,
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 12) MEDICINE (1) -- INCLUDES -- (N) PRESCRIPTION_ITEM
rx, ry = mid('MEDICINE', 'PRESCRIPTION_ITEM', 0.5, oy=1)
draw_diamond(ax, rx, ry, "IN-\nCLUDES")
connect_rel(ax, *E['MEDICINE'], *E['PRESCRIPTION_ITEM'], rx, ry, "1", "N",
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 13) PATIENT (1) -- REQUESTS -- (N) LAB_TEST
rx, ry = mid('PATIENT', 'LAB_TEST', 0.5, oy=1)
draw_diamond(ax, rx, ry, "RE-\nQUESTS")
connect_rel(ax, *E['PATIENT'], *E['LAB_TEST'], rx, ry, "1", "N",
            c1_offset=(0, 0.5), c2_offset=(0, 0.5))

# 14) DOCTOR (1) -- ORDERS -- (N) LAB_TEST
rx, ry = mid('DOCTOR', 'LAB_TEST', 0.5, oy=-1)
draw_diamond(ax, rx, ry, "ORDERS")
connect_rel(ax, *E['DOCTOR'], *E['LAB_TEST'], rx, ry, "1", "N",
            c1_offset=(0, 0.5), c2_offset=(0, 0.5))

# 15) ROOM (1) --<<CONTAINS>>-- (N) BED [Identifying]
rx, ry = mid('ROOM', 'BED', 0.5)
draw_diamond(ax, rx, ry, "CON-\nTAINS", identifying=True)
connect_rel(ax, *E['ROOM'], *E['BED'], rx, ry, "1", "N",
            total_e2=True,
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 16) BED (1) -- ALLOCATED_TO -- (N) ADMISSION
rx, ry = mid('BED', 'ADMISSION', 0.5)
draw_diamond(ax, rx, ry, "ALLOC.\nTO")
connect_rel(ax, *E['BED'], *E['ADMISSION'], rx, ry, "1", "N",
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 17) PATIENT (1) -- ADMITTED -- (N) ADMISSION
rx, ry = mid('PATIENT', 'ADMISSION', 0.5, ox=2)
draw_diamond(ax, rx, ry, "ADMIT-\nTED")
connect_rel(ax, *E['PATIENT'], *E['ADMISSION'], rx, ry, "1", "N",
            c1_offset=(0.6, 0.2), c2_offset=(-0.6, 0.2))

# 18) PATIENT (1) -- ISSUED_TO -- (N) BILL
rx, ry = mid('PATIENT', 'BILL', 0.5, ox=-2)
draw_diamond(ax, rx, ry, "ISSUED\nTO")
connect_rel(ax, *E['PATIENT'], *E['BILL'], rx, ry, "1", "N",
            c1_offset=(-0.6, 0.3), c2_offset=(0.6, 0.3))

# 19) BILL (1) --<<INCLUDES_ITEM>>-- (N) BILL_ITEM [Identifying]
rx, ry = mid('BILL', 'BILL_ITEM', 0.5)
draw_diamond(ax, rx, ry, "INCL.\nITEM", identifying=True)
connect_rel(ax, *E['BILL'], *E['BILL_ITEM'], rx, ry, "1", "N",
            total_e2=True,
            c1_offset=(0.5, 0.4), c2_offset=(-0.5, 0.4))

# 20) BILL (1) -- PAID_VIA -- (N) PAYMENT
rx, ry = mid('BILL', 'PAYMENT', 0.5)
draw_diamond(ax, rx, ry, "PAID\nVIA")
connect_rel(ax, *E['BILL'], *E['PAYMENT'], rx, ry, "1", "N",
            c1_offset=(-0.5, 0.4), c2_offset=(0.5, 0.4))

# 21) PATIENT/STAFF -- NOTIFIED -- NOTIFICATION
rx, ry = mid('PATIENT', 'NOTIFICATION', 0.6, oy=-5)
draw_diamond(ax, rx, ry, "NOTI-\nFIED")
# Patient -> Notification
b1 = connect_to_entity(ax, *E['PATIENT'], rx, ry)
d1 = connect_to_diamond(ax, rx, ry, *E['PATIENT'])
draw_line(ax, b1[0], b1[1], d1[0], d1[1])
draw_card(ax, b1[0]*0.6+d1[0]*0.4 - 0.5, b1[1]*0.6+d1[1]*0.4 + 0.4, "0..1")
# Diamond -> Notification
d2 = connect_to_diamond(ax, rx, ry, *E['NOTIFICATION'])
b2 = connect_to_entity(ax, *E['NOTIFICATION'], rx, ry)
draw_line(ax, d2[0], d2[1], b2[0], b2[1])
draw_card(ax, b2[0]*0.6+d2[0]*0.4 + 0.5, b2[1]*0.6+d2[1]*0.4 + 0.4, "N")

# ══════════════════════════════════════════════════════════════════════════
# LEGEND BOX (bottom-left corner)
# ══════════════════════════════════════════════════════════════════════════
LX, LY = -1, -1.5
lgbg = FancyBboxPatch((LX, LY), 20, 5.5, boxstyle="round,pad=0.3",
                       facecolor="#F8F9F9", edgecolor="#ABB2B9",
                       linewidth=1.5, zorder=3)
ax.add_patch(lgbg)
ax.text(LX + 10, LY + 5, "LEGEND — Chen ER Notation", ha='center',
        fontsize=12, fontweight='bold', color=C_TXT, fontfamily='serif', zorder=4)

# Left column
items_l = [
    (LX+2.2, LY+3.8, "Strong Entity", "entity"),
    (LX+2.2, LY+2.6, "Weak Entity", "weak"),
    (LX+2.2, LY+1.4, "Relationship", "rel"),
    (LX+2.2, LY+0.3, "Identifying Rel.", "idrel"),
]
for x, y, label, kind in items_l:
    if kind == "entity":
        draw_entity(ax, x, y, "Entity")
        ax.text(x + 3.5, y, "= Strong Entity (Rectangle)", fontsize=8,
                va='center', color=C_TXT, fontfamily='serif', zorder=4)
    elif kind == "weak":
        draw_entity(ax, x, y, "Weak", weak=True)
        ax.text(x + 3.5, y, "= Weak Entity (Double Rectangle)", fontsize=8,
                va='center', color=C_TXT, fontfamily='serif', zorder=4)
    elif kind == "rel":
        draw_diamond(ax, x, y, "Rel")
        ax.text(x + 3.5, y, "= Relationship (Diamond)", fontsize=8,
                va='center', color=C_TXT, fontfamily='serif', zorder=4)
    elif kind == "idrel":
        draw_diamond(ax, x, y, "Id", identifying=True)
        ax.text(x + 3.5, y, "= Identifying Rel. (Double Diamond)", fontsize=8,
                va='center', color=C_TXT, fontfamily='serif', zorder=4)

# Right column
rx2 = LX + 12.5
draw_attr(ax, rx2, LY+3.8, "PK", key=True)
ax.text(rx2 + 2.5, LY+3.8, "= Key Attr. (Underlined)", fontsize=8,
        va='center', color=C_TXT, fontfamily='serif', zorder=4)

draw_attr(ax, rx2, LY+2.6, "Partial", partial_key=True)
ax.text(rx2 + 2.5, LY+2.6, "= Partial Key (Dashed UL)", fontsize=8,
        va='center', color=C_TXT, fontfamily='serif', zorder=4)

draw_attr(ax, rx2, LY+1.4, "Derived", derived=True)
ax.text(rx2 + 2.5, LY+1.4, "= Derived Attr. (Dashed Oval)", fontsize=8,
        va='center', color=C_TXT, fontfamily='serif', zorder=4)

draw_attr(ax, rx2, LY+0.3, "Attr")
ax.text(rx2 + 2.5, LY+0.3, "= Regular Attribute (Oval)", fontsize=8,
        va='center', color=C_TXT, fontfamily='serif', zorder=4)

# Total participation note
ax.plot([LX+8.5, LX+9.5], [LY+0.3, LY+0.3], color=C_LINE, linewidth=2, zorder=4)
ax.plot([LX+8.5, LX+9.5], [LY+0.16, LY+0.16], color=C_LINE, linewidth=2, zorder=4)
ax.text(LX+10, LY+0.3, "= Total Participation", fontsize=8,
        va='center', color=C_TXT, fontfamily='serif', zorder=4)

# ══════════════════════════════════════════════════════════════════════════
# SAVE
# ══════════════════════════════════════════════════════════════════════════
out = r"d:\DBMS Medicore\docs\MediCore_ER_Diagram.png"
plt.savefig(out, dpi=180, bbox_inches='tight', facecolor=BG,
            edgecolor='none', pad_inches=0.5)
plt.close()
print(f"ER Diagram saved: {out}")
