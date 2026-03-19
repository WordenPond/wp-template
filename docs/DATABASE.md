# Database

## Overview

PROJECT_NAME uses PostgreSQL 15 as its primary database, managed via SQLAlchemy ORM and Alembic migrations. All schema changes must go through Alembic migrations -- never apply SQL directly.

## Tech

- **Database:** PostgreSQL 15
- **ORM:** SQLAlchemy 2.x
- **Migrations:** Alembic
- **Timestamps:** All timestamps are `TIMESTAMP(timezone=True)` (UTC stored, timezone-aware)

## Schema Overview

_Update this section as your schema grows._

| Table | Description |
|-------|-------------|
| `users` | Application users (all roles) |
| _(add tables here)_ | |

## Migration Guide

### Common Commands

```bash
# Apply all pending migrations
cd api && python -m alembic upgrade head

# Generate new migration from model changes
cd api && python -m alembic revision --autogenerate -m "Description of changes"

# Create empty migration (for data migrations)
cd api && python -m alembic revision -m "Description of changes"

# Rollback one migration
cd api && python -m alembic downgrade -1

# Show current version
cd api && python -m alembic current

# Show migration history
cd api && python -m alembic history

# Show pending migrations
cd api && python -m alembic heads
```

### Creating a New Migration

1. Make changes to `api/db_models.py`
2. Generate migration: `cd api && python -m alembic revision --autogenerate -m "Add column X to table Y"`
3. Review the generated file in `api/alembic/versions/`
4. Test locally: `cd api && python -m alembic upgrade head`
5. Test rollback: `cd api && python -m alembic downgrade -1 && python -m alembic upgrade head`
6. Commit both the model change and migration together

## Best Practices

### Idempotency
Migrations must be safe to run multiple times:
```sql
-- GOOD
CREATE TABLE IF NOT EXISTS table_name (...);
CREATE INDEX IF NOT EXISTS idx_name ON table(column);

-- BAD
CREATE TABLE table_name (...);  -- Fails if already exists
```

### No Data Loss
- NEVER drop tables or columns that contain data
- Use `op.add_column()` to add new columns
- Rename columns by adding the new column, migrating data, then dropping the old one (in separate PRs)

### Always Include Downgrade
Every migration must have a working `downgrade()` function:
```python
def upgrade() -> None:
    op.add_column('users', sa.Column('new_field', sa.String(), nullable=True))

def downgrade() -> None:
    op.drop_column('users', 'new_field')
```

### Timestamps
Always use timezone-aware timestamps:
```python
from sqlalchemy import Column, DateTime
from sqlalchemy.sql import func

created_at = Column(DateTime(timezone=True), server_default=func.now())
updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

## Session Pattern

```python
from database_config import get_db_session

# Always use the context manager
with get_db_session() as db:
    result = db.query(User).filter(User.id == user_id).first()
    db.add(new_record)
    # Auto-commit on exit, auto-rollback on exception
```

**Never** create sessions manually or use `db.commit()` outside the context manager.

## Performance

- Add indexes for columns used in WHERE clauses and JOINs
- Use `.first()` instead of `.all()` when you only need one record
- Use `db.query(Model.column1, Model.column2)` instead of `db.query(Model)` for large tables when you don't need all columns
- Monitor slow queries in production via `pg_stat_statements`

## References

- [Alembic documentation](https://alembic.sqlalchemy.org/en/latest/)
- [SQLAlchemy documentation](https://docs.sqlalchemy.org/)
- `api/alembic/` -- Migration files and configuration
