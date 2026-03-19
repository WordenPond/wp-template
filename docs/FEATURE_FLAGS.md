# Feature Flags

## Overview

Feature flags allow you to control the availability of features at runtime without deploying new code. They are stored in the database and can be toggled via the admin interface or API.

## When to Use Feature Flags

**Use a feature flag when:**
- Rolling out a new user-facing feature to a subset of users
- Running A/B tests
- Implementing a breaking change that needs gradual rollout
- Adding functionality that stakeholders may want to disable quickly
- Building a feature that depends on a future infrastructure change

**Do NOT use a feature flag for:**
- Bug fixes
- Internal refactoring
- Trivial UI tweaks
- Security patches

## Backend Pattern

```python
from feature_flag_service import get_feature_flag_service

# In an API endpoint
@router.get("/my-endpoint")
async def my_endpoint(db = Depends(get_db)):
    feature_service = get_feature_flag_service(db)

    if feature_service.is_enabled('new_dashboard'):
        return new_dashboard_response()
    else:
        return old_dashboard_response()
```

### Creating a New Flag

1. Add the flag to the database via migration:

```python
# In Alembic migration
def upgrade():
    op.execute("""
        INSERT INTO feature_flags (name, enabled, description)
        VALUES ('new_feature', false, 'Description of the new feature')
        ON CONFLICT (name) DO NOTHING
    """)

def downgrade():
    op.execute("DELETE FROM feature_flags WHERE name = 'new_feature'")
```

2. Use the flag in your code:

```python
if feature_service.is_enabled('new_feature'):
    # New behavior
    pass
```

## Frontend Pattern

```typescript
import { useFeatureFlag } from '@/hooks/useFeatureFlag';

function MyComponent() {
  const { isEnabled, isLoading } = useFeatureFlag('new_feature');

  if (isLoading) {
    return <LoadingSpinner />;
  }

  return isEnabled ? <NewFeature /> : <OldFeature />;
}
```

### Checking a Flag Without a Hook

```typescript
import { featureFlagService } from '@/services/featureFlagService';

const isEnabled = await featureFlagService.isEnabled('new_feature');
```

## Toggling Flags

### Via Admin API

```bash
# Enable a flag
curl -X PATCH https://api.PROJECT_NAME.com/api/admin/feature-flags/new_feature \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'

# Disable a flag
curl -X PATCH https://api.PROJECT_NAME.com/api/admin/feature-flags/new_feature \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```

## Best Practices

1. **Default to off:** New flags should default to `enabled: false` in migrations
2. **Clean up old flags:** Remove flag checks and the database row once a feature is fully launched (after 1-2 sprints)
3. **Name clearly:** Use descriptive names like `vendor_pre_orders` not `feature_v2`
4. **Document the flag:** Always include a description when creating the database row
5. **Cache flags:** The feature flag service should cache values (e.g., 60 seconds) to avoid database hits on every request
