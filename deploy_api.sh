#!/usr/bin/env bash
set -euo pipefail

gcloud functions deploy api-etiquetei \
  --gen2 --runtime python311 --trigger-http --allow-unauthenticated \
  --entry-point api_dashboard --source . \
  --set-env-vars GCP_PROJECT_ID=dashboard-koti-omie,BQ_DATASET=etiquetei \
  --region us-central1 --memory 512MB --timeout 60s
