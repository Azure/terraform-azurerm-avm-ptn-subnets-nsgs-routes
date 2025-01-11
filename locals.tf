locals {
  subnets = {
    for sk, sv in var.subnets : sk => merge(
      sv,
      {
        network_security_group = try({
          id = module.network_security_groups[sv.network_security_group.key].resource_id
        }, sv.network_security_group, {}),
        route_table = try({
          id = module.route_tables[sv.route_table_key].resource_id
        }, sv.route_table, {})
      }
    )
  }
}
