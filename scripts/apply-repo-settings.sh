#!/usr/bin/env bash
# Apply the standard repository settings to a repo created from this template.
# GitHub copies files and branches from a template, not settings or rulesets,
# so run this once after `gh repo create --template sredhu37/repo-template`.
#
# Usage: scripts/apply-repo-settings.sh [owner/repo]   (default: the current repo)
# Needs: gh, logged in with admin rights on the target repo.
set -euo pipefail

TEMPLATE="sredhu37/repo-template"
REPO="${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
echo "Applying settings to $REPO"

# Merge buttons, branch updates, auto-merge, branch cleanup, PR creation policy.
gh api -X PATCH "repos/$REPO" --silent \
  -F allow_merge_commit=true \
  -f merge_commit_title=PR_TITLE \
  -f merge_commit_message=PR_BODY \
  -F allow_squash_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY \
  -F allow_rebase_merge=true \
  -F allow_update_branch=true \
  -F allow_auto_merge=true \
  -F delete_branch_on_merge=true \
  -F has_issues=true \
  -F has_wiki=true \
  -f pull_request_creation_policy=collaborators_only

# Issue creation by all users (GraphQL only).
REPO_ID="$(gh api "repos/$REPO" --jq .node_id)"
gh api graphql --silent \
  -f query='mutation($id:ID!){updateRepository(input:{repositoryId:$id,issueCreationPolicy:ALL}){repository{id}}}' \
  -f id="$REPO_ID"

# Release immutability.
gh api -X PUT "repos/$REPO/immutable-releases" --silent

# Copy the template's rulesets (for example "Protect main") unless a ruleset
# with the same name already exists. Rulesets need a public repo or GitHub Pro.
if [ "$REPO" != "$TEMPLATE" ]; then
  existing="$(gh api "repos/$REPO/rulesets" --jq '.[].name' 2>/dev/null || true)"
  for id in $(gh api "repos/$TEMPLATE/rulesets" --jq '.[].id'); do
    body="$(gh api "repos/$TEMPLATE/rulesets/$id" \
      --jq '{name, target, enforcement, conditions, rules, bypass_actors}')"
    name="$(jq -r .name <<<"$body")"
    if grep -qxF "$name" <<<"$existing"; then
      echo "Ruleset '$name' already exists, skipped"
    else
      gh api -X POST "repos/$REPO/rulesets" --input - --silent <<<"$body"
      echo "Ruleset '$name' copied"
    fi
  done
fi

cat <<'EOF'
Done. Three settings have no API; set them by hand in Settings > General:
  - Wikis: Restrict editing to collaborators only
  - Commits: Allow comments on individual commits
  - Issues: Auto-close issues with merged linked pull requests
EOF
