# Development Guide

## Prerequisites

Before starting, install the following:

| Tool | Version | Install |
|------|---------|---------|
| Docker Desktop | Latest | https://www.docker.com/products/docker-desktop |
| Node.js | 20+ | https://nodejs.org/ |
| Python | 3.11 (NOT 3.13) | https://www.python.org/ |
| flyctl | Latest | `curl -L https://fly.io/install.sh | sh` |
| Git | Latest | https://git-scm.com/ |

**Python 3.11 is required** -- psycopg2 has compatibility issues with Python 3.13.

## First-Time Setup

```bash
# 1. Clone the repo
git clone https://github.com/WordenPond/PROJECT_NAME.git
cd PROJECT_NAME

# 2. Enable git hooks (IMPORTANT -- prevents bad commits)
git config core.hooksPath .githooks

# 3. Install frontend dependencies
npm install

# 4. Install backend dependencies
cd api && pip install -r requirements.txt && cd ..

# 5. Copy environment files
cp .env.example .env
cp api/.env.example api/.env
# Edit both .env files with your local credentials

# 6. Start the full stack
docker-compose up
```

## Daily Development Workflow

```bash
# Start all services
docker-compose up

# Or start in background
docker-compose up -d

# View logs
docker-compose logs -f api
docker-compose logs -f frontend

# Stop all services
docker-compose down
```

### Frontend Development (hot reload)

```bash
# Start Vite dev server (http://localhost:5173)
npm run dev
```

### Backend Development

```bash
# Run FastAPI directly (http://localhost:8000)
cd api && python main.py

# Apply migrations
cd api && python -m alembic upgrade head

# Generate new migration after model changes
cd api && python -m alembic revision --autogenerate -m "Add new table"
```

## Common Commands Reference

### Git Workflow
```bash
# Start new feature
git checkout main && git pull origin main
git checkout -b rpo_<description>_<issue_number>

# After implementation, push and create PR
git push origin rpo_<description>_<issue_number>
gh pr create --title "feat: ..." --body "Closes #<issue>"
```

### Testing
```bash
npm test                              # Frontend unit tests
cd api && pytest                      # Backend tests
npm run test:e2e                      # E2E tests (requires Docker)

# Run specific test file
cd api && pytest tests/unit/test_something.py -v
npx playwright test tests/e2e/something.spec.ts
```

### Docker Management
```bash
# Rebuild everything (use after dependency changes)
docker-compose build --no-cache

# Rebuild specific service
docker-compose build --no-cache api

# Remove all containers and volumes (clean slate)
docker-compose down -v

# Shell into running container
docker exec -it PROJECT_NAME-api bash
```

### Database
```bash
# Apply migrations
cd api && python -m alembic upgrade head

# Check migration status
cd api && python -m alembic current

# Connect to PostgreSQL (Docker must be running)
docker exec -it PROJECT_NAME-db psql -U postgres -d PROJECT_NAME
```

## Debugging Tips

### Backend

1. Check API logs: `docker-compose logs -f api`
2. Access API docs: http://localhost:8000/docs
3. Enable debug logging by setting `LOG_LEVEL=DEBUG` in `api/.env`
4. Use `print()` temporarily, then replace with proper logging

### Frontend

1. Open browser DevTools (F12)
2. Check Console for errors
3. Check Network tab for failed API requests
4. Inspect React component state with React DevTools extension

### Database Issues

1. Check migration status: `cd api && python -m alembic current`
2. View all tables: `docker exec -it PROJECT_NAME-db psql -U postgres -d PROJECT_NAME -c "\dt"`
3. Check PostgreSQL logs: `docker-compose logs -f db`

### Docker Issues

1. Container won't start: `docker-compose logs <service>` to see the error
2. Port conflicts: Check if another process is using port 8000 or 8080
3. Build failures: Run `docker-compose build --no-cache <service>` to force rebuild

## Environment Variables

See [ENVIRONMENT.md](ENVIRONMENT.md) for all environment variables and their descriptions.

**Required for development:**
- `DATABASE_URL` -- PostgreSQL connection string
- `SECRET_KEY` -- JWT signing secret (any random string for dev)

## Code Quality

```bash
# Run linter (must pass before PR)
npm run lint

# Auto-fix lint issues
npm run lint:fix

# Type check frontend
npm run type-check

# Format code
npm run format
```
