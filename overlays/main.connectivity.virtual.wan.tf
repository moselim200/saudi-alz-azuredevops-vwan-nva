module "virtual_wan" {
  # SAUDI TEST: Select the local AVM root so DNS creation uses the confirmed Saudi geo mapping.
  source = "./modules/vendor/virtual-wan"

  count = local.connectivity_virtual_wan_enabled ? 1 : 0

  virtual_wan_settings = local.virtual_wan_settings
  virtual_hubs         = local.virtual_hubs
  route_maps           = local.route_maps
  ignore_body_changes  = module.config.outputs.ignore_body_changes
  enable_telemetry     = var.enable_telemetry
  tags                 = coalesce(module.config.outputs.connectivity_tags, module.config.outputs.tags)

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }
}
