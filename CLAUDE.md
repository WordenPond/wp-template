# CLAUDE.md

This file provides guidance to Claude Code when working with the PROJECT_NAME codebase.

## Project Overview

**PROJECT_NAME** -- SaaS platform. Update this description after setup.

**Tech Stack:** React 18 + TypeScript + Vite + TailwindCSS | FastAPI + SQLAlchemy | PostgreSQL | Docker + Fly.io

## Quick Reference

### Essential Commands

```bash
# First-time setup: Enable pre-commit hooks
git config core.hooksPath .githooks

# Start full stack
docker-compose up

# Frontend dev (http://localhost:5173)
npm run dev

# Backend dev (http://localhost:8000)
cd api && python main.py

# Run migrations (Alembic)
cd api && python -m alembic upgrade head

# Generate new migration
cd api && python -m alembic revision --autogenerate -m "Description"

# Run tests
npm test                         # Frontend unit tests
cd api && pytest                 # Backend tests (unit + integration)
cd api && pytest -m performance  # Performance tests only
npm run test:e2e                 # E2E tests (Playwright)
npm run test:e2e:ui              # E2E tests (interactive UI mode)
npm run test:e2e:debug           # E2E tests (debug mode)

# Build (always use --no-cache)
docker-compose build --no-cache

# Visual verification (UI/UX changes)
node scripts/capture-screenshots.mjs before
node scripts/capture-screenshots.mjs after
```

### URLs

**Local Development:**
- **Frontend:** http://localhost:8080
- **API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs

**Production:**
- **Frontend:** https://PROJECT_NAME.com
- **API:** https://api.PROJECT_NAME.com

## Documentation

**Detailed documentation in `/docs` directory:**

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** -- System architecture, N-tier layers, services
- **[DATABASE.md](docs/DATABASE.md)** -- Database schema, migrations, models, best practices
- **[DEVELOPMENT.md](docs/DEVELOPMENT.md)** -- Development commands, workflow, debugging
- **[TESTING_GUIDE.md](docs/TESTING_GUIDE.md)** -- Testing best practices, E2E tests, Docker testing
- **[ENVIRONMENT.md](docs/ENVIRONMENT.md)** -- Environment variables configuration
- **[FEATURE_FLAGS.md](docs/FEATURE_FLAGS.md)** -- Feature flag implementation and rollout strategies
- **[LOGGING_GUIDE.md](docs/LOGGING_GUIDE.md)** -- Logging standards and patterns
- **[SECURITY.md](docs/SECURITY.md)** -- OWASP compliance, security checklist
- **[WORKFLOW.md](docs/WORKFLOW.md)** -- Complete 27-step implementation process

**Issue Queue:**
- **[QUEUE.md](QUEUE.md)** -- Ordered issue queue

**Implementation and Workflow:**
- **[IR.md](IR.md)** -- Implementation rules (quick reference checklist)
- **[DP.md](DP.md)** -- Deployment procedures

## Critical Rules

### Pre-Implementation
1. Pull latest: `git pull origin main`
2. Create branch: `rpo_<description>_<issue_number>`
3. Back up database before schema changes

### Implementation
4. Follow DRY and SOLID principles
5. Account for changes across ALL n-tier layers (DB, API, frontend)
6. **PRESERVE DATA** -- No data loss acceptable
7. Update or create tests (unit + e2e)
8. Run eslint: `npm run lint`
9. Consider feature flags for new features
10. Add comprehensive logging to ALL new code

### Testing

11. **CRITICAL: Set DATABASE_URL environment variable (PostgreSQL REQUIRED)**
    ```bash
    export DATABASE_URL="postgresql://user:password@localhost:5432/testdb"
    ```
12. **Run migrations first:** `cd api && python -m alembic upgrade head`
13. Run tests: `cd api && pytest` (backend), `npm test` (frontend)
14. Check Docker status
15. Rebuild with `--no-cache`: `docker-compose build --no-cache && docker-compose up`
16. **Verify data preservation**

**DO NOT use SQLite for testing. ALL tests must run against PostgreSQL.**

