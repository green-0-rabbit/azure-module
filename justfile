# Path to the .env file and the prompt helper
env_file := "examples/.env"
setup_script := "./scripts/setup-env.sh"

# ─── Terraform (modules) ─────────────────────────────────────────────────────

[group('terraform')]
@tf-fmt:
    terraform fmt -recursive

[group('terraform')]
@tf-validate *target:
    terraform -chdir={{target}} validate

[group('terraform')]
@tf-init *target:
    terraform -chdir={{target}} init

# ─── Examples ─────────────────────────────────────────────────────────────────

# Load .env if it exists, otherwise prompt the user to create it.
[group('examples')]
[private]
@ensure-env:
    if [ -z "$TF_VAR_admin_password" ]; then \
        if [ ! -f {{env_file}} ] || ! grep -q '^TF_VAR_admin_password=.' {{env_file}}; then \
            echo "No TF_VAR_admin_password found in {{env_file}} or shell."; \
            bash {{setup_script}} {{env_file}}; \
        fi \
    fi

[group('examples')]
tf-init-ex example: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} init

[group('examples')]
@tf-import-ex example address id: ensure-env
    terraform -chdir=examples/{{example}} import -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" \
        {{address}} {{id}}

[group('examples')]
tf-plan-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} plan -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('examples')]
tf-apply-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} apply -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('examples')]
tf-destroy-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} destroy -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('ops')]
vm-exec-example example_dir +command:
    #!/usr/bin/env bash
    if [ -z "$TF_VAR_admin_password" ]; then
        echo "Error: TF_VAR_admin_password is not set. Please run 'glb-var dev' first."
        exit 1
    fi

    EXAMPLE_DIR="./examples/{{example_dir}}"
    if [ ! -d "$EXAMPLE_DIR" ]; then
        echo "Error: Example directory '$EXAMPLE_DIR' does not exist."
        exit 1
    fi

    pushd "$EXAMPLE_DIR" > /dev/null
    IP=$(terraform output -raw bastion_public_ip)
    popd > /dev/null

    if [ -z "$IP" ]; then
        echo "Error: Could not get bastion VM Public IP from '$EXAMPLE_DIR'."
        exit 1
    fi

    echo "Running on $IP..."
    sshpass -p "$TF_VAR_admin_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 bastionadmin@$IP "{{command}}"
