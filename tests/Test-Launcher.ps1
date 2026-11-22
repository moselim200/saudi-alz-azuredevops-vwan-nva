#Requires -Version 7.0
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$TerraformPath,
  [Parameter(Mandatory)][string]$ScratchPath
)

$ErrorActionPreference = "Stop"
$source = Split-Path -Parent $PSScriptRoot
if (Test-Path -LiteralPath $ScratchPath) { throw "Use a new empty scratch path." }
Copy-Item -LiteralPath $source -Destination $ScratchPath -Recurse
$launcher = Join-Path $ScratchPath "Start-CustomerBootstrap.ps1"
$inputs = Join-Path $ScratchPath "config\inputs.yaml"
$platform = Join-Path $ScratchPath "config\platform-landing-zone.tfvars"
$passed = 0
$global:AdoPackageTestCalls = [System.Collections.Generic.List[object]]::new()

function Assert-Rejected {
  param([scriptblock]$Action, [string]$Message)
  $rejected = $false
  try { & $Action | Out-Null }
  catch {
    if ($_.Exception.Message -notmatch $Message) { throw }
    $rejected = $true
  }
  if (-not $rejected) { throw "Expected rejection matching '$Message'." }
}

function Import-Module {
  param([string]$Name, [string]$RequiredVersion, [string]$ErrorAction)
  if ($Name -eq "ALZ") {
    if ($RequiredVersion -ne "7.1.5") { throw "Unexpected ALZ version." }
  } else { Microsoft.PowerShell.Core\Import-Module @PSBoundParameters }
}
function Deploy-Accelerator {
  param($inputs, $starterAdditionalFiles, $bootstrapModuleOverrideFolderPath, $output,
    [switch]$skipAlzModuleVersionRequirementsCheck)
  if (-not $skipAlzModuleVersionRequirementsCheck) { throw "Online ALZ version lookup was not skipped." }
  $global:AdoPackageTestCalls.Add($PSBoundParameters)
}

Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "Set customer input"
$passed++
$yaml = Get-Content -LiteralPath $inputs -Raw
$replacements = @{
  "<parent-management-group-id>" = "synthetic-validation-parent"
  "<management-subscription-id>" = "00000000-0000-0000-0000-000000000002"
  "<identity-subscription-id>" = "00000000-0000-0000-0000-000000000004"
  "<connectivity-subscription-id>" = "00000000-0000-0000-0000-000000000003"
  "<security-subscription-id>" = "00000000-0000-0000-0000-000000000005"
  "<bootstrap-subscription-id>" = "00000000-0000-0000-0000-000000000002"
  "<customer-service-name>" = "exampletest"
  "<customer-environment-name>" = "test"
  "<azure-devops-organization>" = "exampleorg"
  "<azure-devops-project>" = "exampleproject"
}
foreach ($key in $replacements.Keys) { $yaml = $yaml.Replace($key, $replacements[$key]) }
[IO.File]::WriteAllText($inputs, $yaml)
& $launcher -CheckOnly -TerraformPath $TerraformPath | Out-Null
if ($global:AdoPackageTestCalls.Count -ne 0 -or (Test-Path (Join-Path $ScratchPath "output"))) {
  throw "CheckOnly ran bootstrap or generated output."
}
$passed++

try {
  [IO.File]::WriteAllText($inputs, $yaml.Replace("exampleproject", "<azure-devops-project>"))
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "azure_devops_project_name"
  $passed++
  [IO.File]::WriteAllText($inputs, $yaml.Replace("exampletest", "invalid-name"))
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "lowercase letters and numbers"
  $passed++
  [IO.File]::WriteAllText($inputs, $yaml.Replace("<azure_devops_personal_access_token>", "synthetic-inline-token"))
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "Keep the literal"
  $passed++
} finally { [IO.File]::WriteAllText($inputs, $yaml) }

foreach ($name in @("plan", "apply")) {
  $helper = Join-Path $ScratchPath "sources\bootstrap\alz\azuredevops\pipelines\terraform\templates\helpers\terraform-$name.yaml"
  $original = Get-Content -LiteralPath $helper -Raw
  try {
    [IO.File]::WriteAllText($helper, $original.Replace('ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "false"', 'ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS: "true"'))
    Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "task environment guard"
    $passed++
  } finally { [IO.File]::WriteAllText($helper, $original) }
}

