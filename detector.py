"""
Deepfake Detection — local inference using a HuggingFace pre-trained model.

Model: dima806/deepfake_vs_real_image_detection
  - EfficientNet trained on DFDC + FaceForensics++ data
  - Labels: "Fake" / "Real"
  - Runs entirely locally, no API key required
"""

from pathlib import Path
from typing import Optional

from PIL import Image
from transformers import pipeline

MODEL_ID = "dima806/deepfake_vs_real_image_detection"

_pipeline = None


def _get_pipeline():
    global _pipeline
    if _pipeline is None:
        print(f"Loading model '{MODEL_ID}' (downloads once, ~100 MB)...")
        _pipeline = pipeline(
            "image-classification",
            model=MODEL_ID,
            top_k=None,        # return all class scores
        )
        print("Model ready.\n")
    return _pipeline


def analyze(
    image_path: Optional[str] = None,
    image_url: Optional[str] = None,
) -> dict:
    """
    Analyze an image for deepfake indicators.

    Args:
        image_path: local file path to an image
        image_url:  HTTP/HTTPS URL of an image

    Returns a dict:
        verdict     — "DEEPFAKE" | "AUTHENTIC"
        confidence  — 0-100 (int)
        scores      — {"Fake": float, "Real": float}
        summary     — one-line human-readable result
    """
    if image_path:
        img = Image.open(image_path).convert("RGB")
    elif image_url:
        import urllib.request, io
        with urllib.request.urlopen(image_url) as resp:
            img = Image.open(io.BytesIO(resp.read())).convert("RGB")
    else:
        raise ValueError("Provide image_path or image_url")

    pipe = _get_pipeline()
    raw: list[dict] = pipe(img)

    scores = {item["label"]: round(item["score"] * 100, 1) for item in raw}

    fake_score = scores.get("Fake", 0)
    real_score = scores.get("Real", 0)

    if fake_score >= real_score:
        verdict = "DEEPFAKE"
        confidence = int(fake_score)
    else:
        verdict = "AUTHENTIC"
        confidence = int(real_score)

    summary = (
        f"Image classified as {verdict} with {confidence}% confidence "
        f"(Fake: {fake_score}%, Real: {real_score}%)"
    )

    return {
        "verdict": verdict,
        "confidence": confidence,
        "scores": scores,
        "summary": summary,
    }
