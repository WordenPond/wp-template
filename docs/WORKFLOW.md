# Implementation Workflow

Complete 27-step process for implementing features. See [IR.md](../IR.md) for the quick reference checklist.

## Phase 1: Preparation (Steps 1-6)

### Step 1: Read the Issue
```bash
gh issue view <number> --json title,body,labels,comments
```
Understand the full scope before writing any code.

### Step 2: Check for Duplicate Work
```bash
gh pr list --state open | grep -i "<keyword>"
gh issue list --label "In-Progress"
```
Avoid implementing something another agent is already working on.

### Step 3: Enable Git Hooks (First Time Only)
```bash
git config core.hooksPath .githooks
```

### Step 4: Pull Latest Main
```bash
git checkout main && git pull origin main
```

### Step 5: Create Feature Branch
```bash
git checkout -b rpo_<short-description>_<issue_number>
```

### Step 6: Label the Issue
```bash
gh issue edit <number> --add-label "In-Progress"
```

---

## Phase 2: Design (Steps 7-9)

### Step 7: Identify Affected N-Tier Layers
Determine which layers need changes:
- Database schema (new table, column, index)
- API (new endpoint, updated response model)
- Frontend (new component, updated page)

### Step 8: Check for Feature Flag Need
Ask: "Should this be behind a feature flag?"
- New user-facing features: Yes
- Bug fixes and refactoring: No

### Step 9: Plan Tests
Before coding, identify:
- What unit tests are needed?
- What integration tests are needed?
- What E2E test scenarios cover this?

---

## Phase 3: Database (Steps 10-11)

### Step 10: Create Database Migration (if needed)
```bash
# Add/modify model in api/db_models.py first, then:
cd api && python -m alembic revision --autogenerate -m "Add <column/table>"

# Review the generated migration
cat api/alembic/versions/<new_revision>.py
```

### Step 11: Test Migration
```bash
cd api && python -m alembic upgrade head
cd api && python -m alembic downgrade -1
cd api && python -m alembic upgrade head
```

---

## Phase 4: Backend (Steps 12-14)

### Step 12: Implement Pydantic Models
Add request/response models to `api/models.py`.

### Step 13: Implement Database Methods
Add CRUD methods to `api/sqlalchemy_database.py`.

### Step 14: Implement API Endpoints
Add endpoints to `api/main.py` with:
- Authentication check
- Authorization check
- Input validation/sanitization
- Comprehensive logging (DEBUG/INFO/WARNING/ERROR)
- Proper error handling

---

## Phase 5: Frontend (Steps 15-17)

### Step 15: Capture BEFORE Screenshots (UI/UX changes)
```bash
node scripts/capture-screenshots.mjs before
```

### Step 16: Update TypeScript Types
Add/update interfaces in `src/types/index.ts`.

### Step 17: Update API Client and Components
- Add API methods to `src/services/api.ts`
- Create or update React components
- Update routing in `src/App.tsx` if needed

---

## Phase 6: Testing (Steps 18-21)

### Step 18: Write Unit Tests
- Backend: `api/tests/unit/`
- Frontend: `src/**/*.test.ts`

### Step 19: Write Integration Tests
- Backend: `api/tests/integration/`

### Step 20: Write E2E Tests
- `tests/e2e/*.spec.ts`

### Step 21: Run All Tests in Docker
```bash
docker-compose build --no-cache
docker-compose up -d
./scripts/run-all-tests.sh
```

---

## Phase 7: Quality (Steps 22-24)

### Step 22: Run Linting
```bash
npm run lint  # Fix all errors before proceeding
```

### Step 23: Run Security Review
Check against [SECURITY.md](SECURITY.md) checklist.

### Step 24: Capture AFTER Screenshots (UI/UX changes)
```bash
docker-compose build --no-cache frontend
docker-compose up -d frontend
node scripts/capture-screenshots.mjs after
diff screenshots/before/ screenshots/after/
```

---

## Phase 8: PR and Review (Steps 25-27)

### Step 25: Update Documentation
Update relevant docs:
- `CLAUDE.md` if new patterns were introduced
- `docs/` files for any architectural changes
- API documentation if new endpoints were added

### Step 26: Create Pull Request
```bash
gh pr create \
  --title "feat: <description> (#<issue_number>)" \
  --body "$(cat << 'EOF'
## Summary
<Brief description of what was implemented>

## Changes
- List of specific changes
- Files modified

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Tested in Docker

## Screenshots (if UI changes)
<Before/after screenshots>

Closes #<issue_number>
EOF
)"
```

### Step 27: Post-Merge Cleanup
```bash
# Close issue
gh issue close <number> --comment "Implemented in PR #<pr_number>"

# Delete feature branch
git push origin --delete rpo_<description>_<issue_number>
git branch -d rpo_<description>_<issue_number>

# Rebuild from main
git checkout main && git pull origin main
./scripts/rebuild-docker.sh
./scripts/verify-deployment.sh local
```

---

## Quick Reference

See [IR.md](../IR.md) for the condensed checklist version of this workflow.
