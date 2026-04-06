#!/usr/bin/env bash
# ~/scripts/init-claude-project.sh

PROJECT_NAME="${1:-}"

if [ -z "$PROJECT_NAME" ]; then
    read -p "Project name: " PROJECT_NAME
fi

# Project type
echo "Project type:"
echo "1) Frontend only"
echo "2) Backend only" 
echo "3) Fullstack"
read -p "Select (1-3): " PROJECT_TYPE

# Frontend config
if [[ "$PROJECT_TYPE" =~ ^[13]$ ]]; then
    read -p "Frontend runtime (bun/node): " FE_RUNTIME
    read -p "Frontend framework (react/next/vue/etc): " FE_FRAMEWORK
fi

# Backend config
if [[ "$PROJECT_TYPE" =~ ^[23]$ ]]; then
    read -p "Backend runtime (bun/node/python/go): " BE_RUNTIME
    read -p "Backend framework (express/fastapi/gin/etc): " BE_FRAMEWORK
    read -p "Database (postgres/mongo/mysql/none): " DATABASE
fi

# Docker
read -p "Dockerized? (y/n): " DOCKERIZED

# Generate patterns based on stack
PATTERNS=""

if [[ "$BE_RUNTIME" == "python" ]]; then
    PATTERNS+="
### Python-specific
- Typing: Pydantic models for all schemas
- Linting: Ruff (see pyproject.toml reference)
- Pattern: route → service → repository
  - Routes: validation only
  - Services: business logic, error handling
  - Repositories: DB operations only
- Config: Central settings.py for all env vars
- Testing: Unit tests required"
fi

if [[ "$FE_RUNTIME" =~ ^(bun|node)$ ]]; then
    PATTERNS+="
### TypeScript/JS
- Typing: Zod schemas for validation
- Linting: ESLint + Prettier
- State: TanStack Query for server state
- Routing: React Router
- Styling: Maintain central theme file
- Naming: \`*.hooks.ts\`, \`*.service.ts\`"
fi

# Write CLAUDE.md
cat > CLAUDE.md << EOF
# Project: $PROJECT_NAME

## Tech Stack
$([ -n "$FE_FRAMEWORK" ] && echo "**Frontend:** $FE_RUNTIME + $FE_FRAMEWORK")
$([ -n "$BE_FRAMEWORK" ] && echo "**Backend:** $BE_RUNTIME + $BE_FRAMEWORK")
$([ -n "$DATABASE" ] && echo "**Database:** $DATABASE")
$([ "$DOCKERIZED" == "y" ] && echo "**Containerized:** Docker Compose")

## Documentation Strategy
**CRITICAL: Always use context7 before implementing with external libraries.**

Process:
1. Use context7 to fetch latest docs
2. Verify API matches current version
3. Never trust training data for specifics

## Project Patterns
$PATTERNS

### General Standards
- **Naming:** Descriptive, extension-based (\`.hooks.ts\`, \`.service.py\`)
- **Typing:** Strong typing everywhere (function params, returns, variables)
- **Linting:** Strict (add configs to .vscode/extensions.json)

## Auto-Approved Commands
- \`git status/diff/log/add/commit\`
- Package installs (\`bun install\`, \`pip install\`, etc)
- Dev server commands
- **NOT APPROVED:** \`git push\`, production deploys, DB migrations

## Context Management
- \`/clear\` when switching features
- \`/compact\` during complex debugging

## Deployment
- **Frontend:** [TODO: specify]
- **Backend:** [TODO: specify]
EOF

echo "✓ CLAUDE.md created for $PROJECT_NAME"
echo "Next: Customize deployment section, then ask Claude to initialize project structure"
