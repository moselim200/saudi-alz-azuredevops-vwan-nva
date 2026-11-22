/*
--- Built-in Replacements ---
This file contains built-in replacements to avoid repeating the same hard-coded values.
Replacements are denoted by the dollar-dollar curly braces token (e.g. $${starter_location_01}). The following details each built-in replacements that you can use:
`starter_location_01`: This the primary an Azure location sourced from the `starter_locations` variable. This can be used to set the location of resources.
`starter_location_02` to `starter_location_##`: These are the secondary Azure locations sourced from the `starter_locations` variable. This can be used to set the location of resources.
`starter_location_01_short`: Short code for the primary Azure location. Defaults to the region geo_code, or short_name if no geo_code is available. Can be overridden via the starter_locations_short variable.
`starter_location_02_short` to `starter_location_##_short`: Short codes for the secondary Azure locations. Same behavior and override rules as starter_location_01_short.
`root_parent_management_group_id`: This is the id of the management group that the ALZ hierarchy will be nested under.
`subscription_id_identity`: The subscription ID of the subscription to deploy the identity resources to, sourced from the variable `subscription_ids`.
`subscription_id_connectivity`: The subscription ID of the subscription to deploy the connectivity resources to, sourced from the variable `subscription_ids`.
`subscription_id_management`: The subscription ID of the subscription to deploy the management resources to, sourced from the variable `subscription_ids`.
`subscription_id_security`: The subscription ID of the subscription to deploy the security resources to, sourced from the variable `subscription_ids`.
*/

# CUSTOMER INPUT: Review the marked literal values for the customer's design before bootstrap planning.
# Keep $${...} replacement tokens: tenant/subscription selections come from inputs.yaml.
# SAUDI TEST notes describe the reduced regional profile, not options to remove without revalidation.
# PRE-BOOTSTRAP CHECK: Run terraform fmt after all edits, including comment-only customer annotations.
/*
--- Starter Locations ---
You can define the Azure regions to use throughout the configuration.
The first location will be used as the primary location, the second as the secondary location, and so on.
*/
# CUSTOMER INPUT (review): Confirm access/service availability in this Saudi workload region.
# Adding or changing regions requires reviewing the module/DNS mappings and policy design too.
# SAUDI TEST: Keep workload resources in Saudi Arabia East; policy identity placement is separate.
starter_locations = ["saudiarabiaeast"]

