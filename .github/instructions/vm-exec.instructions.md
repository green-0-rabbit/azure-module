---
applyTo: "**"
---
# VM Execution Workflow

When you need to execute commands on the remote Bastion VM (e.g., for testing connectivity, running curl, or checking network status), you must follow this workflow:

1. **Load Environment Variables:** Always run `glb-var dev` as it is a shell function, first to load the necessary environment variables (specifically `TF_VAR_admin_password`).
2. **Execute Command:** Use `just vm-exec-example '<example_dir>' '<command>'` to run the command on the VM.

**Example:**
```bash
glb-var dev && just vm-exec-example 'todo-api' 'curl -v http://example.com'
```

**Note:** Ensure that the command passed to `just vm-exec-example` is properly quoted to avoid shell expansion issues on the local machine.
