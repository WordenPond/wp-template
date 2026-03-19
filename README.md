# wp-template

WordenPond project scaffold — FastAPI + React + PostgreSQL + Fly.io

## Overview

This template provides a pre-configured foundation for WordenPond SaaS projects. It includes all the implementation rules, deployment procedures, documentation structure, and GitHub Actions workflows used across WordenPond projects.

**Stack:** React 18 + TypeScript + Vite + TailwindCSS | FastAPI + SQLAlchemy | PostgreSQL | Docker + Fly.io + Alembic

## Getting Started

### 1. Use This Template

Click **"Use this template"** on GitHub, or clone and reinitialize:

```bash
git clone https://github.com/WordenPond/wp-template.git PROJECT_NAME
cd PROJECT_NAME
git remote set-url origin https://github.com/WordenPond/PROJECT_NAME.git
```

### 2. Run Setup Script

Replace all `PROJECT_NAME` placeholders throughout the codebase:

```bash
chmod +x setup.sh
./setup.sh my-project-name
```

This replaces `PROJECT_NAME` in all `.md`, `.sh`, `.yml`, and `.txt` files.

### 3. Add GitHub Secrets

In your new repo's **Settings → Secrets and variables → Actions**, add:

| Secret | Description |
|--------|-------------|
| `ANTHROPIC_API_KEY` | Claude API key for agent workflows |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token for notifications |
| `TELEGRAM_CHAT_ID` | Telegram chat ID for notifications |
| `GH_PAT` | GitHub Personal Access Token (repo + workflow scopes) |

### 4. Add Queue Workflow Files

The queue processor and Telegram receiver are thin wrappers around [WordenPond/claude-queue](https://github.com/WordenPond/claude-queue). The workflow files are already included in `.github/workflows/`.

To populate your issue queue, add issue numbers to `QUEUE.md`.

### 5. Enable Git Hooks

```bash
git config core.hooksPath .githooks
```

## What's Included

| File / Directory | Purpose |
|-----------------|---------|
| `IR.md` | Implementation rules — 27-step workflow checklist |
| `DP.md` | Deployment procedures — staging and production |
| `CLAUDE.md` | Agent instructions for Claude Code |
| `QUEUE.md` | Agent issue queue (PO-managed priority list) |
| `setup.sh` | Placeholder replacement script |
| `docs/` | Architecture, database, testing, security, and more |
| `scripts/claude-queue-hooks.sh` | Project-specific Telegram command hooks |
| `.github/workflows/` | Queue processor, issue implementer, Telegram receiver |
| `.github/prompts/implement.txt` | Agent implementation prompt |

## Documentation

- **[IR.md](IR.md)** — Implementation rules and checklists
- **[DP.md](DP.md)** — Deployment procedures
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — System architecture
- **[docs/DATABASE.md](docs/DATABASE.md)** — Database schema and migrations
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** — Development setup and workflow
- **[docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md)** — Testing procedures
- **[docs/ENVIRONMENT.md](docs/ENVIRONMENT.md)** — Environment variables
- **[docs/FEATURE_FLAGS.md](docs/FEATURE_FLAGS.md)** — Feature flag patterns
- **[docs/SECURITY.md](docs/SECURITY.md)** — Security guidelines
- **[docs/LOGGING_GUIDE.md](docs/LOGGING_GUIDE.md)** — Logging standards
- **[docs/WORKFLOW.md](docs/WORKFLOW.md)** — Complete 27-step implementation process