### PR and Deployment
17. Update docs (CLAUDE.md, DP.md, README.md)
18. Create PR
19. Resolve medium+ issues from code review
20. Merge to main
21. Rebuild locally with `--no-cache`
22. Run basic tests
23. Verify `/healthz`
24. **STOP** -- Do not auto-deploy to production

## Key Patterns

### Database Sessions
```python
from database_config import get_db_session

with get_db_session() as db:
    result = db.query(Model).filter(...).first()
    # Auto-commit/rollback
```

### Database Migrations (Alembic)
```bash
cd api && python -m alembic upgrade head
cd api && python -m alembic revision --autogenerate -m "Description"
cd api && python -m alembic downgrade -1
cd api && python -m alembic current
cd api && python -m alembic history
```

### Input Sanitization
```python
from validation_utils import sanitize_html, validate_positive_id

clean_text = sanitize_html(user_input)
validate_positive_id(entity_id, "Entity Name")
```

### Error Handling
```typescript
import { extractApiError } from '@/utils/errorUtils';

try {
  const data = await api.getData();
} catch (err: unknown) {
  const apiError = extractApiError(err);
  setError(apiError.message);
}
```

### Feature Flags

```python
# Backend
feature_service = get_feature_flag_service(db_service)
if feature_service.is_enabled('new_feature'):
    pass  # New code path
```

```typescript
// Frontend
const { isEnabled } = useFeatureFlag('new_feature');
return isEnabled ? <NewFeature /> : <OldFeature />;
```

### Currency

```python
# Backend - use Decimal, never float
from decimal import Decimal
price: Decimal = Field(..., ge=Decimal('0'))
```

```typescript
// Frontend - use currency utilities, never Number()
import { addCurrency, formatCurrency } from '@/utils/currency';
const total = addCurrency(price1, price2);
```

### RBAC (Role-Based Access Control)

```python
# Backend
from auth_service import is_admin_user
if is_admin_user(current_user, db): pass
```

```typescript
// Frontend
import { isAdmin } from '@/utils/rbac';
if (isAdmin(user)) { /* ... */ }
```

## Architecture Overview

### Monorepo Structure
```
/src                    # React frontend
/api                    # FastAPI backend
  /alembic              # Alembic migrations
  /email_templates      # Jinja2 templates
/tests/e2e              # Playwright tests
/docs                   # Project documentation
/scripts                # Automation scripts
```

### Backend N-Tier

**API Layer:** `main.py` -- All API endpoints

**Database Layer:**
- `database_config.py` -- Connection factory
- `sqlalchemy_database.py` -- CRUD methods
- `db_models.py` -- ORM models
- `models.py` -- Pydantic models (v2)

**Service Layer:**
- `auth_service.py` -- JWT authentication
- `email_service.py` -- Email notifications
- `feature_flag_service.py` -- Runtime toggles
- `cache_service.py` -- Redis caching

### Frontend

- `/src/components` -- React components
- `/src/services/api.ts` -- API client (Axios)
- `/src/types/index.ts` -- TypeScript interfaces

## Common Pitfalls

1. **Git Hooks:** Run once: `git config core.hooksPath .githooks`
2. **PostgreSQL Required:** ALL tests MUST use PostgreSQL. Set `DATABASE_URL`. NEVER use SQLite.
3. **Python 3.11 Required:** Use Python 3.11 (NOT 3.13) -- psycopg2 compatibility
4. **Migrations:** Always use Alembic, never manual SQL
5. **Idempotency:** Migrations must be reversible (upgrade and downgrade)
6. **Data Loss:** Never drop tables or columns with data
7. **Sessions:** Always use `with get_db_session() as db:` pattern
8. **IDs:** Use `validate_positive_id()` before queries
9. **Input:** Use `sanitize_html()` on all user text
10. **Docker:** Always rebuild with `--no-cache` for testing
11. **Currency:** Use `Decimal` (backend) and currency utilities (frontend), never `float` or `Number()`
12. **Logging:** Never log passwords, tokens, API keys
13. **Feature Flags:** Consider for all new user-facing features
14. **TODO Comments:** NEVER use TODO/FIXME/XXX/HACK -- create GitHub issues instead
15. **Visual Verification:** ALWAYS capture before/after screenshots for UI/UX changes
