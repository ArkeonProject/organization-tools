#!/bin/bash
set -e

TOOLS_DIR=$(pwd)

echo "Installing CI/CD into current repository..."

mkdir -p .github/workflows

IS_NODE=false
IS_PYTHON=false
HAS_DOCKER=false

[ -f "package.json" ] && IS_NODE=true
[ -f "pyproject.toml" ] || [ -f "requirements.txt" ] && IS_PYTHON=true
[ -f "Dockerfile" ] && HAS_DOCKER=true

cp "$TOOLS_DIR/ci-templates/ci-universal-develop.yml" .github/workflows/ci.yml

if [ "$IS_NODE" = true ]; then
  cp "$TOOLS_DIR/ci-templates/cd-node-vercel-main.yml" .github/workflows/cd.yml
fi

if [ "$IS_PYTHON" = true ] || [ "$HAS_DOCKER" = true ]; then
  cp "$TOOLS_DIR/ci-templates/cd-python-docker-main.yml" .github/workflows/cd.yml
fi

echo "CI/CD installed successfully."
