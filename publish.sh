#!/usr/bin/env bash
# Push the already-rendered _site/ to the gh-pages branch.
# quarto does the work in a temporary git worktree (.quarto/quarto-publish-worktree-*),
# so the current branch, index, and uncommitted changes are never touched.
# Once GitHub Pages has deployed the push, purge the Cloudflare edge cache
# (the cache rule holds pages for 7 days, so without a purge the old content lingers).
set -euo pipefail
cd "$(dirname "$0")"

CF_ZONE_ID="d711e9d4f321db4e7a42ff1f941ace44"

[[ -f _site/index.html ]] || {
    echo "No rendered site found in _site/. Run 'quarto render' first." >&2
    exit 1
}

quarto publish gh-pages --no-render --no-prompt --no-browser

[[ -n "${CF_PURGE_TOKEN:-}" ]] || {
    echo "CF_PURGE_TOKEN not set: skipping cache purge (edge stays stale up to 7 days)." >&2
    exit 1
}

# Wait until GitHub Pages has built the commit we just pushed (typically < 1 min),
# else the purged edge would re-cache the previous deploy.
pushed_sha=$(git ls-remote origin gh-pages | cut -f1)
build=""
for _ in $(seq 30); do
    build=$(gh api 'repos/{owner}/{repo}/pages/builds/latest' --jq '[.commit, .status] | @tsv' 2>/dev/null) || build=""
    [[ "$build" == "$pushed_sha"$'\t'"built" ]] && break
    sleep 10
done
[[ "$build" == "$pushed_sha"$'\t'"built" ]] || echo "GitHub Pages build not confirmed after 5 min; purging anyway." >&2
sleep 10 # small grace period for GitHub's CDN to serve the new deploy

curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
    -H "Authorization: Bearer ${CF_PURGE_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"purge_everything":true}' \
    | jq -e '.success' > /dev/null || {
        echo "Cloudflare cache purge FAILED." >&2
        exit 1
    }
echo "Cloudflare edge cache purged."
