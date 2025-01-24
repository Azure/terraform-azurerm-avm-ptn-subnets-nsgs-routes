# Default example

This deploys the module illustrating using NSGs with multiple vnets.

```terraform
subnets = {
  snet0 = {
    name             = "${module.naming.subnet.name_unique}0"
    address_prefixes = ["10.0.0.0/24"]
    route_table = {
      id = azurerm_route_table.this.id
    }
  },
}
```

If you want the module to create the route table and associate it, this is done like so:

```terraform
route_tables = {
  rt0 = {
    name = "${module.naming.route_table.name_unique}-created"
    routes = {
      address_prefix = "1.2.3.4/24"
      name           = "${module.naming.route.name_unique}-created"
      next_hop_type  = "Internet"
    }
  }
}
subnets = {
  snet0 = {
    name             = "${module.naming.subnet.name_unique}1"
    address_prefixes = ["10.0.1.0/24"]
    # the route table is referenced by its map key.
    route_table_key = "rt0"
  }
}
```

The same approach applies to network security groups.
