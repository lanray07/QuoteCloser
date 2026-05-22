from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "AppStoreAssets"
APP_ICONSET = ROOT / "QuoteCloser" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

GREEN = "#00563E"
GREEN_2 = "#147E6C"
MINT = "#E9F6F1"
GOLD = "#D8A928"
INK = "#111816"
MUTED = "#5E6A66"
LINE = "#DCE4E0"
BG = "#F7F9F7"
CARD = "#FFFFFF"
RED = "#D9534F"
BLUE = "#2A6FDB"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def rounded(draw: ImageDraw.ImageDraw, xy, radius: int, fill: str, outline: str | None = None, width: int = 1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def text(draw: ImageDraw.ImageDraw, xy, value: str, size: int, fill: str = INK, bold: bool = False, anchor: str | None = None):
    draw.text(xy, value, fill=fill, font=font(size, bold), anchor=anchor)


def text_size(draw: ImageDraw.ImageDraw, value: str, size: int, bold: bool = False) -> tuple[int, int]:
    box = draw.textbbox((0, 0), value, font=font(size, bold))
    return box[2] - box[0], box[3] - box[1]


def wrap(draw: ImageDraw.ImageDraw, value: str, max_width: int, size: int, bold: bool = False) -> list[str]:
    lines: list[str] = []
    for paragraph in value.split("\n"):
        current = ""
        for word in paragraph.split(" "):
            candidate = word if not current else f"{current} {word}"
            if text_size(draw, candidate, size, bold)[0] <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines or [""]


def draw_wrapped(draw: ImageDraw.ImageDraw, xy, value: str, max_width: int, size: int, fill: str = INK, bold: bool = False, line_gap: int = 8):
    x, y = xy
    for line in wrap(draw, value, max_width, size, bold):
        text(draw, (x, y), line, size, fill, bold)
        y += size + line_gap
    return y


def gradient(size: tuple[int, int], top: str, bottom: str) -> Image.Image:
    width, height = size
    image = Image.new("RGB", size, top)
    draw = ImageDraw.Draw(image)
    tr, tg, tb = Image.new("RGB", (1, 1), top).getpixel((0, 0))
    br, bg, bb = Image.new("RGB", (1, 1), bottom).getpixel((0, 0))
    for y in range(height):
        t = y / max(1, height - 1)
        r = round(tr + (br - tr) * t)
        g = round(tg + (bg - tg) * t)
        b = round(tb + (bb - tb) * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    return image


def app_icon(size: int) -> Image.Image:
    image = gradient((size, size), "#003F30", "#17A174").convert("RGBA")
    draw = ImageDraw.Draw(image)
    pad = size // 7
    rounded(draw, (pad, pad, size - pad, size - pad), size // 8, fill="#F3F8F5", outline="#C5DCD2", width=size // 90)
    chart_left = pad + size // 7
    chart_bottom = size - pad - size // 4
    chart_top = pad + size // 4
    chart_right = size - pad - size // 6
    draw.line((chart_left, chart_bottom, chart_left, chart_top), fill=GREEN, width=size // 38)
    draw.line((chart_left, chart_bottom, chart_right, chart_bottom), fill=GREEN, width=size // 38)
    points = [
        (chart_left + size // 16, chart_bottom - size // 13),
        (chart_left + size // 4, chart_bottom - size // 5),
        (chart_left + size // 3, chart_bottom - size // 8),
        (chart_right - size // 12, chart_top + size // 8),
    ]
    draw.line(points, fill=GREEN_2, width=size // 28, joint="curve")
    for point in points:
        x, y = point
        draw.ellipse((x - size // 36, y - size // 36, x + size // 36, y + size // 36), fill=GREEN)
    text(draw, (size // 2, size // 2 + size // 16), "QC", size // 5, fill=INK, bold=True, anchor="mm")
    return image


def canvas(width: int, height: int) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(image)
    return image, draw


def status_bar(draw: ImageDraw.ImageDraw, width: int, y: int, scale: float):
    text(draw, (round(54 * scale), y), "9:41", round(28 * scale), INK, True)
    x = width - round(180 * scale)
    rounded(draw, (x, y + round(4 * scale), x + round(64 * scale), y + round(28 * scale)), round(8 * scale), fill=INK)
    rounded(draw, (x + round(74 * scale), y + round(4 * scale), x + round(140 * scale), y + round(28 * scale)), round(8 * scale), fill=INK)


def phone_header(draw: ImageDraw.ImageDraw, width: int, title: str, subtitle: str, scale: float):
    status_bar(draw, width, round(34 * scale), scale)
    y = round(110 * scale)
    text(draw, (round(54 * scale), y), title, round(44 * scale), INK, True)
    text(draw, (round(54 * scale), y + round(58 * scale)), subtitle, round(24 * scale), MUTED)
    rounded(draw, (width - round(188 * scale), y - round(8 * scale), width - round(54 * scale), y + round(48 * scale)), round(22 * scale), fill=GREEN)
    text(draw, (width - round(121 * scale), y + round(19 * scale)), "New", round(23 * scale), CARD, True, anchor="mm")


def bottom_tabs(draw: ImageDraw.ImageDraw, width: int, height: int, active: str, scale: float):
    top = height - round(148 * scale)
    rounded(draw, (round(36 * scale), top, width - round(36 * scale), height - round(40 * scale)), round(34 * scale), fill=CARD, outline=LINE)
    tabs = ["Dashboard", "Pipeline", "AI Tools", "Analytics", "Settings"]
    gap = (width - round(120 * scale)) / len(tabs)
    for i, tab in enumerate(tabs):
        x = round(60 * scale + gap * i + gap / 2)
        color = GREEN if tab == active else MUTED
        draw.ellipse((x - round(12 * scale), top + round(24 * scale), x + round(12 * scale), top + round(48 * scale)), fill=color)
        text(draw, (x, top + round(70 * scale)), tab, round(18 * scale), color, tab == active, anchor="mm")


def card(draw: ImageDraw.ImageDraw, xy, radius: int, fill: str = CARD):
    rounded(draw, xy, radius, fill=fill, outline=LINE)


def metric(draw, x, y, w, h, label, value, scale):
    card(draw, (x, y, x + w, y + h), round(18 * scale))
    text(draw, (x + round(24 * scale), y + round(24 * scale)), label, round(21 * scale), MUTED)
    text(draw, (x + round(24 * scale), y + round(64 * scale)), value, round(34 * scale), INK, True)


def pill(draw, x, y, label, color, scale):
    tw, _ = text_size(draw, label, round(18 * scale), True)
    rounded(draw, (x, y, x + tw + round(34 * scale), y + round(42 * scale)), round(21 * scale), fill=color)
    text(draw, (x + round(17 * scale), y + round(10 * scale)), label, round(18 * scale), CARD, True)
    return x + tw + round(46 * scale)


def screenshot_dashboard(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Dashboard", "Roofing workspace - Free plan", scale)
    y = round(235 * scale)
    pad = round(54 * scale)
    gap = round(22 * scale)
    col = (width - pad * 2 - gap) // 2
    metric(draw, pad, y, col, round(150 * scale), "Pipeline", "\u00a318,420", scale)
    metric(draw, pad + col + gap, y, col, round(150 * scale), "Accepted", "12", scale)
    y += round(180 * scale)
    metric(draw, pad, y, col, round(150 * scale), "Follow-ups", "8 due", scale)
    metric(draw, pad + col + gap, y, col, round(150 * scale), "Sent quotes", "27", scale)
    y += round(200 * scale)
    text(draw, (pad, y), "Quick actions", round(30 * scale), INK, True)
    y += round(55 * scale)
    actions = ["New Quote", "Generate Proposal", "Objection Handler", "Follow-Up Writer", "Voice Notes", "Templates"]
    for index, action in enumerate(actions):
        x = pad + (index % 2) * (col + gap)
        yy = y + (index // 2) * round(112 * scale)
        rounded(draw, (x, yy, x + col, yy + round(86 * scale)), round(18 * scale), fill=MINT, outline="#BBDDD1")
        text(draw, (x + round(24 * scale), yy + round(25 * scale)), action, round(23 * scale), GREEN, True)
    y += round(380 * scale)
    text(draw, (pad, y), "Recent quotes", round(30 * scale), INK, True)
    y += round(55 * scale)
    for title, client, value, status in [
        ("Flat roof repair", "A. Williams", "\u00a32,450", "Follow-up due"),
        ("Garden redesign", "J. Smith", "\u00a37,800", "Sent"),
        ("Office deep clean", "Northside Ltd", "\u00a31,160", "Accepted"),
    ]:
        card(draw, (pad, y, width - pad, y + round(134 * scale)), round(18 * scale))
        text(draw, (pad + round(24 * scale), y + round(24 * scale)), title, round(25 * scale), INK, True)
        text(draw, (pad + round(24 * scale), y + round(63 * scale)), client, round(21 * scale), MUTED)
        text(draw, (width - pad - round(24 * scale), y + round(28 * scale)), value, round(26 * scale), GREEN, True, anchor="ra")
        text(draw, (width - pad - round(24 * scale), y + round(68 * scale)), status, round(18 * scale), MUTED, anchor="ra")
        y += round(154 * scale)
    bottom_tabs(draw, width, height, "Dashboard", scale)
    save(image, name)


def screenshot_quote_builder(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Quote Builder", "Build a profitable quote in minutes", scale)
    pad = round(54 * scale)
    y = round(240 * scale)
    card(draw, (pad, y, width - pad, y + round(430 * scale)), round(20 * scale))
    text(draw, (pad + round(28 * scale), y + round(28 * scale)), "Bathroom leak repair", round(30 * scale), INK, True)
    fields = [
        ("Labour", "\u00a3450"),
        ("Materials", "\u00a3180"),
        ("Travel", "\u00a335"),
        ("Equipment", "\u00a365"),
        ("Discount", "\u00a30"),
        ("Margin", "32%"),
    ]
    yy = y + round(88 * scale)
    for i, (label, value) in enumerate(fields):
        x = pad + round(28 * scale) + (i % 2) * round(520 * scale)
        row_y = yy + (i // 2) * round(100 * scale)
        text(draw, (x, row_y), label, round(20 * scale), MUTED)
        rounded(draw, (x, row_y + round(30 * scale), x + round(440 * scale), row_y + round(78 * scale)), round(12 * scale), fill="#F3F7F5", outline=LINE)
        text(draw, (x + round(18 * scale), row_y + round(41 * scale)), value, round(22 * scale), INK, True)
    y += round(465 * scale)
    card(draw, (pad, y, width - pad, y + round(310 * scale)), round(20 * scale), fill="#F1FBF6")
    text(draw, (pad + round(28 * scale), y + round(28 * scale)), "Quote output", round(30 * scale), INK, True)
    for i, (label, value) in enumerate([("Subtotal", "\u00a3730"), ("Profit estimate", "\u00a3234"), ("VAT placeholder", "\u00a30"), ("Total price", "\u00a3964")]):
        yy = y + round(88 * scale) + i * round(46 * scale)
        text(draw, (pad + round(28 * scale), yy), label, round(23 * scale), MUTED)
        text(draw, (width - pad - round(28 * scale), yy), value, round(24 * scale), GREEN if i == 3 else INK, True, anchor="ra")
    y += round(350 * scale)
    text(draw, (pad, y), "Recommended upsells", round(30 * scale), INK, True)
    y += round(55 * scale)
    for title, value in [("Maintenance check", "\u00a3120"), ("Leak inspection", "\u00a395"), ("Priority callout cover", "\u00a3180")]:
        card(draw, (pad, y, width - pad, y + round(115 * scale)), round(18 * scale))
        draw.ellipse((pad + round(26 * scale), y + round(34 * scale), pad + round(62 * scale), y + round(70 * scale)), fill=GREEN)
        text(draw, (pad + round(84 * scale), y + round(27 * scale)), title, round(24 * scale), INK, True)
        text(draw, (width - pad - round(28 * scale), y + round(39 * scale)), value, round(24 * scale), GREEN, True, anchor="ra")
        y += round(136 * scale)
    bottom_tabs(draw, width, height, "Pipeline", scale)
    save(image, name)


def screenshot_proposal(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Proposal", "AI-assisted proposal draft", scale)
    pad = round(54 * scale)
    y = round(245 * scale)
    card(draw, (pad, y, width - pad, y + round(1180 * scale)), round(22 * scale))
    text(draw, (pad + round(30 * scale), y + round(32 * scale)), "Professional quote summary", round(32 * scale), INK, True)
    y += round(96 * scale)
    sections = [
        ("Scope of work", "Repair leak source, replace failed fittings, test pressure, and clean the work area before handover."),
        ("Included services", "Labour, standard materials, travel, equipment, testing, and client-friendly handover notes."),
        ("Exclusions", "Hidden defects, specialist reports, extra materials, and changes requested after approval."),
        ("Timeline", "Next available slot after acceptance, with urgent attendance prioritised where possible."),
        ("Payment terms", "Deposit may be required to secure scheduling. Remaining balance due on completion."),
    ]
    for heading, body in sections:
        text(draw, (pad + round(30 * scale), y), heading, round(25 * scale), GREEN, True)
        y = draw_wrapped(draw, (pad + round(30 * scale), y + round(38 * scale)), body, width - pad * 2 - round(60 * scale), round(22 * scale), MUTED, False, round(8 * scale))
        y += round(34 * scale)
    rounded(draw, (pad + round(30 * scale), y, width - pad - round(30 * scale), y + round(128 * scale)), round(18 * scale), fill=MINT, outline="#BBDDD1")
    text(draw, (pad + round(58 * scale), y + round(28 * scale)), "Acceptance CTA", round(24 * scale), GREEN, True)
    draw_wrapped(draw, (pad + round(58 * scale), y + round(66 * scale)), "Reply with approval or sign the acceptance section to confirm the next steps.", width - pad * 2 - round(116 * scale), round(21 * scale), INK)
    y += round(178 * scale)
    rounded(draw, (pad, y, width - pad, y + round(78 * scale)), round(18 * scale), fill=GREEN)
    text(draw, (width // 2, y + round(39 * scale)), "Export PDF Proposal", round(24 * scale), CARD, True, anchor="mm")
    bottom_tabs(draw, width, height, "AI Tools", scale)
    save(image, name)


def screenshot_objection(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Objection Handler", "Turn hesitation into a helpful reply", scale)
    pad = round(54 * scale)
    y = round(250 * scale)
    text(draw, (pad, y), "Common objection", round(28 * scale), INK, True)
    y += round(55 * scale)
    x = pad
    for label, color in [("Too expensive", GREEN), ("Need to think", BLUE), ("Cheaper quote", GOLD), ("Discount", RED)]:
        x = pill(draw, x, y, label, color, scale)
    y += round(95 * scale)
    text(draw, (pad, y), "Tone", round(28 * scale), INK, True)
    y += round(55 * scale)
    x = pad
    for label in ["Friendly", "Premium", "Confident", "Polite"]:
        x = pill(draw, x, y, label, GREEN if label == "Confident" else "#7D8A86", scale)
    y += round(115 * scale)
    card(draw, (pad, y, width - pad, y + round(585 * scale)), round(22 * scale))
    text(draw, (pad + round(30 * scale), y + round(30 * scale)), "Generated reply", round(30 * scale), INK, True)
    reply = (
        "I completely understand comparing options. The important thing is making sure the quotes cover the same scope, "
        "materials, preparation, and aftercare. I can highlight exactly what is included here so you can compare like for like."
    )
    draw_wrapped(draw, (pad + round(30 * scale), y + round(92 * scale)), reply, width - pad * 2 - round(60 * scale), round(27 * scale), INK, False, round(12 * scale))
    rounded(draw, (pad + round(30 * scale), y + round(455 * scale), width - pad - round(30 * scale), y + round(535 * scale)), round(18 * scale), fill=GREEN)
    text(draw, (width // 2, y + round(495 * scale)), "Copy Reply", round(24 * scale), CARD, True, anchor="mm")
    bottom_tabs(draw, width, height, "AI Tools", scale)
    save(image, name)


def screenshot_followup(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Follow-Up Writer", "Never let a warm lead go cold", scale)
    pad = round(54 * scale)
    y = round(250 * scale)
    card(draw, (pad, y, width - pad, y + round(165 * scale)), round(20 * scale))
    text(draw, (pad + round(28 * scale), y + round(28 * scale)), "Garden redesign - J. Smith", round(29 * scale), INK, True)
    text(draw, (pad + round(28 * scale), y + round(78 * scale)), "\u00a37,800 quote sent yesterday", round(23 * scale), MUTED)
    y += round(205 * scale)
    x = pad
    for label in ["SMS", "Email", "WhatsApp", "Reminder", "Final check-in"]:
        x = pill(draw, x, y, label, GREEN if label == "WhatsApp" else "#7D8A86", scale)
    y += round(112 * scale)
    card(draw, (pad, y, width - pad, y + round(470 * scale)), round(22 * scale), fill="#F1FBF6")
    text(draw, (pad + round(30 * scale), y + round(30 * scale)), "WhatsApp-style follow-up", round(30 * scale), INK, True)
    body = "Hi J. Smith, quick follow-up on the garden redesign quote. Let me know if you want me to talk through the options or reserve a slot."
    draw_wrapped(draw, (pad + round(30 * scale), y + round(96 * scale)), body, width - pad * 2 - round(60 * scale), round(30 * scale), INK, False, round(14 * scale))
    y += round(525 * scale)
    text(draw, (pad, y), "Saved follow-ups", round(30 * scale), INK, True)
    y += round(58 * scale)
    for label, date in [("Reminder follow-up", "Tomorrow"), ("Final check-in", "Friday")]:
        card(draw, (pad, y, width - pad, y + round(112 * scale)), round(18 * scale))
        text(draw, (pad + round(28 * scale), y + round(30 * scale)), label, round(24 * scale), INK, True)
        text(draw, (width - pad - round(28 * scale), y + round(34 * scale)), date, round(22 * scale), MUTED, anchor="ra")
        y += round(134 * scale)
    bottom_tabs(draw, width, height, "AI Tools", scale)
    save(image, name)


def screenshot_pipeline(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Pipeline", "Track every quote from draft to accepted", scale)
    pad = round(54 * scale)
    y = round(246 * scale)
    x = pad
    for label in ["All", "Draft", "Sent", "Follow-up", "Accepted"]:
        x = pill(draw, x, y, label, GREEN if label == "All" else "#7D8A86", scale)
    y += round(102 * scale)
    rows = [
        ("Flat roof repair", "Follow-up due", "\u00a32,450", GOLD),
        ("Drainage and lighting", "Sent", "\u00a34,900", BLUE),
        ("Office deep clean", "Accepted", "\u00a31,160", GREEN),
        ("Driveway sealant", "Viewed", "\u00a33,320", GREEN_2),
        ("Emergency plumbing", "Draft", "\u00a3964", "#7D8A86"),
        ("Decorating package", "Rejected", "\u00a32,200", RED),
    ]
    for title, status, value, color in rows:
        card(draw, (pad, y, width - pad, y + round(170 * scale)), round(20 * scale))
        text(draw, (pad + round(28 * scale), y + round(28 * scale)), title, round(27 * scale), INK, True)
        text(draw, (pad + round(28 * scale), y + round(76 * scale)), "Follow-up date and PDF export ready", round(21 * scale), MUTED)
        rounded(draw, (pad + round(28 * scale), y + round(113 * scale), pad + round(280 * scale), y + round(152 * scale)), round(19 * scale), fill=color)
        text(draw, (pad + round(154 * scale), y + round(133 * scale)), status, round(17 * scale), CARD, True, anchor="mm")
        text(draw, (width - pad - round(28 * scale), y + round(45 * scale)), value, round(28 * scale), GREEN, True, anchor="ra")
        y += round(192 * scale)
    bottom_tabs(draw, width, height, "Pipeline", scale)
    save(image, name)


def screenshot_analytics(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Analytics", "Know what helps you close", scale)
    pad = round(54 * scale)
    gap = round(22 * scale)
    col = (width - pad * 2 - gap) // 2
    y = round(246 * scale)
    metric(draw, pad, y, col, round(150 * scale), "Acceptance rate", "64%", scale)
    metric(draw, pad + col + gap, y, col, round(150 * scale), "Avg quote", "\u00a32,870", scale)
    y += round(182 * scale)
    metric(draw, pad, y, col, round(150 * scale), "Pipeline", "\u00a318,420", scale)
    metric(draw, pad + col + gap, y, col, round(150 * scale), "Upsells", "\u00a34,160", scale)
    y += round(210 * scale)
    card(draw, (pad, y, width - pad, y + round(515 * scale)), round(22 * scale))
    text(draw, (pad + round(28 * scale), y + round(28 * scale)), "Pipeline value by status", round(30 * scale), INK, True)
    chart_y = y + round(120 * scale)
    labels = [("Draft", 140), ("Sent", 260), ("Follow-up", 330), ("Accepted", 410)]
    for i, (label, height_bar) in enumerate(labels):
        x = pad + round(75 * scale) + i * round(235 * scale)
        bar_h = round(height_bar * scale)
        rounded(draw, (x, chart_y + round(330 * scale) - bar_h, x + round(100 * scale), chart_y + round(330 * scale)), round(14 * scale), fill=GREEN if label == "Accepted" else GREEN_2)
        text(draw, (x + round(50 * scale), chart_y + round(355 * scale)), label, round(18 * scale), MUTED, anchor="mm")
    y += round(560 * scale)
    card(draw, (pad, y, width - pad, y + round(255 * scale)), round(22 * scale))
    text(draw, (pad + round(28 * scale), y + round(28 * scale)), "Best-performing services", round(30 * scale), INK, True)
    for i, (label, value) in enumerate([("Roofing repairs", "\u00a39,700"), ("Landscaping", "\u00a37,800"), ("Cleaning plans", "\u00a33,240")]):
        yy = y + round(92 * scale) + i * round(48 * scale)
        text(draw, (pad + round(28 * scale), yy), label, round(23 * scale), INK)
        text(draw, (width - pad - round(28 * scale), yy), value, round(23 * scale), GREEN, True, anchor="ra")
    bottom_tabs(draw, width, height, "Analytics", scale)
    save(image, name)


def screenshot_voice(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Voice-to-Quote", "Turn site notes into quote details", scale)
    pad = round(54 * scale)
    y = round(260 * scale)
    card(draw, (pad, y, width - pad, y + round(420 * scale)), round(22 * scale))
    text(draw, (pad + round(30 * scale), y + round(30 * scale)), "Recording site notes", round(30 * scale), INK, True)
    base = y + round(250 * scale)
    for i in range(22):
        x = pad + round(58 * scale) + i * round(46 * scale)
        h = round((60 + (i % 5) * 28 + (i % 3) * 15) * scale)
        rounded(draw, (x, base - h, x + round(18 * scale), base + h), round(9 * scale), fill=GREEN_2)
    rounded(draw, (width // 2 - round(88 * scale), y + round(315 * scale), width // 2 + round(88 * scale), y + round(375 * scale)), round(30 * scale), fill=RED)
    text(draw, (width // 2, y + round(345 * scale)), "Stop", round(22 * scale), CARD, True, anchor="mm")
    y += round(470 * scale)
    card(draw, (pad, y, width - pad, y + round(520 * scale)), round(22 * scale), fill="#F1FBF6")
    text(draw, (pad + round(30 * scale), y + round(30 * scale)), "AI summary", round(30 * scale), INK, True)
    summary = (
        "Client needs urgent leak repair. Confirm access, inspect nearby pipework, include labour, materials, "
        "testing, and a maintenance-check upsell. Send proposal today and follow up tomorrow."
    )
    draw_wrapped(draw, (pad + round(30 * scale), y + round(92 * scale)), summary, width - pad * 2 - round(60 * scale), round(29 * scale), INK, False, round(12 * scale))
    y += round(575 * scale)
    rounded(draw, (pad, y, width - pad, y + round(78 * scale)), round(18 * scale), fill=GREEN)
    text(draw, (width // 2, y + round(39 * scale)), "Create Lead From Notes", round(24 * scale), CARD, True, anchor="mm")
    bottom_tabs(draw, width, height, "AI Tools", scale)
    save(image, name)


def screenshot_paywall(width: int, height: int, name: str):
    scale = width / 1242
    image, draw = canvas(width, height)
    phone_header(draw, width, "Upgrade", "Plans for growing service teams", scale)
    pad = round(54 * scale)
    y = round(245 * scale)
    plans = [
        ("Free", "\u00a30", ["5 quotes/month", "Basic proposal export", "QuoteCloser branding"], False),
        ("Pro Monthly", "\u00a319.99", ["Unlimited quotes", "AI proposal generator", "PDF exports", "Pipeline and analytics"], True),
        ("Business Monthly", "\u00a379.99", ["Custom branding", "Advanced analytics", "Team workflow placeholder"], False),
    ]
    for title, price, features, highlighted in plans:
        card(draw, (pad, y, width - pad, y + round(300 * scale)), round(22 * scale), fill="#F1FBF6" if highlighted else CARD)
        text(draw, (pad + round(30 * scale), y + round(28 * scale)), title, round(31 * scale), INK, True)
        text(draw, (width - pad - round(30 * scale), y + round(30 * scale)), price, round(30 * scale), GREEN, True, anchor="ra")
        yy = y + round(92 * scale)
        for feature in features:
            draw.ellipse((pad + round(34 * scale), yy + round(7 * scale), pad + round(56 * scale), yy + round(29 * scale)), fill=GREEN)
            text(draw, (pad + round(75 * scale), yy), feature, round(22 * scale), INK)
            yy += round(43 * scale)
        if highlighted:
            rounded(draw, (pad + round(30 * scale), y + round(235 * scale), width - pad - round(30 * scale), y + round(280 * scale)), round(18 * scale), fill=GREEN)
            text(draw, (width // 2, y + round(258 * scale)), "Choose Pro", round(21 * scale), CARD, True, anchor="mm")
        y += round(335 * scale)
    bottom_tabs(draw, width, height, "Settings", scale)
    save(image, name)


SCREENS = [
    ("01-dashboard", screenshot_dashboard),
    ("02-quote-builder", screenshot_quote_builder),
    ("03-proposal-generator", screenshot_proposal),
    ("04-objection-handler", screenshot_objection),
    ("05-follow-up-writer", screenshot_followup),
    ("06-pipeline", screenshot_pipeline),
    ("07-analytics", screenshot_analytics),
    ("08-voice-to-quote", screenshot_voice),
    ("09-paywall", screenshot_paywall),
]


def save(image: Image.Image, relative_name: str):
    output = ASSET_ROOT / relative_name
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)


def make_screenshots(prefix: str, width: int, height: int):
    for base_name, renderer in SCREENS:
        renderer(width, height, f"Screenshots/{prefix}/{base_name}.png")


def make_metadata():
    text_content = """# QuoteCloser App Store Assets

Generated assets for App Store Connect.

## Upload order

Use these for the iPhone screenshot section:

1. Screenshots/iPhone-6.5/01-dashboard.png
2. Screenshots/iPhone-6.5/02-quote-builder.png
3. Screenshots/iPhone-6.5/03-proposal-generator.png
4. Screenshots/iPhone-6.5/04-objection-handler.png
5. Screenshots/iPhone-6.5/05-follow-up-writer.png
6. Screenshots/iPhone-6.5/06-pipeline.png
7. Screenshots/iPhone-6.5/07-analytics.png
8. Screenshots/iPhone-6.5/08-voice-to-quote.png
9. Screenshots/iPhone-6.5/09-paywall.png

Use the matching files in Screenshots/iPad-12.9 for the iPad tab.

## Metadata

Promotional text:
Create clearer quotes, proposals, follow-ups, upsells, and objection replies faster with AI-assisted tools for service businesses.

Keywords:
quotes,proposal,estimate,contractor,trades,invoice,sales,follow up,upsell,clients

Support URL:
Add a public support page URL before review.

Marketing URL:
Add a public product page URL if available.

Copyright:
(C) 2026 Olanrewaju Bankole

App Review Notes:
QuoteCloser does not require sign-in. The app uses mock AI mode by default for review. Reviewers can complete onboarding, create a lead, build a quote, generate mock proposal/follow-up/objection content, export a PDF, and view pipeline analytics using local sample data they create in the app.
"""
    (ASSET_ROOT / "README.md").write_text(text_content, encoding="utf-8")


def main():
    ASSET_ROOT.mkdir(parents=True, exist_ok=True)
    (ASSET_ROOT / "AppIcon").mkdir(parents=True, exist_ok=True)

    icon = app_icon(1024)
    icon.save(ASSET_ROOT / "AppIcon" / "AppIcon-1024.png")
    APP_ICONSET.mkdir(parents=True, exist_ok=True)
    icon.save(APP_ICONSET / "AppIcon.png")

    make_screenshots("iPhone-6.5", 1242, 2688)
    make_screenshots("iPad-12.9", 2048, 2732)
    make_metadata()


if __name__ == "__main__":
    main()
