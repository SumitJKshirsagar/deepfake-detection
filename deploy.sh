#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Deepfake Detection — GKE Deploy Script
# Usage: bash deploy.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e  # exit on any error

# ── CONFIG — change these ────────────────────────────────────────────────────
PROJECT_ID="your-gcp-project-id"       # your Google Cloud project ID
CLUSTER_NAME="deepfake-cluster"
REGION="us-central1"
IMAGE="gcr.io/$PROJECT_ID/deepfake-detection"
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "======================================================"
echo "  Deepfake Detection — Deploying to GKE"
echo "======================================================"
echo ""

# 1. Authenticate with Google Cloud
echo "[1/7] Authenticating with Google Cloud..."
gcloud auth configure-docker --quiet

# 2. Set project
echo "[2/7] Setting project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 3. Build Docker image
echo "[3/7] Building Docker image (this takes a few minutes)..."
docker build -t $IMAGE:latest .
echo "      Image built successfully."

# 4. Push to Google Container Registry
echo "[4/7] Pushing image to Google Container Registry..."
docker push $IMAGE:latest
echo "      Image pushed: $IMAGE:latest"

# 5. Create GKE cluster (skip if it already exists)
echo "[5/7] Checking GKE cluster..."
if gcloud container clusters describe $CLUSTER_NAME --region=$REGION --quiet 2>/dev/null; then
  echo "      Cluster '$CLUSTER_NAME' already exists. Skipping creation."
else
  echo "      Creating GKE Autopilot cluster (this takes ~5 minutes)..."
  gcloud container clusters create-auto $CLUSTER_NAME \
    --region=$REGION \
    --quiet
  echo "      Cluster created."
fi

# 6. Get credentials for kubectl
echo "[6/7] Fetching cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION --quiet

# 7. Apply Kubernetes manifests
echo "[7/7] Deploying to Kubernetes..."

# Update image in deployment
sed -i "s|gcr.io/YOUR_PROJECT_ID/deepfake-detection:latest|$IMAGE:latest|g" kubernetes/deployment.yaml

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml

echo ""
echo "======================================================"
echo "  Deployment complete!"
echo "======================================================"
echo ""
echo "Waiting for external IP (may take 2-3 minutes)..."
echo ""

kubectl get service deepfake-detection-service -n deepfake-detection --watch &
WATCH_PID=$!

# Poll for external IP
for i in $(seq 1 30); do
  sleep 10
  EXTERNAL_IP=$(kubectl get service deepfake-detection-service -n deepfake-detection \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [ -n "$EXTERNAL_IP" ]; then
    kill $WATCH_PID 2>/dev/null
    echo ""
    echo "======================================================"
    echo "  Your app is live at: http://$EXTERNAL_IP"
    echo "======================================================"
    echo ""
    break
  fi
done

echo ""
echo "Useful commands:"
echo "  kubectl get pods -n deepfake-detection          # check pod status"
echo "  kubectl get hpa  -n deepfake-detection          # check autoscaler"
echo "  kubectl logs -f <pod-name> -n deepfake-detection  # view logs"
echo ""
