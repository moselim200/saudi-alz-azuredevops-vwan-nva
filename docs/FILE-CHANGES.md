# Azure DevOps vWAN NVA-ready - exact changed files

Azure DevOps vWAN NVA-ready: **Customer testing in progress** as of 22 November 2026.

GitHub verification is reported by the package owner. No independent run evidence or NVA traffic/security certification accompanies this publication. Azure DevOps scenarios are not represented as end-to-end verified. No production-readiness or failure-free guarantee.

Historical preparation/test statements in earlier guide sections are superseded by this publication status. No deployment source or input values changed for publication; only documentation/manifests/hashes changed. Inactive tfvars-only scenario candidates were omitted to avoid confusing them with verified active packages.

Paths are relative to the extracted preparation package; generated paths belong to the matching tracked repositories, not .terraform caches.

## `config\inputs.yaml`

Select alz_azuredevops and org/project inputs, two PAT placeholders and use_self_hosted_agents. Separate template repo/branch policy settings retained. Approvers are Azure DevOps user principal names. bootstrap_subscription_id is a top-level input. Entire bootstrap is uaenorth; four platform subscriptions and bootstrap IPAM are customer inputs, not supplied real values.

**Generated location:** Local bootstrap input; generated repositories and bootstrap Azure resources.

## `Start-CustomerBootstrap.ps1`

Stage library + matching topology root + local modules + tests into ordinary output. Import exact ALZ 7.1.5; skip only online latest-version lookup with -skipAlzModuleVersionRequirementsCheck. Clear legacy ARM_PROVIDER_ENHANCED_VALIDATION and set ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS=false locally. Do not edit installed signed modules. Offline checks do not prove cloud access, quota, policy compliance or traffic.

**Generated location:** Local launcher; no direct generated repository counterpart.

## `config\platform-landing-zone.tfvars`

Keep starter_locations=["saudiarabiaeast"]. management_group_settings.location="uaenorth" locates policy assignments/system-assigned identities outside Saudi; policy_default_values.resource_group_location remains Saudi. These are separate from bootstrap pipeline user-assigned identities.

**Generated location:** Platform repo: platform-landing-zone.auto.tfvars; main.management.groups.tf forwards location.

## `config\platform-landing-zone.tfvars`

Reduced test profile: management_resources_enabled=false; DDoS, Azure Firewall, Resolver and VPN/ExpressRoute flags false. Private zones/links/registration and Bastion remain enabled; Bastion and public-IP zones=[] retained. Some omissions reflect historical test rejections and others customer choices, not proof of universal current unavailability. Names alone enable nothing.

**Generated location:** Platform repo: platform-landing-zone.auto.tfvars.

## `overlays\main.connectivity.virtual.wan.tf`

Call supplied local modules/vendor/virtual-wan rather than an unpatched registry root; preserve native provider mapping/arguments.

**Generated location:** Platform repo root: main.connectivity.virtual.wan.tf.

## `overlays\modules\vendor\virtual-wan\main.tf`

Connectivity module calls sibling ../private-dns-zones. Pinned roots/child source references and licenses retained; hub-spoke ships its two required local children.

**Generated location:** Platform repo: modules\vendor\virtual-wan\main.tf.

## `overlays\modules\vendor\private-dns-zones\locals.tf`

Saudi Backup mapping saudiarabiaeast="sae" retained; zone privatelink.sae.backup.windowsazure.com. Upstream behavior for other regions retained.

**Generated location:** Platform repo: modules\vendor\private-dns-zones\locals.tf.

## `config\platform-landing-zone.tfvars > management_group_settings.policy_assignments_to_modify.corp`

Deploy-Private-DNS-Zones uses dnzZoneRegionShortNames.saudiarabiaeast="sae". Keep the upstream dnz spelling and merge overrides rather than replacing unrelated entries.

**Generated location:** Platform repo: platform-landing-zone.auto.tfvars.

