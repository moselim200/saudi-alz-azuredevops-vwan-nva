# Current validation boundary

Azure DevOps vWAN NVA-ready: **Customer testing in progress** as of 22 November 2026.

GitHub verification is reported by the package owner. No independent run evidence or NVA traffic/security certification accompanies this publication. Azure DevOps scenarios are not represented as end-to-end verified. No production-readiness or failure-free guarantee.

Historical preparation/test statements in earlier guide sections are superseded by this publication status. No deployment source or input values changed for publication; only documentation/manifests/hashes changed. Inactive tfvars-only scenario candidates were omitted to avoid confusing them with verified active packages.

Local preparation evidence remains historical. Azure DevOps packages passed native bootstrap init/validate, stubbed launcher checks and local rendered YAML checks; these do not prove live Azure DevOps execution. Customer environments require separate regional capacity, inheritance, state ownership, quota and security review.

# Local validation and limitations

Date: 2026-11-22. Azure DevOps revision 1.

- Terraform 1.14.9 native Azure DevOps bootstrap: init -backend=false and validate passed in an isolated copy; identical bootstrap source in both packages.
- 12 focused launcher cases passed per scenario. Deploy-Accelerator was stubbed. No real Azure or Azure DevOps operation was performed.
- Active platform tfvars, custom policy library and connectivity overlays were preserved byte-for-byte from the prior GitHub source packages.
- Both task env guards parsed/verified; CI and CD reuse the plan helper and CD uses the apply helper. Rendered template YAML and inline PowerShell were checked locally, not compiled by Azure Pipelines.
- Existing network tests/schema checks remain in their corresponding sources. Their earlier GitHub results are not an Azure DevOps end-to-end test.
- Source-only ZIP inventory, every FILES.sha256 entry and Word XML/command contents are verified at packaging.
- No customer bootstrap/CI/CD, regional quota/capacity, permissions, NVA traffic/failover or security compliance pass is claimed.
- Live/customer testing is still required before production.

Revision 2: complete download block parsed as PowerShell; Word/Markdown blocks match. Both top-level bootstrap_subscription_id placeholders verified. Runtime inputs/launcher/pipelines/policy/network source unchanged from revision 1; no new live deployment.
