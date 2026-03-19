# Architecture

## Overview

PROJECT_NAME is a SaaS platform built on a modern, scalable stack. The architecture follows an N-tier pattern with clear separation of concerns between the presentation layer, API layer, service layer, and data layer.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18, TypeScript, Vite, TailwindCSS |
| Backend API | FastAPI (Python 3.11) |
| ORM | SQLAlchemy 2.x |
| Database | PostgreSQL 15 |
| Migrations | Alembic |
| Caching | Redis 7 |
| Container | Docker, Docker Compose |
| Hosting | Fly.io |
| CI/CD | GitHub Actions |

## System Architecture

```
Browser / Mobile Client
        |
        v
[Fly.io CDN / nginx]
        |
        v
[React Frontend]  <---> [FastAPI Backend] <---> [PostgreSQL]
                                |
                                v
                            [Redis Cache]
```

## N-Tier Layer Descriptions

### Presentation Layer (React Frontend)
- Single-page application built with React 18 and TypeScript
- Component-based UI with TailwindCSS styling
- Axios HTTP client for API communication
- React Router for client-side navigation
- Route guards for authentication/authorization

### API Layer (FastAPI)
- RESTful API endpoints in `api/main.py`
- JWT-based authentication
- Pydantic v2 models for request/response validation
- CORS middleware configured for production domains
- OpenAPI docs at `/docs`

### Service Layer
- Business logic separated into service modules
- Auth service, email service, feature flag service, cache service
- Stripe integration for payments

### Data Layer
- PostgreSQL 15 with SQLAlchemy ORM
- Alembic for schema migrations
- `get_db_session()` context manager for connection pooling
- Redis for caching frequently accessed data

## Key Files

| File | Purpose |
|------|---------|
| `api/main.py` | All API endpoints |
| `api/sqlalchemy_database.py` | All database CRUD methods |
| `api/db_models.py` | SQLAlchemy ORM models |
| `api/models.py` | Pydantic request/response models |
| `api/database_config.py` | Database connection factory |
| `api/auth_service.py` | JWT authentication logic |
| `src/App.tsx` | Frontend route definitions |
| `src/services/api.ts` | Axios API client |
| `src/types/index.ts` | TypeScript interfaces |

## Scalability Considerations

- **Horizontal scaling:** Fly.io machines can be scaled out with `flyctl scale count`
- **Database connections:** Use connection pooling (SQLAlchemy pool settings in `database_config.py`)
- **Caching:** Redis cache-aside pattern reduces database load for frequent reads
- **Static assets:** Served via nginx with aggressive caching headers
- **CDN:** Fly.io edge network provides geographic distribution
