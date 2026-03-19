#!/usr/bin/env bash
# setup.sh — Replace PROJECT_NAME placeholder throughout the codebase
# Usage: ./setup.sh my-project-name

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 PROJECT_NAME"
  echo "Example: $0 my-saas-app"
  exit 1
fi

PROJECT_NAME="$1"

echo "Setting up project: $PROJECT_NAME"
echo "Replacing all PROJECT_NAME placeholders..."

# Replace in all relevant file types
find . \
  -not -path './.git/*' \
  -not -name 'setup.sh' \
  \( -name '*.md' -o -name '*.sh' -o -name '*.yml' -o -name '*.yaml' -o -name '*.txt' -o -name '*.toml' -o -name '*.env*' \) \
  -exec sed -i "s/PROJECT_NAME/${PROJECT_NAME}/g" {} +

echo ""
echo "Done! PROJECT_NAME replaced with '${PROJECT_NAME}' throughout."
echo ""
echo "Next steps:"
echo "  1. Review changed files: git diff"
echo "  2. Add GitHub secrets: ANTHROPIC_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, GH_PAT"
echo "  3. Push to GitHub: git add -A && git commit -m 'chore: initialize ${PROJECT_NAME}' && git push"
echo "  4. Enable git hooks: git config core.hooksPath .githooks"
echo "  5. Add issues to QUEUE.md and trigger the queue workflow"
