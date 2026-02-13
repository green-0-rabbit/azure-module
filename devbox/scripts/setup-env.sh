#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"

echo "==> Setting up TF_VAR_admin_password"
read -rsp "Enter the admin password: " password
echo

if [[ -z "$password" ]]; then
  echo "Error: password cannot be empty." >&2
  exit 1
fi

echo "TF_VAR_admin_password=${password}" > "$ENV_FILE"
echo "==> Saved to ${ENV_FILE}"
