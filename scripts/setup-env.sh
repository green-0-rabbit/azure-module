#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-.env}"

# ─── Subscription ID (auto-detect from az cli) ───────────────────────────────
echo "==> Detecting Azure subscription from 'az account show' ..."
if ! sub_id=$(az account show --query id -o tsv 2>/dev/null); then
  echo "Error: not logged in to Azure CLI. Run 'az login' first." >&2
  exit 1
fi
echo "    Using subscription: ${sub_id}"

# ─── Admin password ──────────────────────────────────────────────────────────
echo "==> Setting up TF_VAR_admin_password"
read -rsp "Enter the admin password: " password
echo

if [[ -z "$password" ]]; then
  echo "Error: password cannot be empty." >&2
  exit 1
fi

# ─── Write .env ──────────────────────────────────────────────────────────────
cat > "$ENV_FILE" <<EOF
ARM_SUBSCRIPTION_ID=${sub_id}
TF_VAR_admin_password=${password}
EOF

echo "==> Saved to ${ENV_FILE}"
