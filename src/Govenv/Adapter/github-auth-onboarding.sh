#!/usr/bin/env bash
set -euo pipefail

if gh auth token --hostname github.com >/dev/null 2>&1; then
  exit 0
fi

cat <<'EOF'
Govenv: GitHub CLI authentication is not configured.

Choose one authentication flow:

1. Fine-grained PAT (least privilege for agent collaboration)
   Open:
   https://github.com/settings/personal-access-tokens/new?name=Govenv%20collaboration&description=Repository%20collaboration%20from%20Govenv&contents=read&issues=write&pull_requests=write

   Select only the repositories Govenv should collaborate with.
   Prefilled repository permissions:
     Contents: Read-only
     Issues: Read and write
     Pull requests: Read and write
   Then expose the token to GitHub CLI as GH_TOKEN from your user environment
   or secret manager. Do not store it in the repository.

2. GitHub CLI interactive OAuth login
   gh auth login --git-protocol ssh --skip-ssh-key
EOF