/*
--- Custom Replacements ---
You can define custom replacements to use throughout the configuration.
*/
custom_replacements = {
  /*
  --- Custom Name Replacements ---
  You can define custom names and other strings to use throughout the configuration.
  You can only use the built in replacements in this section.
  NOTE: You cannot refer to another custom name in this variable.
  */
  names = {
    # Defender email security contact
    # CUSTOMER INPUT: Replace with the customer's monitored security mailbox before enabling contact policies.
    # This value alone does not configure a contact while the related Defender policy is excluded.
    defender_email_security_contact = "replace_me@replace_me.com"

    # Resource group names
    # CUSTOMER INPUT (review): Adapt these platform names to the customer's naming standard.
    # Bootstrap service_name/environment_name do not automatically change the names in this file.
    management_resource_group_name               = "rg-management-$${starter_location_01}"
    connectivity_hub_vwan_resource_group_name    = "rg-hub-vwan-$${starter_location_01}"
    connectivity_hub_primary_resource_group_name = "rg-hub-$${starter_location_01}"
    dns_resource_group_name                      = "rg-hub-dns-$${starter_location_01}"
    ddos_resource_group_name                     = "rg-hub-ddos-$${starter_location_01}"
    asc_export_resource_group_name               = "rg-asc-export-$${starter_location_01}"
    service_health_alerts_resource_group_name    = "rg-service-health-alerts-$${starter_location_01}"

    # Resource names
    # CUSTOMER INPUT (review): Apply the customer's resource naming standard and check name availability.
    # Names for disabled monitoring/DDoS resources are retained but do not enable those resources.
    log_analytics_workspace_name            = "law-management-$${starter_location_01}"
    ddos_protection_plan_name               = "ddos-$${starter_location_01}"
    ama_user_assigned_managed_identity_name = "uami-management-ama-$${starter_location_01}"
    dcr_change_tracking_name                = "dcr-change-tracking"
    dcr_defender_sql_name                   = "dcr-defender-sql"
    dcr_vm_insights_name                    = "dcr-vm-insights"

    # Resource provisioning global connectivity
    # CUSTOMER INPUT (design approval): Agree the DDoS/gateway omissions and the reduced security baseline.
    # Re-enabling a service also requires revisiting its regional support and related policy exclusions.
    # SAUDI TEST: DDoS and gateways below are lab exclusions, not regional availability findings.
    ddos_protection_plan_enabled = false

    # Resource provisioning primary connectivity
    # SAUDI TEST: Azure rejected Resolver here; retain the independently supported DNS zones and links.
    primary_virtual_network_gateway_express_route_enabled = false
    primary_virtual_network_gateway_vpn_enabled           = false
    primary_private_dns_zones_enabled                     = true
    primary_private_dns_auto_registration_zone_enabled    = true
    primary_private_dns_resolver_enabled                  = false
    # CUSTOMER INPUT (review): Confirm Bastion/public-IP requirements and the need for a sidecar VNet.
    primary_bastion_enabled                 = true
    primary_sidecar_virtual_network_enabled = true

    # Resource names primary connectivity
    # CUSTOMER INPUT (review): Use customer-approved hub, VNet, subnet, gateway and Bastion names.
    primary_hub_name                                   = "vwan-hub-$${starter_location_01}"
    primary_sidecar_virtual_network_name               = "vnet-sidecar-$${starter_location_01}"
    primary_subnet_nva_name                            = "subnet-nva-$${starter_location_01}"
    primary_virtual_network_gateway_express_route_name = "vgw-hub-er-$${starter_location_01}"
    primary_virtual_network_gateway_vpn_name           = "vgw-hub-vpn-$${starter_location_01}"
    primary_private_dns_resolver_name                  = "pdr-hub-dns-$${starter_location_01}"
    primary_bastion_host_name                          = "bas-hub-$${starter_location_01}"
    primary_bastion_host_public_ip_name                = "pip-bastion-hub-$${starter_location_01}"

    # Private DNS Zones primary
    # CUSTOMER INPUT: Select the customer's approved private DNS namespace and check existing DNS use.
    primary_auto_registration_zone_name = "$${starter_location_01}.customer.internal"

    # IP Ranges Primary
    # CUSTOMER INPUT (required): Replace these example ranges with the customer's IPAM-approved allocation.
    # Avoid overlaps across the hub, sidecar, spokes, peered VNets, on-premises and bootstrap networking.
    # All sidecar subnets must fit inside the sidecar VNet and must not overlap one another.
    # The /16 below is a planning note, not a separate deployed network.
    # Regional Address Space: 10.0.0.0/16
    # CUSTOMER INPUT: Virtual WAN hub range; size it for the customer's scale and Azure hub requirements.
    primary_hub_address_space = "10.0.0.0/22"
    # CUSTOMER INPUT: Sidecar VNet range, separate from the Virtual WAN hub range.
    primary_sidecar_virtual_network_address_space = "10.0.4.0/22"
    # CUSTOMER INPUT: Bastion range inside the sidecar VNet; new Bastion deployments require /26 or larger.
    primary_bastion_subnet_address_prefix = "10.0.4.0/26"
    # CUSTOMER INPUT: Appliance subnet inside the sidecar VNet; match the customer's NVA capacity needs.
    primary_nva_subnet_address_prefix = "10.0.4.64/26"
    # CUSTOMER INPUT: Reserve a usable IP within the NVA subnet, excluding Azure-reserved addresses.
    # This replacement value alone does not deploy an NVA or configure appliance routing.
    primary_nva_ip_address = "10.0.4.68"
    # CUSTOMER INPUT: Reserved Resolver subnet example; unused while Resolver is disabled.
    # Validate its service/subnet requirements before enabling Resolver.
    primary_private_dns_resolver_subnet_address_prefix = "10.0.4.128/28"
  }

  /*
  --- Custom Resource Group Identifier Replacements ---
  You can define custom resource group identifiers to use throughout the configuration.
  You can only use the templated variables and custom names in this section.
  NOTE: You cannot refer to another custom resource group identifier in this variable.
  */
  # CUSTOMER INPUT: Normally retain these generated identifier templates; change the names above.
  # Subscription replacements are populated from inputs.yaml, not from copied lab resource IDs.
  resource_group_identifiers = {
    management_resource_group_id           = "/subscriptions/$${subscription_id_management}/resourcegroups/$${management_resource_group_name}"
    ddos_protection_plan_resource_group_id = "/subscriptions/$${subscription_id_connectivity}/resourcegroups/$${ddos_resource_group_name}"
    primary_connectivity_resource_group_id = "/subscriptions/$${subscription_id_connectivity}/resourceGroups/$${connectivity_hub_primary_resource_group_name}"
    dns_resource_group_id                  = "/subscriptions/$${subscription_id_connectivity}/resourceGroups/$${dns_resource_group_name}"
  }

  /*
  --- Custom Resource Identifier Replacements ---
  You can define custom resource identifiers to use throughout the configuration.
  You can only use the templated variables, custom names and customer resource group identifiers in this variable.
  NOTE: You cannot refer to another custom resource identifier in this variable.
  */
  resource_identifiers = {
    ama_change_tracking_data_collection_rule_id = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_change_tracking_name}"
    ama_mdfc_sql_data_collection_rule_id        = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_defender_sql_name}"
    ama_vm_insights_data_collection_rule_id     = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_vm_insights_name}"
    ama_user_assigned_managed_identity_id       = "$${management_resource_group_id}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$${ama_user_assigned_managed_identity_name}"
    log_analytics_workspace_id                  = "$${management_resource_group_id}/providers/Microsoft.OperationalInsights/workspaces/$${log_analytics_workspace_name}"
    ddos_protection_plan_id                     = "$${ddos_protection_plan_resource_group_id}/providers/Microsoft.Network/ddosProtectionPlans/$${ddos_protection_plan_name}"
  }
}

