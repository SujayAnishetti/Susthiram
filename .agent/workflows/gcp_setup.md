---
description: How to setup GCP and Vertex AI for Susthiram
---

# GCP & Vertex AI Setup Workflow

Follow these steps to configure your Google Cloud Project for the backend agents.

## 1. Install Google Cloud CLI

If `gcloud` is not installed, download and install it from [here](https://cloud.google.com/sdk/docs/install).

## 2. Initialize & Login

Run the following commands in your terminal:

```bash
# Login to your Google Account
gcloud auth login

# Set your project ID (replace YOUR_PROJECT_ID with your actual ID, e.g., susthiram-92ca8)
gcloud config set project YOUR_PROJECT_ID
```

## 3. Enable Required APIs

We need to enable Vertex AI, Cloud Run, and Container Registry APIs.

```bash
gcloud services enable aiplatform.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

## 4. Authenticate for Application Default Credentials (ADC)

This allows your local code (and backend) to use your user credentials to access Vertex AI.

```bash
gcloud auth application-default login
```

## 5. Verify Setup

Run the backend locally again. It should now be able to access Vertex AI if the code is updated to use `google-cloud-aiplatform`.
