mock_provider "alz" {}
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      subscription_id = "00000000-0000-0000-0000-000000000002"
    }
  }
}
mock_provider "azurerm" {
  alias = "connectivity"
}
mock_provider "azurerm" {
  alias = "management"
}
mock_provider "azapi" {}
mock_provider "azapi" {
  alias = "connectivity"
}
mock_provider "local" {}
mock_provider "random" {}
mock_provider "time" {}

override_module {
  target = module.config.module.regions
  outputs = {
    regions_by_name = {
      saudiarabiaeast = {
        geo_code   = null
        short_name = "sae"
      }
    }
  }
}

run "saudi_available_services_profile" {
  command = plan

  variables {
    connectivity_type         = "none"
    management_groups_enabled = false
    enable_telemetry          = false
  }

  assert {
    condition = (
      jsondecode(local.policy_assignments_to_modify.corp.policy_assignments["Deploy-Private-DNS-Zones"].parameters.dnzZoneRegionShortNames).value.saudiarabiaeast == "sae" &&
      jsondecode(local.policy_default_values.private_dns_zone_region).value == "saudiarabiaeast"
    )
    error_message = "The real tfvars must pass the confirmed Saudi geo code and region to the Private DNS policy."
  }

  assert {
    condition = (
      module.config.outputs.management_group_settings.location == "uaenorth" &&
      module.config.outputs.virtual_hubs.primary.location == "saudiarabiaeast" &&
      jsondecode(local.policy_default_values.resource_group_location).value == "saudiarabiaeast"
    )
    error_message = "Policy-assignment identities must use UAE North while networking and policy-deployed resource groups remain in Saudi Arabia East."
  }

  assert {
    condition = (
      module.config.outputs.virtual_hubs.primary.enabled_resources.private_dns_zones &&
      !module.config.outputs.virtual_hubs.primary.enabled_resources.private_dns_resolver &&
      module.config.outputs.virtual_hubs.primary.private_dns_zones.auto_registration_zone_enabled
    )
    error_message = "Private DNS Resolver must be disabled while private DNS zones and auto-registration remain enabled."
  }

  assert {
    condition = (
      !var.management_resources_enabled &&
      length(module.management_resources) == 0 &&
      !contains(keys(local.policy_default_values), "log_analytics_workspace_id") &&
      alltrue([
        for key in keys(local.policy_default_values) : !startswith(key, "ama_")
      ])
    )
    error_message = "The Saudi profile must omit the workspace-backed monitoring module and its policy resource IDs."
  }

  assert {
    condition = (
      module.config.outputs.virtual_hubs.primary.enabled_resources.bastion &&
      length(module.config.outputs.virtual_hubs.primary.bastion.zones) == 0 &&
      length(module.config.outputs.virtual_hubs.primary.bastion.bastion_public_ip.zones) == 0
    )
    error_message = "Bastion must remain enabled with matching empty zone sets on the host and public IP, as required by the pinned Bastion module."
  }

  assert {
    condition = (
      alltrue([
        for name in [
          "Deploy-AzActivity-Log",
          "Deploy-Diag-LogsCat",
          "Deploy-MDFC-Config-H224"
          ] : contains(
          yamldecode(file("${path.module}/lib/archetype_definitions/root_custom.alz_archetype_override.yaml")).policy_assignments_to_remove,
          name
        )
      ]) &&
      alltrue([
        for name in [
          "Deploy-ASC-Monitoring",
          "Deploy-MCSB2-Monitoring",
          "Deploy-MDEndpoints",
          "Deploy-MDEndpointsAMA"
          ] : !contains(
          yamldecode(file("${path.module}/lib/archetype_definitions/root_custom.alz_archetype_override.yaml")).policy_assignments_to_remove,
          name
        )
      ]) &&
      alltrue([
        for archetype in ["platform", "landing_zones"] : alltrue([
          for name in [
            "Deploy-MDFC-DefSQL-AMA",
            "Deploy-VM-ChangeTrack",
            "Deploy-VM-Monitoring",
            "Deploy-vmArc-ChangeTrack",
            "Deploy-vmHybr-Monitoring",
            "Deploy-VMSS-ChangeTrack",
            "Deploy-VMSS-Monitoring"
            ] : contains(
            yamldecode(file("${path.module}/lib/archetype_definitions/${archetype}_custom.alz_archetype_override.yaml")).policy_assignments_to_remove,
            name
          )
        ])
      ]) &&
      contains(
        yamldecode(file("${path.module}/lib/archetype_definitions/landing_zones_custom.alz_archetype_override.yaml")).policy_assignments_to_remove,
        "Deploy-AzSqlDb-Auditing"
      ) &&
      !contains(
        keys(try(local.policy_assignments_to_modify.salz.policy_assignments, {})),
        "Deploy-MDFC-Config-H224"
      )
    )
    error_message = "Archetypes must exclude workspace/AMA-dependent deployments, preserve independent security benchmarks and endpoint protection, and not modify the removed Defender configuration assignment."
  }
}
