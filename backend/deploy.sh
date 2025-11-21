#!/bin/bash

# Susthiram Backend - Cloud Run Deployment Script

# Set the correct project ID
export PROJECT_ID=gcplab-478805

echo "Setting GCP project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

echo ""
echo "Deploying Susthiram Backend to Cloud Run..."
echo "Project ID: $PROJECT_ID"
echo "Region: europe-west1"

# Deploy to Cloud Run
gcloud run deploy susthiram-backend \
    --source . \
    --project $PROJECT_ID \
    --region europe-west1 \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --min-instances 0 \
    --max-instances 5 \
    --concurrency 80 \
    --timeout 300 \
    --set-env-vars "GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=europe-west1,GOOGLE_GENAI_USE_VERTEXAI=True"

echo ""
echo "Deployment complete!"
echo "Your backend URL will be displayed above."
echo ""
echo "To update your Flutter app with the new URL:"
echo "1. Copy the Cloud Run URL from above"
echo "2. Update lib/core/services/agent_orchestrator.dart"
echo "3. Update lib/features/scan/data/gemini_service.dart"
echo "4. Replace 'http://192.168.1.8:8080' with your Cloud Run URL"
