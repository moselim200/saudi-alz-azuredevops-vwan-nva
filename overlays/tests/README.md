# Virtual WAN and Saudi DNS offline tests

Run the tests from the repository root with Terraform and PowerShell 7 installed:

```powershell
.\tests\Invoke-Tests.ps1
```

The runner tests the real platform landing zone inputs with mocked providers,
checks the Saudi profile's monitoring/policy exclusions, nonzonal Bastion, retained
DNS zones, UAE policy identity/Saudi resource location separation, and generated
DNS names with a missing upstream geo code, then tests
apply-time customer public IP IDs through an HCL consumer fixture. No Azure
credentials are required. Module and provider downloads
need internet access on initialization. To run only the apply-time ID fixture, use:

```powershell
.\tests\Invoke-Tests.ps1 -ComputedOnly
```