$originalPlatform = Get-Content -LiteralPath $platform -Raw
$isHub = $originalPlatform -match 'connectivity_type\s*=\s*"hub_and_spoke_vnet"'
$from = if ($isHub) { "hub_and_spoke_vnet" } else { "virtual_wan" }
$to = if ($isHub) { "virtual_wan" } else { "hub_and_spoke_vnet" }
try {
  [IO.File]::WriteAllText($platform, $originalPlatform.Replace("connectivity_type = `"$from`"", "connectivity_type = `"$to`""))
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "topology"
  $passed++
} finally { [IO.File]::WriteAllText($platform, $originalPlatform) }
$moduleName = if ($isHub) { "hub-and-spoke-vnet" } else { "virtual-wan" }
$module = Join-Path $ScratchPath "overlays\modules\vendor\$moduleName\main.tf"
$originalModule = Get-Content -LiteralPath $module -Raw
try {
  [IO.File]::WriteAllText($module, $originalModule.Replace('"../private-dns-zones"', '"unexpected-module"'))
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "Private-DNS Saudi compatibility wiring"
  $passed++
} finally { [IO.File]::WriteAllText($module, $originalModule) }

$keys = @("ALZ_output_folder_path", "TF_VAR_azure_devops_personal_access_token",
  "TF_VAR_azure_devops_agents_personal_access_token", "ARM_PROVIDER_ENHANCED_VALIDATION",
  "ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS")
$previous = @{}
foreach ($key in $keys) { $previous[$key] = [Environment]::GetEnvironmentVariable($key) }
try {
  $env:ALZ_output_folder_path = "unexpected-path"
  Assert-Rejected { & $launcher -CheckOnly -TerraformPath $TerraformPath } "Remove output_folder_path"
  $passed++
  $env:ALZ_output_folder_path = $null
  $env:TF_VAR_azure_devops_personal_access_token = $null
  $env:TF_VAR_azure_devops_agents_personal_access_token = $null
  Assert-Rejected { & $launcher -TerraformPath $TerraformPath -Confirm:$false } "Set TF_VAR_azure_devops_personal_access_token"
  $passed++
  $env:TF_VAR_azure_devops_personal_access_token = "synthetic-not-a-token"
  $env:TF_VAR_azure_devops_agents_personal_access_token = "synthetic-not-a-token"
  $env:ARM_PROVIDER_ENHANCED_VALIDATION = "false"
  & $launcher -TerraformPath $TerraformPath -Confirm:$false | Out-Null
  if ($global:AdoPackageTestCalls.Count -ne 1) { throw "Expected exactly one stubbed bootstrap invocation." }
  $captured = $global:AdoPackageTestCalls[0]
  $overlay = if ($isHub) { "main.connectivity.hub.and.spoke.virtual.network.tf" } else { "main.connectivity.virtual.wan.tf" }
  if (@($captured.starterAdditionalFiles).Count -ne 4 -or
      $captured.starterAdditionalFiles[1] -ne (Join-Path $ScratchPath "overlays\$overlay") -or
      $captured.output -ne (Join-Path $ScratchPath "output") -or
      $captured.bootstrapModuleOverrideFolderPath -ne (Join-Path $ScratchPath "sources\bootstrap") -or
      (Test-Path Env:\ARM_PROVIDER_ENHANCED_VALIDATION) -or
      $env:ARM_PROVIDER_ENHANCED_VALIDATION_LOCATIONS -ne "false") {
    throw "Unexpected bootstrap staging, output or environment."
  }
  $passed++
} finally {
  foreach ($key in $keys) { [Environment]::SetEnvironmentVariable($key, $previous[$key]) }
  Remove-Variable -Name AdoPackageTestCalls -Scope Global
}
Write-Output "PASS: $passed launcher cases; ALZ bootstrap stubbed, no Azure/Azure DevOps operations."
