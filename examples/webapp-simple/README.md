# webapp-simple

A Linux web app running a hello world container from a private ACR, on an Isolated v2 plan inside
an internal App Service Environment v3.

```
vnet
├── AseSubnet              → App Service Environment v3 (ILB)
│                             └── App Service Plan (I1v2)
│                                   └── Linux Web App ── AcrPull ──┐
├── PrivateEndpointSubnet  → ACR private endpoint ─────────────────┘
└── BastionSubnet          → bastion VM (the only way in)
```

## Read this before applying

**This example is expensive.** An App Service Environment v3 only accepts Isolated v2 plans, which
are the costliest App Service tier. Check current pricing for `I1v2` in your region and multiply by
`worker_count` before you apply.

**It is also slow.** Creating an App Service Environment takes far longer than a normal Terraform
resource, and destroying it is slow too. Budget accordingly, and do not assume a hung apply.

If you only need a private web app, you almost certainly do not need this. A Premium v3 plan with a
private endpoint and VNet integration gives you the same privacy at a fraction of the cost. Use
this example when something genuinely requires single-tenant compute.

## 1. Set your own names

`acr_name` must be globally unique across Azure. Edit `dev.tfvars` before the first apply.

## 2. Deploy the infrastructure

```bash
just tf-init-ex webapp-simple
just tf-plan-ex webapp-simple
just tf-apply-ex webapp-simple
```

## 3. Push the image

The registry is created empty, so the app has nothing to pull until you put an image in it. The
ACR is private, so run the import from a host that can reach it, or use `az acr import`, which runs
server side and does not need network access to the registry:

```bash
az acr import \
  --name "$(terraform -chdir=examples/webapp-simple output -raw acr_login_server | cut -d. -f1)" \
  --source mcr.microsoft.com/azuredocs/aci-helloworld:latest \
  --image hello-world:latest
```

Then restart the app so it pulls:

```bash
az webapp restart --name hello-preview --resource-group webapp-simple-preview-resource-group
```

## 4. Verify

The app resolves only inside the VNet, so test from the bastion VM:

```bash
just vm-exec-example webapp-simple "curl -sS -o /dev/null -w '%{http_code}\n' https://$(terraform -chdir=examples/webapp-simple output -raw webapp_hostname)"
```

A `200` means the environment, the private DNS zone, the plan and the ACR pull are all working.

Resolution from the bastion should return the environment's ILB address:

```bash
just vm-exec-example webapp-simple "getent hosts $(terraform -chdir=examples/webapp-simple output -raw webapp_hostname)"
```

## 5. Tear down

```bash
just tf-destroy-ex webapp-simple
```

## Reaching the app from elsewhere

Every app in the environment answers on the same internal load balancer address, and the platform
picks the app from the `Host` header. `terraform output ase_ilb_ip` shows it. Apps are reachable
from the environment's own VNet and from any network connected to it, but only where DNS resolves.

| Client | What it needs |
|---|---|
| This VNet | nothing — the bastion works out of the box |
| Peered VNet | the peering, plus an entry in `dns_consumer_vnet_ids` |
| On-premises over VPN or ExpressRoute | routing, plus a conditional forwarder for the zone to `168.63.129.16` |

Peering on its own is not enough: without a DNS link the name does not resolve, and nothing reaches
the ILB. `dns_consumer_vnet_ids` adds a link per network:

```hcl
dns_consumer_vnet_ids = {
  hub = "/subscriptions/.../virtualNetworks/hub-vnet"
}
```

Note the deployment endpoints sit behind the same address, so internet-hosted CI (GitHub Actions,
Azure DevOps hosted agents) cannot publish to this environment. That needs a self-hosted agent
inside the VNet.

## Scaling this past one app: you will want a gateway

This example runs a single app, reached at its own hostname on the environment's internal load
balancer. Two limits show up as soon as you add a second app, and a private Application Gateway or
API Management in front of the environment addresses both.

**There is no environment-level routing.** App Service has no equivalent of the `acaenv` module's
`http_route_configs`, which matches on path prefix, rewrites paths, and splits traffic across
several container apps inside one environment. On App Service that layer does not exist at the
plan or environment level, so routing `/api` to one app and `/frontend` to another has to come from
a reverse proxy you deploy yourself.

**Ingress does not collapse on its own.** A private endpoint cannot target the environment. Azure
rejects it outright:

```
Private Link for ASE is invalid. If this is an ASEv3, private endpoints
can still be added to individual apps within the ASEv3.
```

So the per-app endpoint is the only granularity available, and every app you add is another
endpoint and another record. A gateway inside the VNet gives you one private frontend for all of
them.

This is the structural difference from `acaenv`, which takes a private endpoint on the environment
itself because a Container Apps environment is Microsoft-managed infrastructure outside your VNet.
An App Service Environment is already deployed inside your subnet, so there is nothing to private
link to — `internal_load_balancing_mode` is what makes it private instead.

Note that the gateway itself is not free or trivial: it needs its own subnet, its own certificates
for TLS termination, and its own scaling story.

## Notes

- The App Service Environment takes its region from `AseSubnet`, which is why the module has no
  `location` input. The subnet must be delegated to `Microsoft.Web/hostingEnvironments` and hold
  nothing else.
- Subnet sizing: this example uses the documented minimum, `/27`, because it is a demo running a
  single instance. **Do not copy that into production.** Five addresses are reserved for management
  and the platform uses another 7 to 27 for supporting infrastructure, so a `/27` can leave zero
  addresses for plan instances and block scale-out. Production wants `/24`, or `/23` if you expect
  to approach the 200 instance cap. Changing the subnet later requires a support ticket.
- An internal environment is only resolvable through a private DNS zone named after its DNS
  suffix, which Azure does not create for you. Both that zone and the ACR zone are linked to the
  VNet through the `vnet` module's `private_dns_zone_names`, the same way `aca-simple` does it.
- That works because the zone name is built from `local.ase_dns_suffix` rather than
  `module.app_service_environment.dns_suffix`. Azure derives the suffix from the environment's
  name, so composing it from inputs keeps it a plan-time constant. Using the computed attribute
  instead fails with `Invalid for_each argument`, since `for_each` keys must be known at plan
  time. A `check` block in `dns.tf` asserts the composed name matches the real suffix.
- `docker_registry_url` is not set on the web app. The module derives it from `acr_config`, so the
  registry is named once.
