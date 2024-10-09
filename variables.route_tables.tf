
variable "route_tables" {
  type = map(object({
    disable_bgp_route_propagation = optional(bool)
    name                          = string
    tags                          = optional(map(string))
    route = optional(map(object({
      address_prefix         = string
      name                   = string
      next_hop_in_ip_address = string
      next_hop_type          = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  description = <<-DESCRIPTION

- `disable_bgp_route_propagation` - (Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable.
- `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
- `name` - (Required) The name of the route table. Changing this forces a new resource to be created.
- `resource_group_name` - (Required) The name of the resource group in which to create the route table. Changing this forces a new resource to be created.
- `tags` - (Optional) A mapping of tags to assign to the resource.

---
`route` block supports the following:

- `address_prefix` - (Required) The destination to which the route applies. Can be CIDR (such as `10.1.0.0/16`) or [Azure Service Tag](https://docs.microsoft.com/azure/virtual-network/service-tags-overview) (such as `ApiManagement`, `AzureBackup` or `AzureMonitor`) format.
- `name` - (Required) The name of the route table. Changing this forces a new resource to be created.
- `next_hop_in_ip_address` - (Optional) Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.
- `next_hop_type` - (Required) The type of Azure hop the packet should be sent to. Possible values are `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.

---
`timeouts` block supports the following:

- `create` - (Defaults to 30 minutes) Used when creating the Route Table.
- `delete` - (Defaults to 30 minutes) Used when deleting the Route Table.
- `read` - (Defaults to 5 minutes) Used when retrieving the Route Table.
- `update` - (Defaults to 30 minutes) Used when updating the Route Table.

DESCRIPTION
  default     = {}
  nullable    = false
}
