# Saudi Landing Zone - vWAN NVA-ready: Terraform + Azure DevOps

Revision 2 | 2026-11-22

## What this package delivers

vWAN NVA-ready with Terraform and Azure DevOps Services. This is a separate source package derived from GitHub vWAN NVA-ready revision 5 (19 November); the original GitHub package and customer deployments are unchanged. No customer-specific checklist, policy Audit-only rollout, per-subscription alert-RG names, AMBA, Sentinel or Palo Alto appliance was added. Use a fresh isolated lab; do not change topology against existing state.

## Required approvals and limitations

Platform workload region: Saudi Arabia East. Entire bootstrap (state, ACR, ACI agents, networking and pipeline user-assigned identities) is UAE North; policy assignment identities use UAE North too. Obtain explicit residency/operations approval. Management monitoring, Azure Firewall, Resolver, DDoS and gateways remain omitted. Prior regional failures justify the reduced profile; they are not a universal current availability claim. Revalidate customer service/SKU/zone support separately.

## NVA scope

vWAN groundwork creates a new WAN, hub and sidecar containing an NVA subnet, Bastion and private DNS. No NVA appliance or validated inspection/service-chaining route design is included. Do not assume that the sample 10.0.4.68 next-hop name makes all traffic inspected. VPN/ExpressRoute stay disabled; the Saudi vWAN S2S constraint is not solved by this package.

## 1. Prerequisites

Windows x64 and PowerShell 7.4+ (use pwsh), Git and Azure CLI on PATH. Install ALZ 7.1.5 and powershell-yaml from PSGallery. Terraform 1.14.9 must be available BEFORE the custom launcher; it performs offline fmt/profile checks before the normal bootstrap download. Network access to Microsoft, Terraform registries/HashiCorp releases and public source repositories is still needed even though customer source control is Azure DevOps.
Assume familiarity with Azure DevOps project/repository/Pipeline prerequisites. Follow https://azure.github.io/Azure-Landing-Zones/accelerator/1_prerequisites/azuredevops/
Review Azure tenant/subscription permissions using https://azure.github.io/Azure-Landing-Zones/accelerator/1_prerequisites/platform-subscriptions/ . Approve management-group creation/subscription placement and bootstrap role assignments; do not reuse occupied subscriptions without a state-aware design.

## 2. Install pinned tools

Use a new extracted package folder, then cd to that folder. These download commands are for Windows amd64, not ARM64. If Terraform 1.14.9 is already installed, set $terraform to its absolute terraform.exe path instead of downloading again. Do not copy a machine-specific path into inputs.yaml.

```powershell
Install-Module ALZ -RequiredVersion 7.1.5 -Repository PSGallery -Scope CurrentUser
Install-Module powershell-yaml -Repository PSGallery -Scope CurrentUser
$ErrorActionPreference = "Stop"
$version = "1.14.9"

$tools = Join-Path $PWD.Path ".tools\terraform_$version"
New-Item -ItemType Directory -Path $tools -Force | Out-Null

$zip = Join-Path $tools "terraform_${version}_windows_amd64.zip"
Invoke-WebRequest `
  "https://releases.hashicorp.com/terraform/$version/terraform_${version}_windows_amd64.zip" `
  -OutFile $zip

$expected = "5518b04ea610115b17b427b57d8ec1d50a42a2ad63ab2d7a453b788d6c804d14"
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw "Terraform archive checksum mismatch"
}

Expand-Archive -LiteralPath $zip -DestinationPath $tools -Force
$terraform = Join-Path $tools "terraform.exe"
& $terraform version
```

Run the complete download block, including $version, in the same PowerShell window. Terraform's newer-version notice is informational; keep 1.14.9 for this package. bootstrap_subscription_id is a required top-level setting in config\inputs.yaml, separate from subscription_ids; it may match Management when approved.

## 3. Prepare Azure DevOps credentials

