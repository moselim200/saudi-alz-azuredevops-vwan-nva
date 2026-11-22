mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

override_module {
  target = module.regions
  outputs = {
    regions_by_name_or_display_name = {
      saudiarabiaeast = {
        name     = "saudiarabiaeast"
        geo_code = null
      }
      "Saudi Arabia East" = {
        name     = "saudiarabiaeast"
        geo_code = null
      }
      eastus = {
        name     = "eastus"
        geo_code = "eus"
      }
    }
  }
}

variables {
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/dns"
  enable_telemetry = false
  private_link_private_dns_zones = {
    azure_backup = {
      zone_name = "privatelink.{regionCode}.backup.windowsazure.com"
    }
    azure_storage_blob = {
      zone_name = "privatelink.blob.core.windows.net"
    }
    azure_kubernetes_service_management = {
      zone_name = "privatelink.{regionName}.azmk8s.io"
    }
  }
}

run "saudi_backup_zone_uses_confirmed_geo_code" {
  command = plan

  variables {
    location = "saudiarabiaeast"
  }

  assert {
    condition     = local.private_link_private_dns_zones_final.azure_backup.zone_name == "privatelink.sae.backup.windowsazure.com"
    error_message = "Saudi Arabia East must resolve the Backup zone even when upstream geo_code is null."
  }

  assert {
    condition = (
      local.private_link_private_dns_zones_final.azure_storage_blob.zone_name == "privatelink.blob.core.windows.net" &&
      local.private_link_private_dns_zones_final.azure_kubernetes_service_management.zone_name == "privatelink.saudiarabiaeast.azmk8s.io"
    )
    error_message = "The Saudi geo-code fix must retain global and region-name DNS zones."
  }
}

run "saudi_display_name_is_supported" {
  command = plan

  variables {
    location = "Saudi Arabia East"
  }

  assert {
    condition     = local.private_link_private_dns_zones_final.azure_backup.zone_name == "privatelink.sae.backup.windowsazure.com"
    error_message = "Display-name input must use the same confirmed Backup zone."
  }
}

run "existing_region_mapping_is_preserved" {
  command = plan

  variables {
    location = "eastus"
  }

  assert {
    condition     = local.private_link_private_dns_zones_final.azure_backup.zone_name == "privatelink.eus.backup.windowsazure.com"
    error_message = "Regions other than Saudi Arabia East must retain the upstream geo code."
  }
}
