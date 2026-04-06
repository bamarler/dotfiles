#!/bin/bash
# uv-init-pinned.sh - Initialize uv project with exact Python version pinning

VERSION="3.13.9"

show_help() {
    cat << EOF
uv-init-pinned - Initialize uv project with exact Python version (==) instead of minimum (>=)

USAGE:
    uvinit [OPTIONS] [UV_INIT_ARGS...]

OPTIONS:
    -p, --python VERSION   Python version to pin (default: $VERSION)
    -h, --help             Show this help message

EXAMPLES:
    uvinit                      # Init in current dir with ==$VERSION
    uvinit -p 3.12.0            # Init in current dir with ==3.12.0
    uvinit myproject            # Create myproject with ==$VERSION
    uvinit -p 3.11.0 myproject  # Create myproject with ==3.11.0
    uvinit --app                # Init as application with ==$VERSION

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help|help)
            show_help
            ;;
        -p|--python)
            VERSION="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Run default uv init with any remaining args
uv init "$@"

# Determine where pyproject.toml is
if [[ -n "$1" ]] && [[ -f "$1/pyproject.toml" ]]; then
    BASEDIR="$1"
else
    BASEDIR="."
fi

# Remove generated main.py
rm -f "$BASEDIR/main.py"

# Edit pyproject.toml: replace >=X.Y.Z with ==VERSION
if [[ -f "$BASEDIR/pyproject.toml" ]]; then
    sed -i "s/requires-python = \">=.*\"/requires-python = \"==$VERSION\"/" "$BASEDIR/pyproject.toml"
fi

# Edit .python-version to exact version
if [[ -f "$BASEDIR/.python-version" ]]; then
    echo "$VERSION" > "$BASEDIR/.python-version"
fi

# Append ruff config to pyproject.toml
cat >> "$BASEDIR/pyproject.toml" << 'EOF'

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",
    "W",
    "F",
    "I",
    "B",
    "C4",
    "UP",
    "ANN",
]
ignore = [
    "E501",
    "B008",
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"
EOF

# Install ruff
cd "$BASEDIR" && uv add ruff

echo "Pinned Python to ==$VERSION"
echo "Added ruff config and installed ruff"