/*
--- Tags ---
This variable can be used to apply tags to all resources that support it. Some resources allow overriding these tags.
*/
# CUSTOMER INPUT (review): Add customer-required cost, ownership, environment and classification tags.
# Use the customer's approved tag keys/values; avoid putting secrets in tags.
tags = {
  deployed_by = "terraform"
  source      = "Azure Landing Zones Accelerator"
}

/*
--- Management Resources ---
You can use this section to customize the management resources that will be deployed.
*/
# CUSTOMER INPUT (design approval): Agree the missing monitoring coverage and the customer's replacement plan.
# Do not enable this module without revisiting regional availability and the excluded monitoring policies.
# SAUDI TEST: Azure rejected Saudi Log Analytics; omit its dependent monitoring module too.
management_resources_enabled = false

management_resource_settings = {
  location                     = "$${starter_location_01}"
  log_analytics_workspace_name = "$${log_analytics_workspace_name}"
  resource_group_name          = "$${management_resource_group_name}"
  user_assigned_managed_identities = {
    ama = {
      name = "$${ama_user_assigned_managed_identity_name}"
    }
  }
  data_collection_rules = {
    change_tracking = {
      name = "$${dcr_change_tracking_name}"
    }
    defender_sql = {
      name = "$${dcr_defender_sql_name}"
    }
    vm_insights = {
      name = "$${dcr_vm_insights_name}"
    }
  }
}

/*
--- Management Groups and Policy ---
You can use this section to customize the management groups and policies that will be deployed.
You can further configure management groups and policy by supplying a `lib` folder. This is detailed in the Accelerator documentation.
*/
management_groups_enabled = true

