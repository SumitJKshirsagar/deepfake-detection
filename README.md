<div align="center">

# 🔍 Deepfake Detection

**An AI-powered web application to detect deepfake images — runs 100% locally, no API key required.**

[![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![Flask](https://img.shields.io/badge/Flask-3.0-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com)
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Transformers-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)](https://huggingface.co)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🖼️ **Drag & Drop Upload** — Upload any face image directly from your device
- 🌐 **URL Support** — Paste an image URL to analyze it instantly
- 📊 **Visual Score Breakdown** — Real vs Fake confidence bars
- 🤖 **Local AI Model** — Powered by a pre-trained EfficientNet model from HuggingFace
- 💻 **CLI Mode** — Run detection from the command line
- 🔒 **No API Key Needed** — Fully offline after the first model download
- ⚡ **Fast Inference** — Results in seconds after model loads

---

## 🖥️ Preview

```
==================================================
  RESULT:   DEEPFAKE     (91% confidence)
==================================================

  Score breakdown:
    Real     [#######-----------------------]  23.4%
    Fake     [###########################---]  76.6%
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.9 or higher
- pip

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/SumitJKshirsagar/deepfake-detection.git
cd deepfake-detection
```

**2. Install dependencies**

```bash
pip install -r requirements.txt
```

> ⚠️ First run will download the AI model (~100 MB). It is cached after that.

---

## 🌐 Run the Web App

```bash
python app.py
```

Then open your browser at:

```
http://localhost:5000
```

Upload a face image or paste a URL — results appear in seconds.

---

## 💻 Run via CLI

```bash
# Analyze a local image
python main.py portrait.jpg

# Analyze from a URL
python main.py https://example.com/face.png

# Print full JSON output
python main.py portrait.jpg --json
```

**Example output:**

```
Analyzing: portrait.jpg
--------------------------------------------------
Verdict:     [DEEPFAKE]
Confidence:  87%

Summary:
  Image classified as DEEPFAKE with 87% confidence (Fake: 87.3%, Real: 12.7%)

Artifacts detected:
  - Unnatural skin texture smoothness
  - Inconsistent facial boundary blending
  - GAN-typical frequency artifacts
```

---

## 🧠 How It Works

```
Input Image
     │
     ▼
┌─────────────────────────────────────┐
│     EfficientNet (HuggingFace)      │
│  dima806/deepfake_vs_real_image_    │
│           detection                 │
└─────────────────────────────────────┘
     │
     ▼
  Real Score  ──┐
                ├──▶  Verdict + Confidence
  Fake Score  ──┘
```

The model was trained on the **DeepFake Detection Challenge (DFDC)** and **FaceForensics++** datasets — two of the largest and most diverse deepfake datasets available.

---

## 📁 Project Structure

```
deepfake-detection/
├── app.py                  # Flask web server & API routes
├── detector.py             # Core detection logic (HuggingFace pipeline)
├── main.py                 # CLI entry point
├── requirements.txt        # Python dependencies
├── templates/
│   └── index.html          # Web frontend (drag & drop UI)
└── static/
    └── uploads/            # Temporary uploaded images (auto-created)
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flask` | Web server & routing |
| `transformers` | HuggingFace model pipeline |
| `torch` + `torchvision` | Deep learning inference |
| `Pillow` | Image loading & preprocessing |
| `accelerate` | Optimized model loading |

---

## ⚙️ Configuration

You can swap the detection model by editing `detector.py`:

```python
# Default model
MODEL_ID = "dima806/deepfake_vs_real_image_detection"

# Alternative — Vision Transformer based
# MODEL_ID = "Wvolf/ViT-Deepfake-Detection"
```

Any HuggingFace image-classification model trained for deepfake detection will work.

---

## ⚠️ Limitations

- Best results on **facial images** — not designed for full-body or non-face images
- May struggle with **latest GAN/diffusion** models (StyleGAN3, Stable Diffusion)
- Model accuracy depends on training data — results are probabilistic, not absolute
- Not a substitute for professional forensic analysis

---

## 🛣️ Roadmap

- [ ] Video file support (frame-by-frame analysis)
- [ ] Multiple model ensemble for higher accuracy
- [ ] Batch processing mode
- [ ] Heatmap visualization of suspicious regions
- [ ] REST API endpoint

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">

Made with ❤️ by [SumitJKshirsagar](https://github.com/SumitJKshirsagar)

⭐ **Star this repo if you found it useful!**

</div>
