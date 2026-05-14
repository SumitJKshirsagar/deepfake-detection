#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Deepfake Detection — Google Cloud Run Deploy Script
# Free tier: 2M requests/month, scales to zero when idle
#
# Prerequisites:
#   1. Docker Desktop running
#   2. Google Cloud CLI installed (https://cloud.google.com/sdk/docs/install)
#   3. Google Cloud account (free $300 credits for new accounts)
#
# Usage: bash deploy-cloudrun.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── CONFIG — change PROJECT_ID to your Google Cloud project ID ───────────────
PROJECT_ID="deepfake-detection-496320"
SERVICE_NAME="deepfake-detection"
REGION="us-central1"
IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Deepfake Detection — Cloud Run Deployment  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1 — Login
echo "[1/6] Logging into Google Cloud..."
gcloud auth login --quiet
gcloud config set project $PROJECT_ID

# Step 2 — Enable required APIs
echo "[2/6] Enabling required Google Cloud APIs..."
gcloud services enable \
  containerregistry.googleapis.com \
  run.googleapis.com \
  --quiet
echo "      APIs enabled."

# Step 3 — Configure Docker to use GCR
echo "[3/6] Configuring Docker for Google Container Registry..."
gcloud auth configure-docker --quiet

# Step 4 — Build the Docker image
echo "[4/6] Building Docker image..."
echo "      (First build takes 5-10 min — downloading AI model into image)"
docker build -t $IMAGE:latest .
echo "      Build complete."

# Step 5 — Push image to Google Container Registry
echo "[5/6] Pushing image to Google Container Registry..."
docker push $IMAGE:latest
echo "      Image pushed: $IMAGE:latest"

# Step 6 — Deploy to Cloud Run
echo "[6/6] Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 120 \
  --min-instances 0 \
  --max-instances 10 \
  --set-env-vars HF_HUB_DISABLE_SYMLINKS_WARNING=1 \
  --quiet

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --format 'value(status.url)')

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║           Deployment Successful!             ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  URL: $SERVICE_URL"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Useful commands:"
echo "  View logs:    gcloud run services logs read $SERVICE_NAME --region=$REGION"
echo "  Update app:   bash deploy-cloudrun.sh   (re-run this script)"
echo "  Delete app:   gcloud run services delete $SERVICE_NAME --region=$REGION"
echo ""