management_group_settings = {
  # This is the name of the architecture that will be used to deploy the management resources.
  # It refers to the alz_custom.alz_architecture_definition.yaml file in the lib folder.
  # Do not change this value unless you have created another architecture definition
  # with the name value specified below.
  # CUSTOMER INPUT: If supplying a renamed architecture, update this and the library architecture name together.
  architecture_name = "alz_custom"
  # CUSTOMER INPUT (approval required): Obtain explicit approval for policy identities outside Saudi Arabia.
  # This is not the workload resource region; do not change it back without resolving the identity failure.
  # SAUDI TEST: Saudi policy identity creation failed; UAE North is the approved identity-only exception.
  location           = "uaenorth"
  parent_resource_id = "$${root_parent_management_group_id}"
  policy_default_values = {
    # SAUDI TEST: Omit workspace/AMA IDs; explicitly keep policy-deployed resources in Saudi.
    ddos_protection_plan_id                   = "$${ddos_protection_plan_id}"
    private_dns_zone_subscription_id          = "$${subscription_id_connectivity}"
    private_dns_zone_region                   = "$${starter_location_01}"
    private_dns_zone_resource_group_name      = "$${dns_resource_group_name}"
    resource_group_name_service_health_alerts = "$${service_health_alerts_resource_group_name}"
    resource_group_location                   = "$${starter_location_01}"
    /*
    # Example of allowed locations for Sovereign Landing Zones policies
    allowed_locations = [
      "$${starter_location_01}"
    ]
    */
  }
  # CUSTOMER INPUT (review): Each target name must match an id in the supplied architecture definition.
  # The subscription IDs themselves come from the customer mapping in inputs.yaml.
  subscription_placement = {
    identity = {
      subscription_id       = "$${subscription_id_identity}"
      management_group_name = "identity"
    }
    connectivity = {
      subscription_id       = "$${subscription_id_connectivity}"
      management_group_name = "connectivity"
    }
    management = {
      subscription_id       = "$${subscription_id_management}"
      management_group_name = "management"
    }
    security = {
      subscription_id       = "$${subscription_id_security}"
      management_group_name = "security"
    }
  }
  policy_assignments_to_modify = {
    # CUSTOMER INPUT: If renaming the corp management-group ID, rename this key to match as well.
    corp = {
      policy_assignments = {
        Deploy-Private-DNS-Zones = {
          parameters = {
            # SAUDI TEST: Azure confirmed the Backup DNS geo code; this replaces the whole region map.
            dnzZoneRegionShortNames = {
              saudiarabiaeast = "sae"
            }
          }
        }
      }
    }
  }
  /*
  # Example of how to add management group role assignments
  # CUSTOMER INPUT (conditional): Use least-privilege roles and real customer Entra principal object IDs.
  # A principal object ID is not a subscription ID or an application's client ID.
  management_group_role_assignments = {
    root_owner_role_assignment = {
      management_group_name      = "root"
      role_definition_id_or_name = "Owner"
      principal_id               = "00000000-0000-0000-0000-000000000000"
    }
  }
  */
  # role_assignment_name_use_random_uuid = false  # Uncomment this for backwards compatibility with previous naming convention
}

/*
--- Connectivity - Virtual WAN ---
You can use this section to customize the virtual wan networking that will be deployed.
*/
# CUSTOMER INPUT (design review): This prepared profile is Virtual WAN; changing topology needs a new review.
connectivity_type = "virtual_wan"

connectivity_resource_groups = {
  ddos = {
    name     = "$${ddos_resource_group_name}"
    location = "$${starter_location_01}"
    settings = {
      enabled = "$${ddos_protection_plan_enabled}"
    }
  }
  vwan = {
    name     = "$${connectivity_hub_vwan_resource_group_name}"
    location = "$${starter_location_01}"
    settings = {
      enabled = true
    }
  }
  vwan_hub_primary = {
    name     = "$${connectivity_hub_primary_resource_group_name}"
    location = "$${starter_location_01}"
    settings = {
      enabled = true
    }
  }
  dns = {
    name     = "$${dns_resource_group_name}"
    location = "$${starter_location_01}"
    settings = {
      enabled = "$${primary_private_dns_zones_enabled}"
    }
  }
}

