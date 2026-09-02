#!/usr/bin/env bash

set -euo pipefail

_add_federated_credential() {
  local name="$1" subject="$2" identity_name="$3" identity_rg="$4"

  local existing_subject
  existing_subject=$(az identity federated-credential show \
    --name "$name" \
    --identity-name $identity_name \
    --resource-group $identity_rg \
    --query subject -o tsv 2>/dev/null || true)

  if [[ "$existing_subject" == "$subject" ]]; then
    echo "federated credential '${name}' already up to date, skipping..."
    return
  fi

  # `federated-credential create` upserts by name, so this also fixes
  # existing credentials whose subject used the old repo:owner/repo format.
  az identity federated-credential create \
    --name "$name" \
    --identity-name $identity_name \
    --resource-group $identity_rg \
    --issuer "https://token.actions.githubusercontent.com" \
    --subject "$subject" \
    --audiences "api://AzureADTokenExchange" \
    --output none

  if [[ -n "$existing_subject" ]]; then
    echo "updated federated credential '${name}' subject from '${existing_subject}' to '${subject}'..."
  else
    echo "added federated credential '${name}' for subject '${subject}'..."
  fi
}

echo "Configuring federated credentials..."

# GitHub now issues OIDC subject claims with immutable owner/repo IDs
# (repo:<owner>@<owner_id>/<repo>@<repo_id>:...) instead of just names, so we
# must look up the numeric IDs and bake them into the federated credential subject.
repo_info=$(gh api "repos/${GITHUB_OWNER_NAME}/${GITHUB_REPO_NAME}" --jq '{owner_id: .owner.id, repo_id: .id}')
GITHUB_OWNER_ID=$(echo "$repo_info" | jq -r '.owner_id')
GITHUB_REPO_ID=$(echo "$repo_info" | jq -r '.repo_id')
REPO_SUBJECT="${GITHUB_OWNER_NAME}@${GITHUB_OWNER_ID}/${GITHUB_REPO_NAME}@${GITHUB_REPO_ID}"

_add_federated_credential "gh-main" "repo:${REPO_SUBJECT}:ref:refs/heads/main" ${GITHUB_ACTIONS_IDENTITY_NAME} ${LAYER_1_AZURE_RESOURCE_GROUP}
_add_federated_credential "gh-pull-request" "repo:${REPO_SUBJECT}:pull_request" ${GITHUB_ACTIONS_IDENTITY_NAME} ${LAYER_1_AZURE_RESOURCE_GROUP}

gh variable set AZURE_CLIENT_ID --repo "${GITHUB_OWNER_NAME}/${GITHUB_REPO_NAME}" --body "${GITHUB_ACTIONS_CLIENT_ID}"
gh variable set AZURE_TENANT_ID --repo "${GITHUB_OWNER_NAME}/${GITHUB_REPO_NAME}" --body "${AZURE_TENANT_ID}"
gh variable set AZURE_SUBSCRIPTION_ID --repo "${GITHUB_OWNER_NAME}/${GITHUB_REPO_NAME}" --body "${AZURE_SUBSCRIPTION_ID}"
