# Deploy to Production

## Deployment Workflow

**CRITICAL:** Always deploy to staging before production to test migrations and changes.

### Recommended Deployment Flow

```
1. Local Testing -> 2. Staging Deployment -> 3. Staging Verification -> 4. Production Deployment
```

**Process:**
1. **Local**: Test in Docker (`docker-compose up`)
2. **Staging**: Auto-deploy on merge to `main` (GitHub Actions)
3. **Verify**: Test migrations and features in staging
4. **Production**: Manual deployment after staging verification

## Staging Environment

**Purpose:** Pre-production testing environment for migration validation and QA

### Quick Access

- **Frontend:** https://staging.PROJECT_NAME.com
- **API:** https://api.staging.PROJECT_NAME.com
- **Health Check:** `./scripts/verify-deployment.sh staging`

### Automatic Deployment

Staging deploys automatically when:
- Code merged to `main` branch
- All CI tests pass
- GitHub Actions workflow: `.github/workflows/deploy-staging.yml`

### Manual Deployment

```bash
# Trigger staging deployment manually
gh workflow run deploy-staging.yml

# Or deploy directly to staging
flyctl deploy --config fly.staging.toml --remote-only  # Frontend
cd api && flyctl deploy --config fly.staging.toml --remote-only  # API
```

### Testing Migrations in Staging

**Always test migrations in staging before production:**

```bash
# 1. Create migration locally
cd api && python -m alembic revision --autogenerate -m "Add new column"

# 2. Test locally
docker-compose down -v && docker-compose build --no-cache && docker-compose up -d

# 3. Push to main (triggers automatic staging deployment)
git add . && git commit -m "Add migration" && git push origin main

# 4. Wait for GitHub Actions to deploy to staging

# 5. Verify staging deployment
./scripts/verify-deployment.sh staging

# 6. SSH into staging API to verify migration
flyctl ssh console -a PROJECT_NAME-api-staging
cd /app && python -m alembic current

# 7. If all tests pass, deploy to production (see below)
```

### Staging Configuration

**Environment Variables:**
- Use **test** Stripe keys (`pk_test_*`, `sk_test_*`)
- Separate database from production
- Different API keys and secrets
- `ENVIRONMENT=staging`

### When to Skip Staging

**NEVER skip staging for:**
- Database migrations
- Schema changes
- API endpoint changes
- Payment processing updates
- Authentication/authorization changes

**May skip staging for:**
- Documentation updates only
- README changes
- Comment-only changes

## Pre-Deployment Checks
- Verify fly.io environment variables are set to the production versions
- Ensure CORS settings are the production ones
- Create a database backup before performing any SQL updates
- Verify API keys are production versions (see API Keys Configuration below)

## API Keys Configuration (Production)

**IMPORTANT:** Production deployments must use production API keys, not test keys.

### Stripe API Keys
```bash
# Set production Stripe keys in Fly.io
flyctl secrets set VITE_STRIPE_PUBLIC_KEY=pk_live_... -a PROJECT_NAME
flyctl secrets set STRIPE_SECRET_KEY=sk_live_... -a PROJECT_NAME-api
```

**Critical Rules:**
- **Production:** Use live keys (`pk_live_...` and `sk_live_...`)
- **Development:** NEVER use live keys -- always use test keys (`pk_test_...` and `sk_test_...`)
- Live keys process real payments -- use with caution
- Never commit API keys to git -- use `flyctl secrets` only

### Verify Configuration
```bash
# List all secrets (values hidden for security)
flyctl secrets list -a PROJECT_NAME
flyctl secrets list -a PROJECT_NAME-api
```

## Deployment Process

Deploy to fly.io using: `flyctl deploy --remote-only`
- Frontend: Deploy from root directory
- Backend: Deploy from `api/` directory using `cd api && flyctl deploy --remote-only`

**Fly.io App Names:**
- Frontend: `PROJECT_NAME`
- Backend API: `PROJECT_NAME-api`
- Database: `PROJECT_NAME-db`

**Staging App Names:**
- Frontend: `PROJECT_NAME-staging`
- Backend API: `PROJECT_NAME-api-staging`

## PostgreSQL Database Deployment

**Overview:** PostgreSQL 15 deployed on Fly.io with persistent volume. The database provides ACID compliance, advanced querying features, and timezone-aware timestamp support.

### Database Configuration

**Setup:**
```bash
# Internal connection string (used by API):
postgresql://postgres:<PASSWORD>@PROJECT_NAME-db.internal:5432/PROJECT_NAME

# Set via Fly.io secret:
flyctl secrets set DATABASE_URL="postgresql://postgres:<PASSWORD>@PROJECT_NAME-db.internal:5432/PROJECT_NAME" -a PROJECT_NAME-api
```

### Database Migrations

**Alembic is the migration tool.**

```bash
# Migrations run automatically on API container startup
# Manual migration (if needed):
flyctl ssh console -a PROJECT_NAME-api
cd /app && python -m alembic upgrade head

# Check current migration version:
python -m alembic current

# View migration history:
python -m alembic history
```

