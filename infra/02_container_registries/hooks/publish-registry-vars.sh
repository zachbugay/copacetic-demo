#!/usr/bin/env bash
#
# Publishes the Terraform outputs from `azd provision` as GitHub repository variables
# Run after `azd provision`. Requires the gh CLI to be authenticated.

set -euo pipefail

declare -a KEYS=(
  ACR_RESOURCE_GROUP
  ACR_AZURE_LOCATION
  ACR_DMZ_REGISTRY_NAME
  ACR_DMZ_REGISTRY_ENDPOINT
  ACR_DMZ_REGISTRY_ID
  ACR_GOLD_REGISTRY_NAME
  ACR_GOLD_REGISTRY_ENDPOINT
  ACR_GOLD_REGISTRY_ID
)

for key in "${KEYS[@]}"; do
  value="${!key:-}"
  if [[ -z "$value" ]]; then
    echo "error: ${key} not found in azd environment. Has 'azd provision' completed?" >&2
    exit 1
  fi

  gh variable set "${key}" --repo "${GITHUB_OWNER_NAME}/${GITHUB_REPO_NAME}" --body "${value}"
  echo "set ${key}=${value}"
done

echo "Repository variables published. The workflows are ready to run."