## `config\lib\archetype_definitions\root_custom.alz_archetype_override.yaml`

Exclude Deploy-AzActivity-Log, Deploy-Diag-LogsCat and Deploy-MDFC-Config-H224 in reduced profile.

**Generated location:** Platform repo: lib\archetype_definitions\root_custom.alz_archetype_override.yaml.

## `config\lib\archetype_definitions\platform_custom.alz_archetype_override.yaml`

Exclude workspace/DCR-dependent VM/VMSS/Arc monitoring/change-tracking, MDFC SQL AMA and the AMA identity deletion control. Other inherited assignments still apply.

**Generated location:** Platform repo: lib\archetype_definitions\platform_custom.alz_archetype_override.yaml.

## `config\lib\archetype_definitions\landing_zones_custom.alz_archetype_override.yaml; connectivity_custom.alz_archetype_override.yaml`

Landing Zones excludes workspace-dependent diagnostics/monitoring and Enable-DDoS-VNET. Connectivity also excludes Enable-DDoS-VNET. Does not guarantee no paid Defender plans or all-Audit effects.

**Generated location:** Platform repo: lib\archetype_definitions (matching files).

## `config\lib\alz_library_metadata.json; architecture_definitions\alz_custom.alz_architecture_definition.yaml`

platform/alz@2026.11.0 custom library/hierarchy retained. Prefix changes require coordinated IDs, parent links, subscription targets and override keys. Different folders/state do not prevent tenant-wide collisions.

**Generated location:** Platform repo: lib (matching paths).

## `config\platform-landing-zone.tfvars; overlays\tests; tests (where supplied)`

New WAN/hub and sidecar NVA subnet groundwork, not full appliance routing/inspection. No vendor appliance/license, HA endpoint, workload spokes or traffic acceptance added. Replace sample next hop with real approved vendor integration before routing traffic.

**Generated location:** Platform repository topology resources/modules and staged tests; local launcher tests are not uploaded as root runtime.

## `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-plan.yaml`

AzureCLI@2 task env contains ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "false". One shared helper used by both CI and CD plan; no duplicate per plan pipeline needed.

**Generated location:** Templates repo: .pipelines\helpers\terraform-plan.yaml.

## `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-apply.yaml`

Separate task env contains the same location flag; apply does not inherit the plan process environment.

**Generated location:** Templates repo: .pipelines\helpers\terraform-apply.yaml.

## `sources\bootstrap\alz\azuredevops\pipelines\terraform\main and templates`

Native Azure DevOps YAML selected, not GitHub YAML conversion. Calls service connections/agent pool/separate templates. Approval check on apply service connection only exists with nonempty approvers; minimum reviewer policies need more than one approver in pinned implementation.

**Generated location:** Platform: .pipelines\ci.yaml / cd.yaml; templates: .pipelines\ci-template.yaml / cd-template.yaml.

## Publication-only changes

README, Word guide appendix/front notice, PUBLICATION-STATUS.md, FILE-CHANGES.md, CHANGE-SUMMARY.md pointer, validation status, package manifest and FILES.sha256. No subscriptions, current state, tenant/customer data, credentials or active deployments included.

## Complete Windows Terraform prerequisite

```powershell
$ErrorActionPreference = "Stop"
$version = "1.14.9"
$tools = Join-Path $PWD.Path ".tools\terraform_$version"
New-Item -ItemType Directory -Path $tools -Force | Out-Null
$zip = Join-Path $tools "terraform_${version}_windows_amd64.zip"
Invoke-WebRequest "https://releases.hashicorp.com/terraform/$version/terraform_${version}_windows_amd64.zip" -OutFile $zip
$expected = "5518b04ea610115b17b427b57d8ec1d50a42a2ad63ab2d7a453b788d6c804d14"
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw "Terraform archive checksum mismatch"
}
Expand-Archive -LiteralPath $zip -DestinationPath $tools -Force
$terraform = Join-Path $tools "terraform.exe"
& $terraform version
```
