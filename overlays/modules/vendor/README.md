# Pinned Azure module compatibility patch

These local module roots preserve the existing deployment and resource addresses
while supplying the missing Saudi Arabia East Backup DNS geo code.

| Directory | Upstream repository | Version | Commit |
| --- | --- | --- | --- |
| `virtual-wan` | https://github.com/Azure/terraform-azurerm-avm-ptn-alz-connectivity-virtual-wan | 0.18.0 | `116594239389f448c8db52b225566ef9e7ca68b5` |
| `private-dns-zones` | https://github.com/Azure/terraform-azurerm-avm-ptn-network-private-link-private-dns-zones | 0.23.2 | `4d2214f162806d48ea9a157de4b904f879fc61d4` |

Original licenses are included in each directory. Only root Terraform files are
vendored; unchanged Virtual WAN child modules use Git sources pinned to the same
upstream commit. Other dependencies retain their original version constraints.

## Local differences

- The root deployment selects the local Virtual WAN module.
- Virtual WAN selects the local Private DNS module. Its two upstream-relative
  child module sources are replaced with equivalent immutable Git sources.
- Private DNS uses `sae` for `saudiarabiaeast`, retaining upstream geo codes for
  every other region. The compatibility patch does not disable DNS zones.
- The deployment configuration separately disables Private DNS Resolver after
  Azure rejected its regional availability. Zones, VNet links, auto-registration,
  and their policy configuration remain enabled.
- `platform-landing-zone.auto.tfvars` supplies the matching
  `dnzZoneRegionShortNames` parameter to the `corp` management group's
  `Deploy-Private-DNS-Zones` policy assignment. This map replaces that parameter
  for this single-region deployment; extend it if more DNS regions are added.

The value was confirmed from an existing Saudi Arabia East Recovery Services
vault's read-only `privateLinkResources` API response:

```json
[
  "privatelink.sae.backup.windowsazure.com",
  "privatelink.queue.core.windows.net",
  "privatelink.blob.core.windows.net"
]
```

See https://learn.microsoft.com/en-us/rest/api/recoveryservices/private-link-resources/list
for the API. A region's resource-naming abbreviation is not evidence of its
Backup DNS geo code.

## Validation and retirement

Run `tests\Invoke-Tests.ps1` from the repository root. The Saudi DNS regression
tests mock upstream region data with a null Saudi geo code and verify the actual
generated zone names, plus the unchanged behavior of an existing region.

CI/CD must also retain `ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "false"` in
the reusable workflows while Azure's public metadata endpoint omits the region.
That setting does not resolve module metadata or prove service availability.

Do not edit downloaded `.terraform` files. When upstream dependencies support
the confirmed Saudi mapping, compare these local differences with the fixed
release, restore registry sources, and review a complete authenticated plan
before removing the local copies and policy override. Never apply a plan that
unexpectedly replaces or deletes existing resources.
