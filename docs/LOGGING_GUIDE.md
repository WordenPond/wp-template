# Logging Guide

## Overview

Comprehensive logging is mandatory in PROJECT_NAME. Every new function, endpoint, and service method must include appropriate log statements. This makes debugging in production possible without having to redeploy.

## Logging Levels

| Level | When to Use | Example |
|-------|-------------|---------|
| `DEBUG` | Entry points, intermediate steps, detailed operations | "Fetching user by email", "Processing 42 records" |
| `INFO` | Successful completions, important state changes | "User created successfully", "Payment processed" |
| `WARNING` | Non-fatal issues, validation failures, degraded behavior | "Email send failed, retrying", "Cache miss rate high" |
| `ERROR` | Exceptions, failures requiring attention | "Database connection failed", "Payment declined" |

## Backend Logging (Python)

### Setup

```python
import logging

logger = logging.getLogger(__name__)
```

### Code Examples

```python
def create_user(email: str, password: str, db) -> User:
    logger.debug(f"Creating user with email: {email}")

    # Validate input
    if not email or "@" not in email:
        logger.warning(f"Invalid email format provided: {email[:3]}...")
        raise ValueError("Invalid email format")

    try:
        user = User(email=email, password_hash=hash_password(password))
        db.add(user)
        db.commit()
        logger.info(f"User created successfully: id={user.id}")
        return user
    except IntegrityError as e:
        logger.error(f"Failed to create user -- email already exists: {email}", exc_info=True)
        raise

def process_payment(amount: Decimal, user_id: int) -> PaymentResult:
    logger.debug(f"Processing payment: amount={amount}, user_id={user_id}")

    try:
        result = stripe.charge(amount=amount)
        logger.info(f"Payment processed successfully: charge_id={result.id}, amount={amount}")
        return result
    except stripe.StripeError as e:
        logger.error(f"Payment failed: user_id={user_id}, amount={amount}", exc_info=True)
        raise
```

### API Endpoint Logging

```python
@router.get("/users/{user_id}")
async def get_user(user_id: int, db = Depends(get_db)):
    logger.debug(f"GET /users/{user_id} requested")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        logger.warning(f"User not found: id={user_id}")
        raise HTTPException(status_code=404, detail="User not found")

    logger.debug(f"User retrieved: id={user_id}")
    return user
```

## Frontend Logging (TypeScript)

Use structured console logging in development; integrate with a monitoring service (e.g., Sentry) for production:

```typescript
// src/utils/logger.ts
const isDev = import.meta.env.DEV;

export const logger = {
  debug: (message: string, data?: unknown) => {
    if (isDev) console.debug(`[DEBUG] ${message}`, data);
  },
  info: (message: string, data?: unknown) => {
    console.info(`[INFO] ${message}`, data);
  },
  warn: (message: string, data?: unknown) => {
    console.warn(`[WARN] ${message}`, data);
  },
  error: (message: string, error?: unknown) => {
    console.error(`[ERROR] ${message}`, error);
    // Send to Sentry in production
  },
};
```

```typescript
// Usage in components/services
import { logger } from '@/utils/logger';

async function fetchUser(userId: number) {
  logger.debug('Fetching user', { userId });
  try {
    const user = await api.getUser(userId);
    logger.info('User fetched successfully', { userId });
    return user;
  } catch (err) {
    logger.error('Failed to fetch user', err);
    throw err;
  }
}
```

## Mandatory Logging Rules

1. **Always log entry points** at DEBUG level for every public function/endpoint
2. **Always log successful completions** at INFO level with relevant IDs
3. **Always log validation failures** at WARNING level
4. **Always log exceptions** at ERROR level with `exc_info=True` (backend)
5. **Log with context** -- include IDs, not just messages

## What NOT to Log

**NEVER log these -- they are security violations:**

- Passwords or password hashes
- JWT tokens or session tokens
- API keys or secrets
- Full credit card numbers or CVVs
- Social Security Numbers or government IDs
- Full database connection strings with passwords

```python
# BAD -- logs password
logger.debug(f"Login attempt: email={email}, password={password}")

# GOOD -- logs only what's needed
logger.debug(f"Login attempt: email={email}")
```

## Log Format

Backend logs should be structured JSON in production. Configure via `logging_config.py`:

```json
{
  "timestamp": "2026-01-01T00:00:00Z",
  "level": "INFO",
  "name": "auth_service",
  "message": "User login successful",
  "user_id": 42,
  "environment": "production"
}
```
