# Current publication note

Azure DevOps vWAN NVA-ready: **Customer testing in progress** as of 22 November 2026.

GitHub verification is reported by the package owner. No independent run evidence or NVA traffic/security certification accompanies this publication. Azure DevOps scenarios are not represented as end-to-end verified. No production-readiness or failure-free guarantee.

Historical preparation/test statements in earlier guide sections are superseded by this publication status. No deployment source or input values changed for publication; only documentation/manifests/hashes changed. Inactive tfvars-only scenario candidates were omitted to avoid confusing them with verified active packages.

See [exact changed files and generated locations](FILE-CHANGES.md).

## Historical change record

# vWAN NVA-ready - changed files

Azure DevOps revision 1 | 2026-11-22

New package derived from GitHub vWAN NVA-ready revision 5 (19 November). Original GitHub package preserved.

## New in Azure DevOps package: `config\inputs.yaml`

Select alz_azuredevops; replace GitHub org/PAT/runner settings with Azure DevOps org/project/two PAT placeholders/use_self_hosted_agents. Make create-project/separate-template/branch-policy choices explicit. Approvers are existing Azure DevOps user principal names.

Local bootstrap input; produces Azure Repos/Pipelines/service connections/agent pool. No input YAML is a policy effect configuration.

## New in Azure DevOps package: `Start-CustomerBootstrap.ps1`

Validate Azure DevOps inputs and two secret environment variables; require native plan/apply helper guards and the correct network overlay. Keep exact ALZ import, narrow online-version skip, legacy environment cleanup and ordinary output directory.

Local launcher only; no need to modify an installed signed ALZ module.

## New in Azure DevOps package: `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-plan.yaml`

Add ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "false" to AzureCLI@2 task env. Shared helper covers both CI and CD plans.

Templates repo: .pipelines\helpers\terraform-plan.yaml

## New in Azure DevOps package: `sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-apply.yaml`

Add the same task env entry for apply, which runs in a separate process/job.

Templates repo: .pipelines\helpers\terraform-apply.yaml

## Native pinned files selected, not rewritten: `sources\bootstrap\alz\azuredevops\pipelines\terraform\main\ci.yaml; main\cd.yaml; templates\ci-template.yaml; templates\cd-template.yaml`

Use official Azure DevOps pipelines with service connections/agent pools and separate templates instead of GitHub Actions. Terraform 1.14.9 remains the caller default. No global YAML/env flag added to these callers.

Platform repo: .pipelines\ci.yaml / cd.yaml; templates repo: .pipelines\ci-template.yaml / cd-template.yaml

## New verification: `tests\Test-Launcher.ps1`

12 isolated regression cases per scenario; covers secret/input rejection, both task guards, topology/DNS wiring, CheckOnly isolation and stubbed bootstrap forwarding.

Local test only; synthetic values never call Azure or Azure DevOps.

## Retained Saudi compatibility: `config\platform-landing-zone.tfvars`

starter_locations remains Saudi. management_group_settings.location = "uaenorth" locates policy assignments/managed identities in UAE North. policy_default_values.resource_group_location stays Saudi.

Platform repo: platform-landing-zone.auto.tfvars; main.management.groups.tf already forwards the location.

## Retained reduced profile: `config\platform-landing-zone.tfvars`

management_resources_enabled=false suppresses management LAW/AMA identity/DCR resources. DDoS and both gateway enable flags remain false; Azure Firewall is disabled; DNS Resolver false; Bastion host/public-IP zones empty. Resource name strings alone do not deploy them.

Platform repo: platform-landing-zone.auto.tfvars. These are retained choices/compatibility workarounds, not all proven region-wide service limitations.

## Retained Saudi DNS fix: `overlays\modules\vendor\private-dns-zones\locals.tf`

Retain saudiarabiaeast = "sae" override for Backup private zone: privatelink.sae.backup.windowsazure.com.

Platform repo: modules\vendor\private-dns-zones\locals.tf

## Retained local-source wiring: `overlays\main.connectivity.virtual.wan.tf; overlays\modules\vendor\virtual-wan\main.tf`

Root selects local virtual-wan; connectivity module calls sibling ../private-dns-zones. Preserve pinned module and licenses; do not patch downloaded .terraform caches.

Platform repo: main.connectivity.virtual.wan.tf; modules\vendor\virtual-wan\main.tf

## Retained reduced policy scope: `config\lib\archetype_definitions\root_custom.alz_archetype_override.yaml`

Root omits Deploy-AzActivity-Log, Deploy-Diag-LogsCat and Deploy-MDFC-Config-H224 because the reduced profile has no management workspace. No new global Audit-only conversion was added.

Platform repo: lib\archetype_definitions\root_custom.alz_archetype_override.yaml

## Retained reduced policy scope: `config\lib\archetype_definitions\platform_custom.alz_archetype_override.yaml`

Remove workspace/DCR-dependent VM/VMSS/Arc monitoring/change-tracking, MDFC SQL AMA and AMA identity-delete control.

Platform repo: lib\archetype_definitions\platform_custom.alz_archetype_override.yaml

## Retained reduced policy scope: `config\lib\archetype_definitions\landing_zones_custom.alz_archetype_override.yaml; connectivity_custom.alz_archetype_override.yaml`

Landing Zones omits workspace-dependent diagnostics/monitoring and DDoS enforcement; Connectivity omits Enable-DDoS-VNET. Other inherited guardrails still apply.

Platform repo: lib\archetype_definitions\... (same filenames)

## Retained Saudi DNS policy parameter: `config\platform-landing-zone.tfvars > management_group_settings.policy_assignments_to_modify.corp`

Preserve Deploy-Private-DNS-Zones parameter dnzZoneRegionShortNames.saudiarabiaeast = "sae". The upstream parameter spelling is intentional.

Platform repo: platform-landing-zone.auto.tfvars

## Retained pinned library/hierarchy: `config\lib\alz_library_metadata.json; architecture_definitions\alz_custom.alz_architecture_definition.yaml`

Keep platform/alz@2026.11.0 and existing hierarchy. Coordinate child IDs/parent links/placement/override keys for any customer prefix. A new state does not avoid tenant-wide group collisions.

Platform repo: lib (matching paths)

## New handover/provenance: `README.md; START-HERE.md; docs\CUSTOMER-INSTRUCTIONS.md; docs\CHANGE-SUMMARY.md; docs\VALIDATION.md; customer Word guide; PACKAGE-MANIFEST.json; FILES.sha256`

Replace GitHub-specific operational guides and stale historical deployment claims with Azure DevOps instructions, exact changed-file mapping and fresh local validation boundaries. Remove copied inactive scenario samples from vWAN.

Package handover files; not live Azure resources.

## Retained vWAN NVA preparation: `config\platform-landing-zone.tfvars`

New WAN/hub plus sidecar/NVA subnet only. The sample NVA IP does not create full inspected vWAN routing, appliances or HA. Saudi S2S flag stays false.

Platform repo: platform-landing-zone.auto.tfvars. Existing-WAN reuse and vendor routing require a separate reviewed customer profile.

## Revision 2 - documentation-only clarification

Download block now begins with stop-on-error and the pinned version, uses $PWD.Path, and has valid multiline Invoke-WebRequest syntax. Both inputs already contain the top-level bootstrap_subscription_id; no duplicate added. Word and Markdown guides updated. PACKAGE-MANIFEST.json / FILES.sha256 refreshed; executable source unchanged.
