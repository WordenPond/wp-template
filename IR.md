# Implementation Rules

Quick reference checklist for implementing features. **See [WORKFLOW.md](docs/WORKFLOW.md) for complete 27-step process.**

## Quick Start

```bash
# First-time setup: Enable pre-commit hooks (prevents duplicate migrations)
git config core.hooksPath .githooks

# Start new feature
./scripts/start-feature.sh <issue_number> "<description>"

# UI/UX changes: Capture BEFORE screenshots
node scripts/capture-screenshots.mjs before

# ... implement changes ...

# Run all tests
./scripts/run-all-tests.sh

# UI/UX changes: Capture AFTER screenshots
node scripts/capture-screenshots.mjs after

# Pre-commit checks
./scripts/pre-commit-checks.sh

# Verify deployment
./scripts/verify-deployment.sh local
```

## First-Time Setup

**ONE-TIME:** Enable pre-commit hooks (prevents: duplicate migrations, TODO comments, legacy RBAC flags, type sync issues):

```bash
git config core.hooksPath .githooks
```

Verify hooks are enabled:
```bash
git config core.hooksPath
# Should output: .githooks
```

**CRITICAL FOR ALL AGENTS:** The pre-commit hook blocks TODO/FIXME/XXX/HACK comments.
- DO NOT use TODO comments in code
- DO create GitHub issues and reference them: `// See Issue #123`

## Pre-Implementation Checklist

- [ ] **ONE-TIME:** Enable git hooks: `git config core.hooksPath .githooks`
- [ ] Read GitHub issue: `gh issue view <number> --json title,body,labels`
- [ ] **Check for related PRs:** `gh pr list --state open | grep -i "<keyword>"` (avoid duplicate work)
- [ ] **Check other agents' work:** `gh issue list --label "In-Progress"` (coordinate with other agents)
- [ ] Label issue with agent ID: `gh issue edit <number> --add-label "In-Progress: Agent #$AGENT_ID"`
- [ ] Create branch: `git checkout -b rpo_<description>_<issue_number>`
- [ ] Back up database if schema changes are expected

## Implementation Checklist

- [ ] Pull latest: `git pull origin main`
- [ ] **UI/UX Changes:** Capture BEFORE screenshots: `node scripts/capture-screenshots.mjs before`
- [ ] Follow DRY and SOLID principles
- [ ] Account for N-tier changes (DB -> API -> Frontend)
- [ ] **PRESERVE DATA** -- No data loss acceptable
- [ ] Create/update tests (unit + E2E)
- [ ] **Consider feature flags** -- See [FEATURE_FLAGS.md](docs/FEATURE_FLAGS.md)
- [ ] **Add comprehensive logging** -- See [LOGGING_GUIDE.md](docs/LOGGING_GUIDE.md)
- [ ] Run linting: `npm run lint`
- [ ] **Run security review** -- See [SECURITY.md](docs/SECURITY.md)

## Testing Checklist (Docker Only!)

- [ ] Check Docker status: `docker ps`
- [ ] Rebuild with --no-cache: `./scripts/rebuild-docker.sh`
- [ ] **Verify data preservation:** Check database integrity
- [ ] Run critical tests: `./scripts/run-all-tests.sh`
- [ ] Test React components (if modified)
- [ ] **UI/UX Changes:** Capture AFTER screenshots: `node scripts/capture-screenshots.mjs after`
  - Compare before/after screenshots for visual verification
  - Ensure no unintended UI regressions
  - Document visual changes in PR description

## Documentation and PR Checklist

