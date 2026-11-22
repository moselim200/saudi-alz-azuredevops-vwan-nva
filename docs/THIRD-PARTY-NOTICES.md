# Source provenance and licenses

The copied bootstrap and Azure Verified Module roots are MIT-licensed Microsoft
sources. Their original notices are retained:

- `sources\bootstrap\LICENSE`
- `overlays\modules\vendor\virtual-wan\LICENSE`
- `overlays\modules\vendor\private-dns-zones\LICENSE`

The bootstrap snapshot is from
https://github.com/Azure/accelerator-bootstrap-modules at
`7887040f5e865ba134b4108aeac7b83a397a0d5c`. The working-copy changes in the two
GitHub Terraform workflow templates are intentionally included.

The local Virtual WAN and Private DNS roots retain their versions, immutable
upstream references, licenses and compatibility notes in
`overlays\modules\vendor\README.md`. They are locally modified AVM-derived roots,
not a new Microsoft-published regional AVM release.

Upstream developer files are retained in the bootstrap snapshot for provenance;
its `.github` test/cleanup scripts are not part of customer bootstrap execution.
Do not run those cleanup helpers as a customer deployment/reset procedure.

Other dependencies are downloaded by the standard ALZ/Terraform workflow under
their own licenses. They are not bundled as executables or dependency caches.