Create token-1 with the scopes in the official prerequisites: Agent Pools Read & manage, Build Read & execute, Code Full, Environment Read & manage, Graph Read & manage, Pipeline Resources Use & manage, Project and Team Read/write/manage, Service Connections Read/query/manage, Variable Groups Read/create/manage. Use a short bootstrap lifetime. Token-2 needs Agent Pools Read & manage for self-hosted registration; set a reviewed expiration and renewal process. PAT owner permissions/tenant policies must allow the operations. Keep the literal <azure_devops_personal_access_token> and <azure_devops_agents_personal_access_token> placeholders in YAML. Secrets use process environment variables, not committed tfvars or documents. Treat local generated bootstrap state/output as sensitive because it can contain secret values.

## 4. Fill customer inputs

Edit config\inputs.yaml: existing parent ID, four distinct platform subscription GUIDs, bootstrap subscription, lowercase-alphanumeric service/environment names, org name (not URL), project name, bootstrap CIDRs and approved apply_approvers. azure_devops_create_project=true creates a new project; false looks up an existing one by name. Confirm repo names/collisions and permissions; default project privacy must be reviewed in the plan. Keep separate templates and native self-hosted agents/private networking flags as supplied.
Edit config\platform-landing-zone.tfvars: customer resource names, approved Saudi platform IPAM and NVA next hop. Keep correct topology and reduced compatibility flags. Review config\lib architecture IDs: a root prefix alone does not rename every child, subscription target or policy-override key.

## 5. Approval and agent safety

apply_approvers=[] retains a lab-only no-human-gate setting: the pinned module creates no approval check when empty. Configure existing user principal names and inspect apply service-connection checks before CD. With one approver the pinned module allows requester approval; at least two distinct approvers are recommended for separation of duties. Minimum-reviewer branch policies are enabled only when the approver count exceeds one; create_branch_policies=true alone is not a guarantee.
Private endpoints do not protect a privileged agent from malicious pipeline code. Restrict repo/PR access, pool permissions, service-connection authorization and template changes. Verify project/Pipeline licensing and self-hosted parallel-job availability; Microsoft-hosted free capacity is not used by this profile.

## 6. Offline checks and bootstrap

Sign in to the approved tenant/subscription. Run CheckOnly before supplying PATs; it checks input syntax, paths, correct topology/DNS wiring, plan/apply task flags and Terraform formatting (plus hub-spoke contract). It is not an Azure/DevOps permission check or traffic/security readiness test.
Then set the two masked PAT variables and run the launcher. It imports exactly ALZ 7.1.5 and skips only the online latest-release lookup; all other ALZ prerequisites remain. It clears legacy ARM_PROVIDER_ENHANCED_VALIDATION and sets ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS=false locally. It does not alter signed installed modules or machine package-feed settings.

```powershell
az login --tenant "<customer-tenant-id>"
az account set --subscription "<bootstrap-subscription-id>"
.\Start-CustomerBootstrap.ps1 -CheckOnly -TerraformPath $terraform

$env:TF_VAR_azure_devops_personal_access_token = Read-Host "Bootstrap PAT" -MaskInput
$env:TF_VAR_azure_devops_agents_personal_access_token = Read-Host "Agent registration PAT" -MaskInput
.\Start-CustomerBootstrap.ps1 -TerraformPath $terraform
```

## 7. Review before accepting the plan

Inspect the interactive bootstrap plan for actual resource count, UAE location, state protection, project/repo names, roles, subscriptions/groups placement and no unintended adoption/deletion. Counts are not prescribed: Azure DevOps resources differ from the former GitHub bootstrap. Approve apply only after review. Bootstrap generates the ordinary output directory; do not resume the bare interactive saver over prepared YAML.

## 8. First Azure Pipeline runs

After bootstrap, verify the self-hosted agent pool is online, WIF service connections are authorized, template repo access/required-template checks and approvals work, and state is accessible from agents. Platform repo has .pipelines\ci.yaml and cd.yaml; the template repo has .pipelines\ci-template.yaml, cd-template.yaml and helpers. CI validates/plans; CD plans and applies. CI is an optional extra review gate, not a substitute for CD plan review. CI is wired through Azure Repos branch validation, not GitHub PR syntax. Main changes trigger CD automatically; inspect existing queued/running jobs before starting another run.

