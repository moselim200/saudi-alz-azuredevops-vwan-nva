# Azure DevOps vWAN NVA-ready

Azure DevOps vWAN NVA-ready: **Customer testing in progress** as of 22 November 2026.

GitHub verification is reported by the package owner. No independent run evidence or NVA traffic/security certification accompanies this publication. Azure DevOps scenarios are not represented as end-to-end verified. No production-readiness or failure-free guarantee.

Historical preparation/test statements in earlier guide sections are superseded by this publication status. No deployment source or input values changed for publication; only documentation/manifests/hashes changed. Inactive tfvars-only scenario candidates were omitted to avoid confusing them with verified active packages.

Read [exact changed files](docs/FILE-CHANGES.md), [current status](docs/PUBLICATION-STATUS.md) and the included Word customer guide. Use the ordinary output folder; do not restart or delete existing state to apply this documentation update.

## Download only this scenario

Select **Code → Download ZIP** on this repository, extract the ZIP to a new folder, and run from the folder containing `Start-CustomerBootstrap.ps1`. This repository contains one scenario at its root; there is no extra `scenarios` directory to select.

The Word guide is in `docs`; exact changes and generated file paths are in [docs/FILE-CHANGES.md](docs/FILE-CHANGES.md). Fill customer inputs locally, never commit PATs/state, and keep existing deployment state when retrying.

The combined [scenario catalogue](https://github.com/moselim200/saudi-alz-scenario-packages) remains available with all four scenarios and release downloads. Original third-party licenses/notices are preserved; the top-level license applies to repository-authored adaptations.

## Existing customer instructions

# Saudi Landing Zone - vWAN NVA-ready - Terraform + Azure DevOps

Separate Azure DevOps Services customer test package; GitHub packages are unchanged.

Start with [customer instructions](docs/CUSTOMER-INSTRUCTIONS.md) or the Word guide [CUSTOMER-GUIDE-VWAN-AZUREDEVOPS.docx](docs/CUSTOMER-GUIDE-VWAN-AZUREDEVOPS.docx).
See [exact changes and files](docs/CHANGE-SUMMARY.md) and [validation boundaries](docs/VALIDATION.md).

Prerequisites: https://azure.github.io/Azure-Landing-Zones/accelerator/1_prerequisites/azuredevops/

Fill `config\inputs.yaml` and review `config\platform-landing-zone.tfvars` / `config\lib`.
Use PowerShell 7.4+ and Terraform 1.14.9:

```powershell
.\Start-CustomerBootstrap.ps1 -CheckOnly -TerraformPath "<absolute-path-to-terraform.exe>"
.\Start-CustomerBootstrap.ps1 -TerraformPath "<absolute-path-to-terraform.exe>"
```

Before the second command, set both TF_VAR Azure DevOps PATs with masked prompts as documented.
Never save tokens in inputs, Git or shared output. Review the bootstrap plan before applying.

Saudi workload region; UAE North private bootstrap and policy identities are explicit approval exceptions.
NVA-ready means network groundwork, not an installed appliance, HA or validated inspection.
LAW/AMA/DCR management resources, Azure Firewall, Resolver, DDoS and gateways remain disabled.
Private DNS/Bastion remain enabled with retained Saudi DNS mapping and non-zonal Bastion/public IP.

The new project/repository names and tenant-wide group IDs must be collision-free. Do not reuse existing
state/names or swap topology in a deployed environment. Empty apply_approvers creates no human approval check.
Main changes can trigger CD automatically. Authorize agents/service connections and configure approvals first.

Pins: ALZ 7.1.5, Terraform 1.14.9, starter v17.7.0, virtual-wan 0.18.0,
Private DNS 0.23.2, ALZ library platform/alz@2026.11.0. Provider dependency ranges may select newer versions;
preserve generated lockfiles and review upgrades. Public upstream sources may still be hosted on GitHub.

Source-only package: no runtime output/state/plans, provider caches, executables or credentials.
No customer Azure DevOps deployment has been executed for this package.
