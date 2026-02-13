# Path to the .env file and the prompt helper
env_file := "examples/.env"
setup_script := "devbox/scripts/setup-env.sh"

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
    if [ ! -f {{env_file}} ] || ! grep -q '^TF_VAR_admin_password=.' {{env_file}}; then \
        echo "No TF_VAR_admin_password found in {{env_file}}."; \
        bash {{setup_script}} {{env_file}}; \
    fi

[group('examples')]
tf-init-ex example: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} init

[group('examples')]
tf-plan-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} plan -var-file=dev.tfvars {{args}}

[group('examples')]
tf-apply-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} apply -var-file=dev.tfvars {{args}}

[group('examples')]
tf-destroy-ex example *args: ensure-env
    #!/usr/bin/env bash
    set -euo pipefail
    set -a; source {{env_file}}; set +a
    terraform -chdir=examples/{{example}} destroy -var-file=dev.tfvars {{args}}