## 9. What was changed and which files

The following inventory distinguishes NEW Azure DevOps changes from RETAINED Saudi compatibility adjustments. Native pipeline callers/templates are selected from the pinned source, not hand-converted GitHub YAML. The Word guide and docs\CHANGE-SUMMARY.md contain the same inventory.

### New in Azure DevOps package: `config\inputs.yaml`

Select alz_azuredevops; replace GitHub org/PAT/runner settings with Azure DevOps org/project/two PAT placeholders/use_self_hosted_agents. Make create-project/separate-template/branch-policy choices explicit. Approvers are existing Azure DevOps user principal names.

Local bootstrap input; produces Azure Repos/Pipelines/service connections/agent pool. No input YAML is a policy effect configuration.

### New in Azure DevOps package: `Start-CustomerBootstrap.ps1`

Validate Azure DevOps inputs and two secret environment variables; require native plan/apply helper guards and the correct network overlay. Keep exact ALZ import, narrow online-version skip, legacy environment cleanup and ordinary output directory.

Local launcher only; no need to modify an installed signed ALZ module.

### New in Azure DevOps package: `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-plan.yaml`

Add ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "false" to AzureCLI@2 task env. Shared helper covers both CI and CD plans.

Templates repo: .pipelines\helpers\terraform-plan.yaml

### New in Azure DevOps package: `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-apply.yaml`

Add the same task env entry for apply, which runs in a separate process/job.

Templates repo: .pipelines\helpers\terraform-apply.yaml

### Native pinned files selected, not rewritten: `sources\bootstrap\alz\azuredevops\pipelines\terraform\main\ci.yaml; main\cd.yaml; templates\ci-template.yaml; templates\cd-template.yaml`

Use official Azure DevOps pipelines with service connections/agent pools and separate templates instead of GitHub Actions. Terraform 1.14.9 remains the caller default. No global YAML/env flag added to these callers.

Platform repo: .pipelines\ci.yaml / cd.yaml; templates repo: .pipelines\ci-template.yaml / cd-template.yaml

### New verification: `tests\Test-Launcher.ps1`

12 isolated regression cases per scenario; covers secret/input rejection, both task guards, topology/DNS wiring, CheckOnly isolation and stubbed bootstrap forwarding.

Local test only; synthetic values never call Azure or Azure DevOps.

### Retained Saudi compatibility: `config\platform-landing-zone.tfvars`

starter_locations remains Saudi. management_group_settings.location = "uaenorth" locates policy assignments/managed identities in UAE North. policy_default_values.resource_group_location stays Saudi.

Platform repo: platform-landing-zone.auto.tfvars; main.management.groups.tf already forwards the location.

### Retained reduced profile: `config\platform-landing-zone.tfvars`

management_resources_enabled=false suppresses management LAW/AMA identity/DCR resources. DDoS and both gateway enable flags remain false; Azure Firewall is disabled; DNS Resolver false; Bastion host/public-IP zones empty. Resource name strings alone do not deploy them.

Platform repo: platform-landing-zone.auto.tfvars. These are retained choices/compatibility workarounds, not all proven region-wide service limitations.

### Retained Saudi DNS fix: `overlays\modules\vendor\private-dns-zones\locals.tf`

Retain saudiarabiaeast = "sae" override for Backup private zone: privatelink.sae.backup.windowsazure.com.

Platform repo: modules\vendor\private-dns-zones\locals.tf

### Retained local-source wiring: `overlays\main.connectivity.virtual.wan.tf; overlays\modules\vendor\virtual-wan\main.tf`

Root selects local virtual-wan; connectivity module calls sibling ../private-dns-zones. Preserve pinned module and licenses; do not patch downloaded .terraform caches.

Platform repo: main.connectivity.virtual.wan.tf; modules\vendor\virtual-wan\main.tf

### Retained reduced policy scope: `config\lib\archetype_definitions\root_custom.alz_archetype_override.yaml`

