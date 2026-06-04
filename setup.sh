#!/usr/bin/env bash
# =============================================================
# setup.sh — initialize local git repo and push to GitHub
#
# Prerequisites:
#   GitHub CLI (gh): https://cli.github.com
#   OR export GITHUB_TOKEN=<your_token>
#
# Usage:
#   chmod +x setup.sh && ./setup.sh
# =============================================================

set -euo pipefail

REPO_NAME="ngs-demux-pipeline"
GITHUB_USER="murti-abhishek"
DESCRIPTION="Cloud-native Nextflow DSL2 pipeline for genetic demultiplexing of pooled snRNA-seq using bulk RNA-seq or WGS/WES genotype data"

echo "==> Initializing git repo..."
git init
git add .
git commit -m "chore: initial scaffold — subworkflows and module stubs"

echo ""
echo "==> Creating GitHub repository..."

if command -v gh &> /dev/null; then
    gh repo create "${GITHUB_USER}/${REPO_NAME}" \
        --public \
        --description "${DESCRIPTION}" \
        --source=. \
        --remote=origin \
        --push
    echo "Done! Repo created and pushed via GitHub CLI."

elif [ -n "${GITHUB_TOKEN:-}" ]; then
    curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"${REPO_NAME}\",\"description\":\"${DESCRIPTION}\",\"private\":false}" \
        | python3 -c "import sys,json; r=json.load(sys.stdin); print('Repo URL:', r.get('html_url','ERROR: '+str(r)))"

    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    git branch -M main
    git push -u origin main
    echo "Done! Repo created and pushed via GITHUB_TOKEN."

else
    echo "Neither gh CLI nor GITHUB_TOKEN found."
    echo "Create the repo manually at https://github.com/new then run:"
    echo "  git remote add origin https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    echo "  git branch -M main"
    echo "  git push -u origin main"
fi
