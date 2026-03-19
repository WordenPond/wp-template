# Environment Variables

## Overview

PROJECT_NAME uses environment variables for configuration. Never commit secrets to git -- use `.env` files locally and Fly.io secrets for production.

## Required Variables

### Backend (`api/.env`)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | Yes | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/PROJECT_NAME` |
| `SECRET_KEY` | Yes | JWT signing secret (min 32 chars) | `supersecretkey123...` |
| `ENVIRONMENT` | Yes | Runtime environment | `development`, `staging`, `production` |
| `LOG_LEVEL` | No | Logging verbosity | `DEBUG`, `INFO`, `WARNING`, `ERROR` |
| `STRIPE_SECRET_KEY` | For payments | Stripe secret key | `sk_test_...` or `sk_live_...` |
| `SMTP_HOST` | For email | Email server hostname | `smtp.gmail.com` |
| `SMTP_PORT` | For email | Email server port | `587` |
| `SMTP_USER` | For email | Email username | `noreply@PROJECT_NAME.com` |
| `SMTP_PASSWORD` | For email | Email password | `apppassword...` |
| `REDIS_HOST` | For caching | Redis hostname | `localhost` |
| `REDIS_PORT` | For caching | Redis port | `6379` |
| `REDIS_PASSWORD` | For caching | Redis auth password | `redispassword...` |
| `ENABLE_CACHE` | No | Enable Redis caching | `true` or `false` |

### Frontend (`/.env`)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `VITE_API_URL` | Yes | Backend API base URL | `http://localhost:8000` |
| `VITE_STRIPE_PUBLIC_KEY` | For payments | Stripe publishable key | `pk_test_...` or `pk_live_...` |

## DATABASE_URL Format

```
postgresql://USERNAME:PASSWORD@HOST:PORT/DATABASE_NAME
```

**Local Docker:**
```
postgresql://postgres:password@localhost:5432/PROJECT_NAME
```

**Production (Fly.io private network):**
```
postgresql://postgres:PASSWORD@PROJECT_NAME-db.internal:5432/PROJECT_NAME
```

## Stripe Keys

**Development:** Always use test keys (`pk_test_...` / `sk_test_...`)
**Production:** Use live keys (`pk_live_...` / `sk_live_...`)

Never swap these -- live keys process real payments.

## .env.example

Create this file in your repo root (committed) as a template:

```bash
# Backend (api/.env)
DATABASE_URL=postgresql://postgres:password@localhost:5432/PROJECT_NAME
SECRET_KEY=change-this-to-a-random-secret-at-least-32-characters
ENVIRONMENT=development
LOG_LEVEL=INFO

# Stripe (use test keys for development)
STRIPE_SECRET_KEY=sk_test_...

# Email (optional for local dev)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=

# Redis (optional for local dev)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
ENABLE_CACHE=false
```

```bash
# Frontend (.env)
VITE_API_URL=http://localhost:8000
VITE_STRIPE_PUBLIC_KEY=pk_test_...
```

## Setting Production Secrets (Fly.io)

```bash
# Set individual secret
flyctl secrets set DATABASE_URL="postgresql://..." -a PROJECT_NAME-api

# Set multiple secrets at once
flyctl secrets set \
  SECRET_KEY="..." \
  ENVIRONMENT="production" \
  -a PROJECT_NAME-api

# List all secrets (values hidden)
flyctl secrets list -a PROJECT_NAME-api

# Remove a secret
flyctl secrets unset OLD_VARIABLE -a PROJECT_NAME-api
```

## Security Rules

- NEVER commit `.env` files to git (add to `.gitignore`)
- NEVER log environment variable values
- NEVER expose secrets in API responses
- Use `flyctl secrets` for production, never environment variables in fly.toml
