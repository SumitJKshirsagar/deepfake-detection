"""
Deepfake Detection Service - CLI entry point.

Usage:
    python main.py <image_path>
    python main.py <image_url>
    python main.py <image_path> --json
"""

import json
import sys

from detector import analyze


_BAR_WIDTH = 30


def _progress_bar(pct: float) -> str:
    filled = int(_BAR_WIDTH * pct / 100)
    return "[" + "#" * filled + "-" * (_BAR_WIDTH - filled) + "]"


def _print_report(result: dict) -> None:
    verdict    = result.get("verdict", "UNKNOWN")
    confidence = result.get("confidence", 0)
    scores     = result.get("scores", {})
    summary    = result.get("summary", "")

    verdict_tag = {
        "AUTHENTIC": "  AUTHENTIC  ",
        "DEEPFAKE":  "  DEEPFAKE   ",
    }.get(verdict, f"  {verdict}  ")

    print()
    print("=" * 50)
    print(f"  RESULT: {verdict_tag}  ({confidence}% confidence)")
    print("=" * 50)
    print()
    print(f"  {summary}")
    print()
    print("  Score breakdown:")
    for label, score in sorted(scores.items(), key=lambda x: -x[1]):
        bar = _progress_bar(score)
        print(f"    {label:<8} {bar} {score:5.1f}%")
    print()


def main() -> None:
    if len(sys.argv) < 2:
        print("Deepfake Detection Service (local model, no API key needed)")
        print()
        print("Usage:")
        print("  python main.py <image_path>")
        print("  python main.py <image_url>")
        print("  python main.py <image_path> --json")
        print()
        print("Examples:")
        print("  python main.py portrait.jpg")
        print("  python main.py https://example.com/face.png")
        sys.exit(1)

    target    = sys.argv[1]
    show_json = "--json" in sys.argv

    print(f"Analyzing: {target}")

    kwargs = {}
    if target.startswith(("http://", "https://")):
        kwargs["image_url"] = target
    else:
        kwargs["image_path"] = target

    result = analyze(**kwargs)
    _print_report(result)

    if show_json:
        print("Full JSON output:")
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
