# ── Stage 1: download the AI model during build so pods start instantly ──
FROM python:3.11-slim AS model-downloader

WORKDIR /model-cache

RUN pip install --no-cache-dir transformers torch torchvision accelerate Pillow

# Pre-download and cache the model inside the image
RUN python -c "\
from transformers import pipeline; \
pipe = pipeline('image-classification', model='dima806/deepfake_vs_real_image_detection'); \
print('Model downloaded successfully')"


# ── Stage 2: production image ─────────────────────────────────────────────
FROM python:3.11-slim

WORKDIR /app

# Install production dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy cached model from stage 1
COPY --from=model-downloader /root/.cache/huggingface /root/.cache/huggingface

# Copy application code
COPY . .

# Create uploads directory
RUN mkdir -p static/uploads

# Non-root user for security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')"

# Run with gunicorn — reads PORT env var (Cloud Run sets this automatically)
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 2 --timeout 120 app:app
