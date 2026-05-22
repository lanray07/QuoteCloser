from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "AppStoreAssets" / "SubscriptionReview"

GREEN = "#00563E"
GREEN_2 = "#147E6C"
MINT = "#E9F6F1"
INK = "#111816"
MUTED = "#5E6A66"
LINE = "#DCE4E0"
BG = "#F7F9F7"
CARD = "#FFFFFF"
GOLD = "#D8A928"


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


def text(draw: ImageDraw.ImageDraw, xy, value: str, size: int, fill: str = INK, bold: bool = False, anchor: str | None = None):
    draw.text(xy, value, fill=fill, font=font(size, bold), anchor=anchor)


def rounded(draw: ImageDraw.ImageDraw, xy, radius: int, fill: str, outline: str | None = None, width: int = 1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def text_width(draw: ImageDraw.ImageDraw, value: str, size: int, bold: bool = False) -> int:
    box = draw.textbbox((0, 0), value, font=font(size, bold))
    return box[2] - box[0]


def wrap(draw: ImageDraw.ImageDraw, value: str, max_width: int, size: int, bold: bool = False) -> list[str]:
    lines: list[str] = []
    current = ""
    for word in value.split():
        candidate = word if not current else f"{current} {word}"
        if text_width(draw, candidate, size, bold) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def wrapped_text(draw: ImageDraw.ImageDraw, xy, value: str, max_width: int, size: int, fill: str = INK, bold: bool = False, line_gap: int = 9):
    x, y = xy
    for line in wrap(draw, value, max_width, size, bold):
        text(draw, (x, y), line, size, fill, bold)
        y += size + line_gap
    return y


def status_bar(draw: ImageDraw.ImageDraw, width: int):
    text(draw, (54, 34), "9:41", 28, INK, True)
    x = width - 180
    rounded(draw, (x, 38, x + 64, 62), 8, INK)
    rounded(draw, (x + 74, 38, x + 140, 62), 8, INK)


def draw_check(draw: ImageDraw.ImageDraw, x: int, y: int):
    draw.ellipse((x, y, x + 28, y + 28), fill=GREEN)
    draw.line((x + 8, y + 15, x + 13, y + 20, x + 21, y + 9), fill=CARD, width=4, joint="curve")


def draw_plan(draw: ImageDraw.ImageDraw, y: int, title: str, price: str, cadence: str, features: list[str], highlighted: bool):
    left = 54
    right = 1188
    height = 430 if highlighted else 330
    fill = "#F1FBF6" if highlighted else CARD
    outline = GREEN if highlighted else LINE
    rounded(draw, (left, y, right, y + height), 24, fill, outline, 4 if highlighted else 1)
    text(draw, (left + 32, y + 34), title, 34, INK, True)
    if highlighted:
        rounded(draw, (right - 220, y + 28, right - 34, y + 76), 22, GREEN)
        text(draw, (right - 127, y + 52), "Selected", 22, CARD, True, "mm")
        text(draw, (right - 32, y + 102), price, 34, GREEN, True, "ra")
        text(draw, (right - 32, y + 146), cadence, 21, MUTED, False, "ra")
        yy = y + 154
    else:
        text(draw, (right - 32, y + 38), price, 34, GREEN, True, "ra")
        text(draw, (right - 32, y + 82), cadence, 21, MUTED, False, "ra")
        yy = y + 112
    for feature in features:
        draw_check(draw, left + 34, yy + 2)
        text(draw, (left + 78, yy), feature, 24, INK)
        yy += 48
    if highlighted:
        rounded(draw, (left + 32, y + height - 82, right - 32, y + height - 28), 20, GREEN)
        text(draw, ((left + right) // 2, y + height - 55), f"Continue with {title}", 24, CARD, True, "mm")
    return y + height + 26


def draw_disclaimer(draw: ImageDraw.ImageDraw, y: int):
    rounded(draw, (54, y, 1188, y + 184), 22, MINT, "#BBDDD1")
    text(draw, (84, y + 28), "Review before sending", 26, GREEN, True)
    lines = [
        "AI content should be reviewed before use.",
        "Pricing estimates are not guaranteed.",
        "Not legal or financial advice.",
    ]
    yy = y + 74
    for line in lines:
        draw_check(draw, 84, yy - 2)
        text(draw, (128, yy - 4), line, 21, INK)
        yy += 38


def render(path: Path, selected: str):
    image = Image.new("RGB", (1242, 2688), BG)
    draw = ImageDraw.Draw(image)
    status_bar(draw, 1242)

    text(draw, (54, 110), "Upgrade", 46, INK, True)
    text(draw, (54, 171), "QuoteCloser subscription options", 25, MUTED)
    rounded(draw, (1010, 108, 1188, 166), 24, GREEN)
    text(draw, (1099, 137), "Restore", 22, CARD, True, "mm")

    rounded(draw, (54, 230, 1188, 424), 26, GREEN)
    text(draw, (84, 268), "Close more jobs with AI-assisted quoting", 32, CARD, True)
    wrapped_text(draw, (84, 318), "Generate proposals, objection replies, follow-ups, upsells, PDF exports, and pipeline analytics for service businesses.", 1040, 23, "#E3F4EE")
    text(draw, (84, 380), "Mock AI is enabled by default for App Review.", 22, "#E3F4EE", True)

    plans = [
        (
            "Pro Monthly",
            "\u00a319.99",
            "per month",
            [
                "Unlimited quotes",
                "AI proposal generator",
                "AI objection handler",
                "PDF exports and pipeline",
            ],
        ),
        (
            "Pro Yearly",
            "\u00a3149.99",
            "per year",
            [
                "Annual Pro access",
                "Unlimited quotes",
                "AI proposal and follow-up tools",
                "PDF exports and analytics",
            ],
        ),
        (
            "Business Monthly",
            "\u00a379.99",
            "per month",
            [
                "Custom branding",
                "Advanced analytics",
                "Saved pricing templates",
                "Team workflow placeholder",
            ],
        ),
    ]

    y = 466
    for title, price, cadence, features in plans:
        y = draw_plan(draw, y, title, price, cadence, features, title == selected)

    draw_disclaimer(draw, y + 8)

    footer_top = 2528
    rounded(draw, (36, footer_top, 1206, 2648), 34, CARD, LINE)
    labels = ["Dashboard", "Pipeline", "AI Tools", "Analytics", "Settings"]
    gap = (1242 - 120) / len(labels)
    for i, label in enumerate(labels):
        x = round(60 + gap * i + gap / 2)
        color = GREEN if label == "Settings" else MUTED
        draw.ellipse((x - 12, footer_top + 26, x + 12, footer_top + 50), fill=color)
        text(draw, (x, footer_top + 77), label, 18, color, label == "Settings", "mm")

    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


def main():
    outputs = {
        "pro-monthly-review.png": "Pro Monthly",
        "pro-yearly-review.png": "Pro Yearly",
        "business-monthly-review.png": "Business Monthly",
    }
    for filename, selected in outputs.items():
        render(OUTPUT_DIR / filename, selected)


if __name__ == "__main__":
    main()