Root omits Deploy-AzActivity-Log, Deploy-Diag-LogsCat and Deploy-MDFC-Config-H224 because the reduced profile has no management workspace. No new global Audit-only conversion was added.

Platform repo: lib\archetype_definitions\root_custom.alz_archetype_override.yaml

### Retained reduced policy scope: `config\lib\archetype_definitions\platform_custom.alz_archetype_override.yaml`

Remove workspace/DCR-dependent VM/VMSS/Arc monitoring/change-tracking, MDFC SQL AMA and AMA identity-delete control.

Platform repo: lib\archetype_definitions\platform_custom.alz_archetype_override.yaml

### Retained reduced policy scope: `config\lib\archetype_definitions\landing_zones_custom.alz_archetype_override.yaml; connectivity_custom.alz_archetype_override.yaml`

Landing Zones omits workspace-dependent diagnostics/monitoring and DDoS enforcement; Connectivity omits Enable-DDoS-VNET. Other inherited guardrails still apply.

Platform repo: lib\archetype_definitions\... (same filenames)

### Retained Saudi DNS policy parameter: `config\platform-landing-zone.tfvars > management_group_settings.policy_assignments_to_modify.corp`

Preserve Deploy-Private-DNS-Zones parameter dnzZoneRegionShortNames.saudiarabiaeast = "sae". The upstream parameter spelling is intentional.

Platform repo: platform-landing-zone.auto.tfvars

### Retained pinned library/hierarchy: `config\lib\alz_library_metadata.json; architecture_definitions\alz_custom.alz_architecture_definition.yaml`

Keep platform/alz@2026.11.0 and existing hierarchy. Coordinate child IDs/parent links/placement/override keys for any customer prefix. A new state does not avoid tenant-wide group collisions.

Platform repo: lib (matching paths)

### New handover/provenance: `README.md; START-HERE.md; docs\CUSTOMER-INSTRUCTIONS.md; docs\CHANGE-SUMMARY.md; docs\VALIDATION.md; customer Word guide; PACKAGE-MANIFEST.json; FILES.sha256`

Replace GitHub-specific operational guides and stale historical deployment claims with Azure DevOps instructions, exact changed-file mapping and fresh local validation boundaries. Remove copied inactive scenario samples from vWAN.

Package handover files; not live Azure resources.

### Retained vWAN NVA preparation: `config\platform-landing-zone.tfvars`

New WAN/hub plus sidecar/NVA subnet only. The sample NVA IP does not create full inspected vWAN routing, appliances or HA. Saudi S2S flag stays false.

Platform repo: platform-landing-zone.auto.tfvars. Existing-WAN reuse and vendor routing require a separate reviewed customer profile.

## 10. Customer testing and feedback

Test bootstrap, agent availability, CI plan and CD plan/apply in a disposable approved lab. Check that workloads remain Saudi, identities/bootstrap remain approved UAE, Backup DNS uses sae and disabled resources are absent. For hub-spoke, verify real NVA default/summary routes, return flow and failover only after vendor integration. For vWAN, validate supported routing/propagation/inspection separately. Record sanitized pipeline run links, failing stage, error and reproduction steps; never share PATs, state, saved plans or customer GUIDs in public feedback. No customer Azure DevOps bootstrap/CI/CD or real NVA traffic has been executed here.

## Maintenance

Before bootstrap, modify preparation source config/lib and generate once. For an existing deployment, use the matching tracked Azure Repos platform/template files and existing state via PR/CI/CD; local input edits alone do not update deployed repos. Do not patch .terraform caches, rerun bootstrap into existing names, swap topology/state or assume this delivery renames existing resource groups.
The service-health RG naming default remains shared across subscriptions. No subscription-specific policy assignments were added. Policy guardrail effect defaults are unchanged and may still Deny/Modify/DINE; this is not a no-paid-Defender guarantee or an audit-only security baseline.

```powershell
$env:TF_VAR_azure_devops_personal_access_token = $null
$env:TF_VAR_azure_devops_agents_personal_access_token = $null
```
