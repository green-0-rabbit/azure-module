# Example recipes read their configuration from the shell environment. Load it with `glb-var dev`
# in the same shell before running them.

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

# Fail early if the shell environment has not been loaded. Every example recipe reads its
# configuration from the environment, so a missing variable here would otherwise surface as an
# opaque Terraform or SSH error later.
[group('examples')]
[private]
@require-env:
    if [ -z "${ARM_SUBSCRIPTION_ID:-}" ] || [ -z "${TF_VAR_admin_password:-}" ]; then \
        echo "Error: ARM_SUBSCRIPTION_ID and TF_VAR_admin_password must be set."; \
        echo "Run 'glb-var dev' in the same shell, then re-run this recipe."; \
        exit 1; \
    fi

[group('examples')]
tf-init-ex example: require-env
    #!/usr/bin/env bash
    set -euo pipefail
    terraform -chdir=examples/{{example}} init

[group('examples')]
@tf-import-ex example address id: require-env
    terraform -chdir=examples/{{example}} import -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" \
        {{address}} {{id}}

[group('examples')]
tf-plan-ex example *args: require-env
    #!/usr/bin/env bash
    set -euo pipefail
    terraform -chdir=examples/{{example}} plan -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('examples')]
tf-apply-ex example *args: require-env
    #!/usr/bin/env bash
    set -euo pipefail
    terraform -chdir=examples/{{example}} apply -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('examples')]
tf-destroy-ex example *args: require-env
    #!/usr/bin/env bash
    set -euo pipefail
    terraform -chdir=examples/{{example}} destroy -var-file=dev.tfvars \
        -var="subscription_id=${ARM_SUBSCRIPTION_ID}" {{args}}

[group('ops')]
vm-exec-example example_dir +command: require-env
    #!/usr/bin/env bash
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
    # UserKnownHostsFile=/dev/null matters as much as StrictHostKeyChecking here. Bastion VMs are
    # recreated on the same public IP, and when a recorded host key changes ssh silently disables
    # password authentication as MITM protection. That surfaces as
    # "Permission denied (publickey,password)", which reads like a wrong password rather than a
    # stale known_hosts entry. Not recording the key at all avoids the trap.
    sshpass -p "$TF_VAR_admin_password" ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=5 \
        bastionadmin@$IP "{{command}}"
