# wp-template

WordenPond project scaffold — FastAPI + React + PostgreSQL + Fly.io

## Overview

This template provides a pre-configured foundation for WordenPond SaaS projects. It includes all the implementation rules, deployment procedures, documentation structure, and GitHub Actions workflows used across WordenPond projects.

**Stack:** React 18 + TypeScript + Vite + TailwindCSS | FastAPI + SQLAlchemy | PostgreSQL | Docker + Fly.io + Alembic

---

## Setting Up a New Project

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
| `TELEGRAM_BOT_TOKEN` | Telegram bot token from [@BotFather](https://t.me/BotFather) |
| `TELEGRAM_CHAT_ID` | Your Telegram chat ID (see below) |
| `GH_PAT` | GitHub Personal Access Token (`repo` + `actions:write` scopes) |
| `FLY_API_TOKEN` | Fly.io API token (required for `deploy` / `staging` commands) |

**Getting your Telegram chat ID:** Message your bot, then visit:
```
https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
```
Look for `"chat": {"id": <YOUR_CHAT_ID>}`.

### 4. Customize Project-Specific Files

- **`CLAUDE.md`** — Fill in project-specific sections (features, routes, key files)
- **`scripts/claude-queue-hooks.sh`** — Update Fly.io app names for deploy/staging/health commands:
  ```bash
  # Replace PROJECT_NAME with your actual app name, e.g. tikketq
  deploy_production() {
    cd api && flyctl deploy --remote-only -a tikketq-api
    flyctl deploy --remote-only -a tikketq
  }
  ```

### 5. Enable Git Hooks

```bash
git config core.hooksPath .githooks
```

### 6. Create Your Telegram Bot (if new project)

1. Message [@BotFather](https://t.me/BotFather) on Telegram → `/newbot`
2. Copy the bot token → add as `TELEGRAM_BOT_TOKEN` secret
3. Start a chat with your new bot, send any message
4. Get your chat ID from the `getUpdates` URL above → add as `TELEGRAM_CHAT_ID`

### 7. Add Issues to the Queue

Edit `QUEUE.md` and add GitHub issue numbers, or send via Telegram:
```
queue 42 43 44
```

The Telegram receiver polls every minute and dispatches commands automatically.

---

## Telegram Commands

Once set up, control your project from Telegram:

| Command | Description |
|---------|-------------|
| `queue 42 43 44` | Add issues to the implementation queue |
| `queue` | Trigger the queue runner immediately |
| `merge 42` | Merge PR #42 and advance the queue |
| `rev 42` | Re-review and fix PR #42 |
| `implement 42` | Implement a single issue outside the queue |
| `status` | Show queue status (pending / done / next) |
| `pause` | Pause the queue |
| `resume` | Resume the queue |
| `deploy` | Deploy to production (uses `claude-queue-hooks.sh`) |
| `staging` | Deploy to staging |
| `health` | Run production health check |
| `staging-health` | Run staging health check |
| `help` | Show all commands |

Commands powered by [WordenPond/claude-queue](https://github.com/WordenPond/claude-queue).

---

## What's Included

| File / Directory | Purpose |
|-----------------|---------|
| `IR.md` | Implementation rules — 27-step workflow checklist |
| `DP.md` | Deployment procedures — staging and production |
| `CLAUDE.md` | Agent instructions for Claude Code |
| `QUEUE.md` | Agent issue queue (PO-managed priority list) |
| `setup.sh` | Placeholder replacement script |
| `docs/` | Architecture, database, testing, security, and more |
| `scripts/claude-queue-hooks.sh` | Project-specific Telegram command hooks (deploy, health) |
| `.github/workflows/` | Queue processor, issue implementer, Telegram receiver |
| `.github/prompts/implement.txt` | Agent implementation prompt |

---

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

---

## Related Repos

- **[WordenPond/claude-queue](https://github.com/WordenPond/claude-queue)** — Shared queue processor and Telegram receiver workflows
