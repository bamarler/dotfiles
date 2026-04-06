#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

_require_git() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        printf "${RED}✗ Not inside a git repo${NC}\n"; exit 1
    }
}

_require_claude() {
    command -v claude &>/dev/null || {
        printf "${RED}✗ claude not found${NC}\n"; exit 1
    }
}

init_graph() {
    command -v cgc &>/dev/null || {
        printf "${RED}✗ cgc not found. Run:${NC}\n"
        printf "  uv tool install codegraphcontext\n"
        printf "  curl -sSL https://raw.githubusercontent.com/CodeGraphContext/CodeGraphContext/main/scripts/post_install_fix.sh | bash\n"
        return 1
    }

    printf "${YELLOW}Setting up CodeGraphContext...${NC}\n"
    claude mcp add --scope project codegraphcontext -- cgc mcp start 2>/dev/null || true

    if [[ ! -f .cgcignore ]]; then
        cat > .cgcignore << 'IGNORE'
node_modules/
.git/
dist/
build/
__pycache__/
*.pyc
.venv/
venv/
.indexes/
IGNORE
        printf "${GREEN}✓ Created .cgcignore${NC}\n"
    fi

    cgc index . 2>/dev/null || cgc analyze . 2>/dev/null || \
        printf "${YELLOW}⚠ Auto-index skipped — cgc will index on first query${NC}\n"

    printf "${GREEN}✓ CodeGraphContext ready${NC}\n"
}

init_light() {
    command -v mcp-codebase-index &>/dev/null || {
        printf "${RED}✗ mcp-codebase-index not found. Run:${NC}\n"
        printf "  uv tool install 'mcp-codebase-index[mcp]'\n"
        return 1
    }

    printf "${YELLOW}Setting up mcp-codebase-index...${NC}\n"
    claude mcp add --scope project codebase-index \
        -e PROJECT_ROOT="$(pwd)" \
        -- mcp-codebase-index 2>/dev/null || true

    printf "${GREEN}✓ mcp-codebase-index ready (auto-syncs with git)${NC}\n"
}

inject_claude_md() {
    local marker="## Codebase Navigation"
    [[ -f CLAUDE.md ]] || return 0
    grep -q "$marker" CLAUDE.md 2>/dev/null && return 0

    cat >> CLAUDE.md << 'BLOCK'

## Codebase Navigation

Use MCP codebase tools FIRST when exploring the repo or understanding how files relate.
Fall back to reading files directly only when MCP tools don't have what you need.
For config files (YAML, .env, Caddyfile), read directly — MCP tools are best for code.
BLOCK
    printf "${GREEN}✓ Added navigation block to CLAUDE.md${NC}\n"
}

cmd_init() {
    _require_git
    _require_claude

    local mode="" skip_md=false

    for arg in "$@"; do
        case "$arg" in
            --light)        mode="light" ;;
            --graph)        mode="graph" ;;
            --no-claude-md) skip_md=true ;;
            *) printf "${RED}Unknown option: %s${NC}\n" "$arg"; exit 1 ;;
        esac
    done

    [[ -z "$mode" ]] && { printf "${RED}✗ Specify --light or --graph${NC}\n"; cmd_help; exit 1; }

    printf "${CYAN}Setting up in: %s${NC}\n\n" "$(basename "$(pwd)")"

    case "$mode" in
        light) init_light ;;
        graph) init_graph ;;
    esac

    $skip_md || inject_claude_md
    printf "\n${GREEN}✓ Done! Start Claude Code and the tools will be available.${NC}\n"
}

cmd_help() {
    cat << EOF
Usage: cidx-init <--light|--graph> [--no-claude-md]

  --light   mcp-codebase-index (structural, zero deps, auto git-sync)
  --graph   CodeGraphContext (graph DB, relationship mapping, 14 langs)

Prerequisites:
  uv tool install 'mcp-codebase-index[mcp]'   # for --light (note: [mcp] extra required)
  uv tool install codegraphcontext             # for --graph
  curl -sSL https://raw.githubusercontent.com/CodeGraphContext/CodeGraphContext/main/scripts/post_install_fix.sh | bash
EOF
}

case "${1:-help}" in
    init)  shift; cmd_init "$@" ;;
    help|-h|--help) cmd_help ;;
    *)     cmd_init "$@" ;;
esac
