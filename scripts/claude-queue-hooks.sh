#!/usr/bin/env bash
# claude-queue-hooks.sh -- Project-specific Telegram command hooks
# Sourced by claude-queue telegram-receiver workflow
# Replace PROJECT_NAME with your actual project name after running setup.sh

PROJECT_NAME="PROJECT_NAME"

deploy_production() {
  echo "Deploying PROJECT_NAME to production..."
  cd api && flyctl deploy --remote-only -a PROJECT_NAME-api
  flyctl deploy --remote-only -a PROJECT_NAME
  echo "Deploy complete."
}

deploy_staging() {
  echo "Deploying PROJECT_NAME to staging..."
  cd api && flyctl deploy --config fly.staging.toml --remote-only -a PROJECT_NAME-api-staging
  flyctl deploy --config fly.staging.toml --remote-only -a PROJECT_NAME-staging
  echo "Staging deploy complete."
}

health_check() {
  curl -sf https://api.PROJECT_NAME.com/healthz && echo "API healthy" || echo "API unhealthy"
  curl -sf https://PROJECT_NAME.com && echo "Frontend healthy" || echo "Frontend unhealthy"
}

staging_health_check() {
  curl -sf https://api.staging.PROJECT_NAME.com/healthz && echo "Staging API healthy" || echo "Staging API unhealthy"
}
