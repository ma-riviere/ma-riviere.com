#!/usr/bin/env bash
# Push the already-rendered _site/ to the gh-pages branch.
# quarto does the work in a temporary git worktree (.quarto/quarto-publish-worktree-*),
# so the current branch, index, and uncommitted changes are never touched.
set -euo pipefail
cd "$(dirname "$0")"

[[ -f _site/index.html ]] || {
    echo "No rendered site found in _site/. Run 'quarto render' first." >&2
    exit 1
}

quarto publish gh-pages --no-render --no-prompt --no-browser