- [ ] Update docs (CLAUDE.md, README.md, docs/*)
- [ ] **UI/UX Changes:** Add before/after screenshots to PR description
- [ ] Create PR: `gh pr create`
- [ ] Resolve medium+ issues from code review

## Deployment Checklist

- [ ] Merge to main (resolve conflicts first)
- [ ] Close GitHub issue: `gh issue close <number> --comment "..."`
  - Do NOT remove the "In-Progress: Agent #X" label -- keep it for tracking
- [ ] Delete feature branch: `git push origin --delete <branch>`
- [ ] Rebuild from main: `./scripts/rebuild-docker.sh`
- [ ] Run basic tests: `./scripts/verify-deployment.sh local`
- [ ] **STOP** -- Do not auto-deploy to production

## Critical Rules

### Feature Flags

**ALWAYS ask:** "Should this feature be controlled by a feature flag?"

- Yes: Experimental features, gradual rollouts, A/B testing
- Yes: Breaking changes, UI redesigns, role-based features
- No: Bug fixes, internal refactoring, trivial changes

**See:** [FEATURE_FLAGS.md](docs/FEATURE_FLAGS.md) for complete guide

### Logging

**MANDATORY:** Add comprehensive logging to ALL new code.

- DEBUG: Entry, steps, operations
- INFO: Successful completions
- WARNING: Validation failures
- ERROR: Exceptions (with `exc_info=True`)

**See:** [LOGGING_GUIDE.md](docs/LOGGING_GUIDE.md) for complete guide

### Database Migrations

**ALL migrations MUST be idempotent** (safe to run multiple times).

```sql
-- GOOD
CREATE TABLE IF NOT EXISTS table_name (...);
CREATE INDEX IF NOT EXISTS idx_name ON table(column);

-- BAD
CREATE TABLE table_name (...);  -- Fails if exists
```

**See:** [DATABASE.md](docs/DATABASE.md) for migration patterns

### Security (OWASP Top 10)

**ALWAYS follow OWASP security best practices:**

- Sanitize all inputs: `sanitize_html(user_input)`
- Validate IDs: `validate_positive_id(id, "Entity")`
- Use parameterized queries (ORM only)
- Check authorization before actions
- NEVER log passwords, tokens, API keys

**See:** [SECURITY.md](docs/SECURITY.md) for complete checklist

### Testing in Docker

**CRITICAL:** Always test in Docker containers, NOT local dev servers.

- DON'T: Test with `npm run dev` or `python api/main.py`
- DO: Test with `docker-compose up` (production-like)

**See:** [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for test procedures

### Visual Verification (UI/UX Changes)

**MANDATORY for ALL UI/UX changes:** Capture before/after screenshots for visual regression testing and PR documentation.

**Workflow:**
```bash
# 1. BEFORE implementing changes
node scripts/capture-screenshots.mjs before

# 2. Implement your UI/UX changes

# 3. Rebuild Docker with new changes
docker-compose build --no-cache frontend
docker-compose up -d frontend

# 4. AFTER implementation complete
node scripts/capture-screenshots.mjs after

# 5. Compare screenshots
diff screenshots/before/ screenshots/after/
```

**When to use:**
- Dashboard changes, new components, layout modifications
- Styling updates, responsive design changes
- Any user-visible UI changes
- NOT needed for backend-only or API-only changes

## Documentation References

### Core Guides
- **[WORKFLOW.md](docs/WORKFLOW.md)** -- Complete 27-step implementation process
- **[DEVELOPMENT.md](docs/DEVELOPMENT.md)** -- Development commands, workflow, debugging
- **[TESTING_GUIDE.md](docs/TESTING_GUIDE.md)** -- Docker testing, E2E tests, test procedures

### Feature Implementation
- **[FEATURE_FLAGS.md](docs/FEATURE_FLAGS.md)** -- Feature flag decision framework, patterns
- **[LOGGING_GUIDE.md](docs/LOGGING_GUIDE.md)** -- Logging requirements, patterns, levels
- **[SECURITY.md](docs/SECURITY.md)** -- OWASP guidelines, security checklist

### System Reference
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** -- System architecture, N-tier layers, services
- **[DATABASE.md](docs/DATABASE.md)** -- Database schema, migrations, best practices
- **[AUTH.md](docs/AUTH.md)** -- Authentication, authorization, JWT, roles (if created)
- **[ENVIRONMENT.md](docs/ENVIRONMENT.md)** -- Environment variables configuration

## Hotfix Workflow

**CRITICAL:** Always branch from production tag, NOT from `main`.

```bash
# 1. Identify production version
git tag -l "prod-*" | sort -V | tail -1

# 2. Create hotfix branch from production tag
git checkout prod-v1
git checkout -b hotfix_<description>_<issue_number>

# 3. Implement minimal fix (test in Docker)

# 4. Merge to main and tag new version
git checkout main && git pull origin main
git tag -a prod-v2 -m "Hotfix v2 - <description>"
git push origin prod-v2

# 5. Deploy to production (see DP.md)

# 6. Verify and close issue
```

## Quick Commands Reference

### Feature Development
```bash
# Start feature (creates branch)
./scripts/start-feature.sh 123 "add vendor filters"

# Full rebuild and test
./scripts/rebuild-docker.sh && ./scripts/run-all-tests.sh

# Pre-commit validation
./scripts/pre-commit-checks.sh
```

### Testing
```bash
# Run all tests
./scripts/run-all-tests.sh

# Run specific tests
npm test                                   # Frontend
docker exec PROJECT_NAME-api pytest        # Backend
npm run test:e2e                           # E2E

# Verify deployment
./scripts/verify-deployment.sh local
```

### Database
```bash
# Run migrations
cd api && python -m alembic upgrade head

# Check data counts
docker exec PROJECT_NAME-api psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM users;"
```

### Docker
```bash
# Rebuild all (--no-cache)
./scripts/rebuild-docker.sh

# View logs
docker logs PROJECT_NAME-api -f

# Check health
curl http://localhost:8000/healthz
```

## Pre-Commit Validation

**Automatic (via git hooks):**
```bash
# Enabled once with: git config core.hooksPath .githooks
# Runs automatically on every git commit
.githooks/pre-commit
```

Checks:
- Duplicate migration detection (blocks commit if found)
- TODO/FIXME/XXX/HACK comment detection (blocks commit if found)

**Manual validation:**
```bash
./scripts/pre-commit-checks.sh
```

## Common Pitfalls

1. **Git Hooks:** Forget to enable pre-commit hooks (run once: `git config core.hooksPath .githooks`)
2. **Migrations:** Always use migrations, never manual SQL
3. **Duplicate Migrations:** Check for duplicates before creating new migrations
4. **Idempotency:** Use `IF NOT EXISTS` in SQL migrations
5. **Data Loss:** Never drop tables or columns with data
6. **Sessions:** Always use `with get_db_session() as db:` pattern
7. **Docker Testing:** Always rebuild with `--no-cache` before testing
8. **Feature Flags:** Consider for ALL new user-facing features
9. **Logging:** Add to ALL new code
10. **Security:** Run security review before EVERY PR
11. **Visual Verification:** ALWAYS capture before/after screenshots for UI/UX changes
12. **API Keys:** NEVER use production keys in development -- always use test keys