### Creating New Migrations
```bash
# Local development:
cd api && python -m alembic revision --autogenerate -m "Description of changes"

# Review generated migration before deploying:
cat api/alembic/versions/<revision>.py

# Test locally first:
cd api && python -m alembic upgrade head

# Deploy to production:
cd api && flyctl deploy --remote-only -a PROJECT_NAME-api
```

### Database Access
```bash
# SSH into PostgreSQL machine:
flyctl ssh console -a PROJECT_NAME-db

# Connect to PostgreSQL CLI:
psql -U postgres -d PROJECT_NAME

# Common queries:
\dt                           # List tables
\d users                      # Describe users table
SELECT COUNT(*) FROM users;   # Check user count
\q                            # Quit
```

### Backup and Restore
```bash
# Create backup:
flyctl ssh console -a PROJECT_NAME-db
pg_dump -U postgres -d PROJECT_NAME > /tmp/backup_$(date +%Y%m%d_%H%M%S).sql

# Download backup to local machine:
flyctl ssh sftp get /tmp/backup_YYYYMMDD_HHMMSS.sql -a PROJECT_NAME-db
```

### Troubleshooting

**Problem: API cannot connect to database**
```bash
# Check DATABASE_URL is set:
flyctl secrets list -a PROJECT_NAME-api

# Verify PostgreSQL is running:
flyctl status -a PROJECT_NAME-db

# Test connection from API machine:
flyctl ssh console -a PROJECT_NAME-api
psql "$DATABASE_URL" -c "SELECT version();"
```

**Problem: Migrations failing**
```bash
# Check current migration version:
flyctl ssh console -a PROJECT_NAME-api
python -m alembic current

# View migration errors in logs:
flyctl logs -a PROJECT_NAME-api | grep alembic
```

## Redis Caching Deployment

**Overview:** Redis caching provides significant performance improvement for frequently accessed endpoints using cache-aside pattern with circuit breaker fail-open design.

### Pre-Deployment Configuration

```bash
# Option A: Deploy Redis on Fly.io (recommended)
flyctl launch --name PROJECT_NAME-redis --region <your-region> --no-deploy
# Edit fly.toml: set image to redis:7-alpine
flyctl deploy -a PROJECT_NAME-redis

# Set Redis connection secrets
flyctl secrets set REDIS_HOST=PROJECT_NAME-redis.internal -a PROJECT_NAME-api
flyctl secrets set REDIS_PORT=6379 -a PROJECT_NAME-api
flyctl secrets set REDIS_PASSWORD=<strong-random-password> -a PROJECT_NAME-api
flyctl secrets set ENABLE_CACHE=true -a PROJECT_NAME-api
```

### Verify Redis Connection
```bash
# Check Redis health endpoint
curl https://api.PROJECT_NAME.com/healthz/redis
```

### Rollback Redis
```bash
# Disable cache via environment variable (no downtime)
flyctl secrets set ENABLE_CACHE=false -a PROJECT_NAME-api
flyctl machine restart <machine-id> -a PROJECT_NAME-api
```

## Security Headers and Content Security Policy (CSP)

**Overview:** The frontend nginx configuration should include comprehensive security headers including Content Security Policy (CSP) to protect against XSS, clickjacking, and other web vulnerabilities.

### Required Security Headers
```nginx
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options DENY;
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy strict-origin-when-cross-origin;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Permissions-Policy "geolocation=(self), microphone=(), camera=()";
```

### CSP Configuration Template
```nginx
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline' fonts.googleapis.com;
  font-src 'self' fonts.gstatic.com;
  img-src 'self' data: https:;
  connect-src 'self' https://api.PROJECT_NAME.com;
  object-src 'none';
  base-uri 'self';
  form-action 'self';
";
```

**IMPORTANT:** When adding new API endpoints or third-party services, update the CSP `connect-src` directive accordingly.

### Testing CSP Changes
```bash
# Local testing with Docker
docker-compose build --no-cache frontend
docker-compose up frontend
# Visit http://localhost:8080
# Open browser DevTools Console and look for CSP violations
```

## Post-Deployment Validation
- Resolve any deployment issues
- Ensure that any changes made to production are documented
- Run smoke tests to verify basic functionality:
  - Application loads without errors
  - User can login without error
  - Admin can login and no errors occur
- Monitor deployment logs for errors: `flyctl logs -a <app-name>`

## Scaling Considerations

**Vertical Scaling (Database):**
```bash
# Scale database memory
flyctl scale memory 2048 -a PROJECT_NAME-db

# Upgrade to dedicated CPU
flyctl scale vm dedicated-cpu-1x -a PROJECT_NAME-db
```

**Volume Expansion:**
```bash
# Expand database volume (cannot shrink)
flyctl volumes list -a PROJECT_NAME-db
flyctl volumes extend <volume-id> -s 20 -a PROJECT_NAME-db
```

## Cleanup
- Close any related GitHub issues and delete the local and remote branch