virtual_wan_settings = {
  enabled_resources = {
    ddos_protection_plan = "$${ddos_protection_plan_enabled}"
  }
  virtual_wan = {
    # CUSTOMER INPUT (review): This WAN name is a literal here, not a name replacement defined above.
    name                = "vwan-$${starter_location_01}"
    resource_group_name = "$${connectivity_hub_vwan_resource_group_name}"
    location            = "$${starter_location_01}"
  }
  ddos_protection_plan = {
    name                = "$${ddos_protection_plan_name}"
    resource_group_name = "$${ddos_resource_group_name}"
    location            = "$${starter_location_01}"
  }
}

virtual_hubs = {
  primary = {
    location = "$${starter_location_01}"
    /*
      NOTE: We are defaulting to a separate resource group for the hub per best practice for resiliency
      However, there is a known limitation with the portal experience: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-faq#can-hubs-be-created-in-different-resource-groups-in-virtual-wan
      If you prefer to use the same resource group as the vwan, then set this to `$${connectivity_hub_vwan_resource_group_name}`
    */
    default_parent_id = "$${primary_connectivity_resource_group_id}"
    enabled_resources = {
      # CUSTOMER INPUT (approval required): Record the customer's inspection/security design without Firewall.
      # SAUDI TEST: Keep Firewall disabled for this regional test; no substitute inspection is deployed.
      firewall                              = false
      bastion                               = "$${primary_bastion_enabled}"
      virtual_network_gateway_express_route = "$${primary_virtual_network_gateway_express_route_enabled}"
      virtual_network_gateway_vpn           = "$${primary_virtual_network_gateway_vpn_enabled}"
      private_dns_zones                     = "$${primary_private_dns_zones_enabled}"
      private_dns_resolver                  = "$${primary_private_dns_resolver_enabled}"
      sidecar_virtual_network               = "$${primary_sidecar_virtual_network_enabled}"
    }
    hub = {
      name           = "$${primary_hub_name}"
      address_prefix = "$${primary_hub_address_space}"
    }
    virtual_network_gateways = {
      express_route = {
        name = "$${primary_virtual_network_gateway_express_route_name}"
      }
      vpn = {
        name = "$${primary_virtual_network_gateway_vpn_name}"
      }
    }
    private_dns_zones = {
      parent_id = "$${dns_resource_group_id}"
      private_link_private_dns_zones_regex_filter = {
        enabled = false
      }
      auto_registration_zone_enabled = "$${primary_private_dns_auto_registration_zone_enabled}"
      auto_registration_zone_name    = "$${primary_auto_registration_zone_name}"
    }
    private_dns_resolver = {
      subnet_address_prefix = "$${primary_private_dns_resolver_subnet_address_prefix}"
      name                  = "$${primary_private_dns_resolver_name}"
    }
    # SAUDI TEST: Saudi zonal creation failed; the pinned module requires matching host/public-IP zones.
    bastion = {
      subnet_address_prefix = "$${primary_bastion_subnet_address_prefix}"
      name                  = "$${primary_bastion_host_name}"
      zones                 = []
      bastion_public_ip = {
        name  = "$${primary_bastion_host_public_ip_name}"
        zones = []
      }
    }
    sidecar_virtual_network = {
      name          = "$${primary_sidecar_virtual_network_name}"
      address_space = ["$${primary_sidecar_virtual_network_address_space}"]
      /*
      virtual_network_connection_settings = {
        name = "private_dns_vnet_primary"  # Backwards compatibility
      }
      */
      subnets = {
        nva = {
          name             = "$${primary_subnet_nva_name}"
          address_prefixes = ["$${primary_nva_subnet_address_prefix}"]
        }
      }
    }
  }
}

# private_link_private_dns_zone_virtual_network_link_moved_blocks_enabled = true

# CUSTOMER INPUT (review): Agree AVM telemetry participation with the customer's privacy requirements.
# Leave accelerator correlation metadata as generated; do not put credentials in additional content.
enable_telemetry = true
telemetry_additional_content = {
  deployed_by    = "alz-terraform-accelerator"
  correlation_id = "00000000-0000-0000-0000-000000000000"
}
