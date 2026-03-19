# Testing Guide

## Testing Philosophy

1. **Docker only** -- Always test in Docker containers, not local dev servers
2. **PostgreSQL required** -- NEVER use SQLite for tests; set `DATABASE_URL` to a PostgreSQL instance
3. **Minimize mocking** -- Use real database operations where possible; mocks hide real bugs
4. **Test all layers** -- Unit tests for logic, integration tests for APIs, E2E for user flows

## Environment Setup

Before running any backend tests:

```bash
# Required: Set PostgreSQL connection string
export DATABASE_URL="postgresql://postgres:password@localhost:5432/PROJECT_NAME_test"

# Apply migrations to test database
cd api && python -m alembic upgrade head
```

## Backend Tests (pytest)

Tests are organized into subdirectories:

```
api/tests/
  unit/          # Fast, isolated tests (no database)
  integration/   # API endpoint and database tests
  performance/   # Benchmark tests (excluded from default run)
```

### Running Backend Tests

```bash
# All tests (unit + integration, excludes performance)
cd api && pytest

# Unit tests only (fast)
cd api && pytest tests/unit/

# Integration tests only
cd api && pytest tests/integration/

# Performance tests (slow -- run separately)
cd api && pytest -m performance

# Specific test file
cd api && pytest tests/unit/test_something.py -v

# Run tests matching a keyword
cd api && pytest -k "test_user" -v

# With coverage report
cd api && pytest --cov=. --cov-report=html
```

### Writing Backend Tests

```python
import pytest
from httpx import AsyncClient
from main import app

@pytest.mark.asyncio
async def test_create_user(db_session):
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post("/api/users", json={
            "email": "test@example.com",
            "password": "securepassword"
        })
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"
```

## Frontend Tests (Vitest)

```bash
# Run all frontend unit tests
npm test

# Run in watch mode (for development)
npm run test:watch

# With coverage
npm run test:coverage
```

### Writing Frontend Tests

```typescript
import { render, screen } from '@testing-library/react';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders the title', () => {
    render(<MyComponent title="Hello" />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });
});
```

## E2E Tests (Playwright)

E2E tests run against Docker containers for a production-like environment.

```bash
# Start Docker stack first
docker-compose up -d

# Run all E2E tests
npm run test:e2e

# Run with interactive UI
npm run test:e2e:ui

# Run in debug mode
npm run test:e2e:debug

# Run specific test file
npx playwright test tests/e2e/auth.spec.ts

# Run critical tests only (fast subset)
npx playwright test --project=critical
```

### Writing E2E Tests

```typescript
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');
  await expect(page).toHaveURL('/dashboard');
});
```

## Performance Tests

Performance tests are excluded from the default pytest run to avoid slowing CI:

```bash
# Run performance benchmarks
cd api && pytest -m performance

# Run with detailed output
cd api && pytest -m performance -v --tb=short
```

## Running All Tests

```bash
# Full test suite (runs in Docker)
./scripts/run-all-tests.sh
```

## CI Strategy

- **PRs:** Run unit + integration tests (fast, ~5-10 min)
- **Main branch:** Run full suite including E2E tests (~30-60 min)

## Test Data

Use factories or fixtures to create test data -- never use production data:

```python
# conftest.py
@pytest.fixture
def test_user(db_session):
    user = User(email="test@example.com", password_hash="...")
    db_session.add(user)
    db_session.commit()
    return user
```

## Common Issues

**Tests fail with "connection refused":** PostgreSQL is not running -- start Docker first.

**"Table not found" errors:** Run `cd api && python -m alembic upgrade head` to apply migrations.

**E2E tests fail with "server not started":** Docker stack is not running -- run `docker-compose up -d`.

**Slow tests:** Check for missing database indexes; add indexes to columns used in WHERE clauses.
