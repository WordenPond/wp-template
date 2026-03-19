# Security Guide

## Overview

PROJECT_NAME follows OWASP Top 10 security best practices. All code must be reviewed against this checklist before merging.

## OWASP Top 10 Compliance Checklist

### A01: Broken Access Control
- [ ] All API endpoints check authentication before processing
- [ ] All API endpoints check authorization (role/permission) before processing
- [ ] Admin endpoints require admin role, not just login
- [ ] Users cannot access other users' data (verify ownership)
- [ ] CORS is configured to only allow the production frontend domain

### A02: Cryptographic Failures
- [ ] Passwords are hashed with bcrypt (never stored plain)
- [ ] JWT secrets are sufficiently long and random (32+ chars)
- [ ] HTTPS enforced via HSTS header in nginx
- [ ] Sensitive data is not stored in browser localStorage (use httpOnly cookies or memory)

### A03: Injection
- [ ] All database queries use SQLAlchemy ORM (never raw SQL with string formatting)
- [ ] All user text inputs are sanitized with `sanitize_html()` before storage
- [ ] File paths are validated and restricted to safe directories
- [ ] No command injection -- never pass user input to `os.system()` or `subprocess`

### A04: Insecure Design
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout after N failed login attempts
- [ ] Password complexity requirements enforced

### A05: Security Misconfiguration
- [ ] Debug mode disabled in production (`ENVIRONMENT=production`)
- [ ] Error messages don't leak stack traces to users
- [ ] Default admin credentials changed on first deploy
- [ ] Unnecessary API endpoints removed or disabled

### A06: Vulnerable and Outdated Components
- [ ] `npm audit` passes with no high/critical vulnerabilities
- [ ] `pip-audit` passes with no known vulnerabilities
- [ ] Dependencies updated quarterly

### A07: Identification and Authentication Failures
- [ ] JWT tokens have expiration (`exp` claim)
- [ ] Refresh token rotation implemented
- [ ] Password reset tokens are single-use and expire

### A08: Software and Data Integrity Failures
- [ ] Dependencies are pinned to specific versions
- [ ] GitHub Actions uses pinned action versions

### A09: Security Logging and Monitoring Failures
- [ ] Login successes and failures are logged
- [ ] Admin actions are logged with user ID
- [ ] Suspicious activity patterns are logged at WARNING level

### A10: Server-Side Request Forgery (SSRF)
- [ ] External URLs in API requests are validated against an allowlist
- [ ] Webhook URLs are validated

## Input Sanitization Patterns

### Backend

```python
from validation_utils import sanitize_html, validate_positive_id

# Sanitize all text that will be rendered as HTML
clean_description = sanitize_html(request.description)

# Validate all ID parameters before database queries
validate_positive_id(user_id, "User")
validate_positive_id(fair_id, "Fair")
```

### Frontend

```typescript
// Never use dangerouslySetInnerHTML with user content
// BAD:
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// GOOD: Let React escape it
<div>{userContent}</div>

// If HTML is needed, use a sanitization library
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

## Authentication and Authorization

### Backend Auth Pattern

```python
from auth_service import get_current_user, is_admin_user

@router.delete("/admin/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user = Depends(get_current_user),
    db = Depends(get_db)
):
    # Check authentication (get_current_user raises 401 if not authenticated)
    # Check authorization
    if not is_admin_user(current_user, db):
        raise HTTPException(status_code=403, detail="Admin access required")

    validate_positive_id(user_id, "User")
    # ... proceed with deletion
```

### Never Bypass Auth

```python
# BAD -- skips authorization check
@router.get("/admin/users")
async def get_all_users(db = Depends(get_db)):
    return db.query(User).all()

# GOOD -- requires admin role
@router.get("/admin/users")
async def get_all_users(
    current_user = Depends(get_current_user),
    db = Depends(get_db)
):
    if not is_admin_user(current_user, db):
        raise HTTPException(status_code=403, detail="Forbidden")
    return db.query(User).all()
```

## Never Log Secrets

```python
# BAD
logger.debug(f"Connecting with password: {db_password}")
logger.info(f"API key: {api_key}")

# GOOD
logger.debug("Connecting to database")
logger.info("API key configured")
```

## SQL Injection Prevention

**Always use the ORM. Never use string formatting in queries.**

```python
# BAD -- SQL injection vulnerability
db.execute(f"SELECT * FROM users WHERE email = '{email}'")

# GOOD -- parameterized via ORM
db.query(User).filter(User.email == email).first()

# GOOD -- parameterized raw SQL (if ORM cannot be used)
db.execute(text("SELECT * FROM users WHERE email = :email"), {"email": email})
```

## Content Security Policy (CSP)

See [DP.md](../DP.md) for the nginx CSP configuration template. Update the `connect-src` directive whenever you add a new API domain or third-party service.

## Security Review Checklist (Pre-PR)

Before every PR, verify:
- [ ] No raw SQL string formatting
- [ ] All user inputs sanitized
- [ ] All IDs validated with `validate_positive_id()`
- [ ] All endpoints have proper auth checks
- [ ] No secrets in code or logs
- [ ] `npm audit` passes
- [ ] Error responses don't leak internal details
