[group('terraform')]
@tf-fmt:
    terraform fmt -recursive

[group('terraform')]
@tf-validate *target:
    terraform -chdir={{target}} validate

[group('terraform')]
@tf-init *target:
    terraform -chdir={{target}} init



