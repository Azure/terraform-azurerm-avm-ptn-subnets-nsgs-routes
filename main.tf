module "subnets" {
  for_each = local.subnets

  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.2.3"

  virtual_network = {
    resource_id = var.virtual_network_resource_id
  }
  name             = each.value.name
  address_prefixes = each.value.address_prefixes

  default_outbound_access_enabled               = try(each.value.default_outbound_access_enabled, false)
  delegation                                    = try(each.value.delegation, null)
  nat_gateway                                   = try(each.value.nat_gateway, null)
  network_security_group                        = each.value.network_security_group
  private_endpoint_network_policies             = coalesce(each.value.private_endpoint_network_policies, "Enabled")
  private_link_service_network_policies_enabled = coalesce(each.value.private_link_service_network_policies_enabled, true)
  role_assignments                              = try(each.value.role_assignments, {})
  route_table                                   = each.value.route_table
  service_endpoint_policies                     = try(each.value.service_endpoint_policies, null)
  service_endpoints                             = try(each.value.service_endpoints, null)

  depends_on = [
    module.network_security_groups,
    module.route_tables,
  ]
}

module "network_security_groups" {
  for_each = var.network_security_groups

  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  resource_group_name = var.resource_group_name
  name                = each.value.name
  enable_telemetry    = var.enable_telemetry
  security_rules      = try(each.value.security_rules, {})
  location            = var.location
}

module "route_tables" {
  for_each = var.route_tables

  source                        = "Azure/avm-res-network-routetable/azurerm"
  version                       = "0.3.1"
  location                      = var.location
  name                          = each.value.name
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = try(!each.value.disable_bgp_route_propagation, true)
  enable_telemetry              = var.enable_telemetry
  tags                          = each.value.tags

  routes = try(each.value.routes, {})
}
