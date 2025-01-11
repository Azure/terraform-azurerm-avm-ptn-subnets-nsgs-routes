<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-ptn-subnets-nsgs-routes

This is a Terraform Azure Verified Pattern Module for creating subnets with network security group & route tables either created inline or passed in by resource ID.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.6)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71, < 5.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_virtual_network_resource_id"></a> [virtual\_network\_resource\_id](#input\_virtual\_network\_resource\_id)

Description: The virtual network resource ID where the subnets, and optional NSGs and route tables, will be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  Required if supplying NSGs or route tables.

Type: `string`

Default: `null`

### <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups)

Description:
- `name` - (Required) Specifies the name of the network security group. Changing this forces a new resource to be created.
- `resource_group_name` - (Required) The name of the resource group in which to create the network security group. Changing this forces a new resource to be created.
- `tags` - (Optional) A mapping of tags to assign to the resource.

---
`security_rule` block supports the following:

- `access` - (Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
- `description` - (Optional) A description for this rule. Restricted to 140 characters.
- `destination_address_prefix` - (Optional) CIDR or destination IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. This is required if `destination_address_prefixes` is not specified.
- `destination_address_prefixes` - (Optional) List of destination address prefixes. Tags may not be used. This is required if `destination_address_prefix` is not specified.
- `destination_application_security_group_ids` - (Optional) A List of destination Application Security Group IDs
- `destination_port_range` - (Optional) Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `destination_port_ranges` is not specified.
- `destination_port_ranges` - (Optional) List of destination ports or port ranges. This is required if `destination_port_range` is not specified.
- `direction` - (Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
- `name` - (Required) Specifies the name of the network security group. Changing this forces a new resource to be created.
- `priority` - (Required) Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.
- `protocol` - (Required) Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*` (which matches all).
- `source_address_prefix` - (Optional) CIDR or source IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. This is required if `source_address_prefixes` is not specified.
- `source_address_prefixes` - (Optional) List of source address prefixes. Tags may not be used. This is required if `source_address_prefix` is not specified.
- `source_application_security_group_ids` - (Optional) A List of source Application Security Group IDs
- `source_port_range` - (Optional) Source Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `source_port_ranges` is not specified.
- `source_port_ranges` - (Optional) List of source ports or port ranges. This is required if `source_port_range` is not specified.

---
`timeouts` block supports the following:

- `create` - (Defaults to 30 minutes) Used when creating the Network Security Group.
- `delete` - (Defaults to 30 minutes) Used when deleting the Network Security Group.
- `read` - (Defaults to 5 minutes) Used when retrieving the Network Security Group.
- `update` - (Defaults to 30 minutes) Used when updating the Network Security Group.

Type:

```hcl
map(object({
    name = string
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {}),
    tags = optional(map(string))
    security_rules = optional(map(object({
      access                                     = string
      description                                = optional(string)
      destination_address_prefix                 = optional(string)
      destination_address_prefixes               = optional(set(string))
      destination_application_security_group_ids = optional(set(string))
      destination_port_range                     = optional(string)
      destination_port_ranges                    = optional(set(string))
      direction                                  = string
      name                                       = string
      priority                                   = number
      protocol                                   = string
      source_address_prefix                      = optional(string)
      source_address_prefixes                    = optional(set(string))
      source_application_security_group_ids      = optional(set(string))
      source_port_range                          = optional(string)
      source_port_ranges                         = optional(set(string))
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.  Required if supplying NSGs or route tables.

Type: `string`

Default: `null`

### <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables)

Description:
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

Type:

```hcl
map(object({
    disable_bgp_route_propagation = optional(bool)
    name                          = string
    tags                          = optional(map(string))
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {}),
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
```

Default: `{}`

### <a name="input_subnets"></a> [subnets](#input\_subnets)

Description: A map of subnets to create

- `address_prefixes` - (Required) The address prefixes to use for the subnet.
- `default_outbound_access_enabled` - (Optional) Whether to allow default outbound access from the subnet. Defaults to `false`.
- `enforce_private_link_endpoint_network_policies` -
- `enforce_private_link_service_network_policies` -
- `name` - (Required) The name of the subnet. Changing this forces a new resource to be created.
- `private_endpoint_network_policies` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Enabled`.
- `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will **Enable** the policy and setting this to `false` will **Disable** the policy. Defaults to `true`.
- `resource_group_name` - (Required) The name of the resource group in which to create the subnet. This must be the resource group that the virtual network resides in. Changing this forces a new resource to be created.
- `service_endpoint_policy_ids` - (Optional) The list of IDs of Service Endpoint Policies to associate with the subnet.
- `service_endpoints` - (Optional) The list of Service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage`, `Microsoft.Storage.Global` and `Microsoft.Web`.
- `virtual_network_name` - (Required) The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created.

---
`delegation` block supports the following:

- `name` - (Required) A name for this delegation.

---
`nat_gateway` block supports the following:

- `id` - (Optional) The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.

---
`network_security_group` block supports the following:

- `id` - (Optional) The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.

---
`route_table` block supports the following:

- `id` - (Optional) The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.

---
`service_delegation` block supports the following:

- `actions` - (Optional) A list of Actions which should be delegated. This list is specific to the service to delegate to. Possible values are `Microsoft.Network/networkinterfaces/*`, `Microsoft.Network/publicIPAddresses/join/action`, `Microsoft.Network/publicIPAddresses/read`, `Microsoft.Network/virtualNetworks/read`, `Microsoft.Network/virtualNetworks/subnets/action`, `Microsoft.Network/virtualNetworks/subnets/join/action`, `Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action`, and `Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action`.
- `name` - (Required) The name of service to delegate to. Possible values are `GitHub.Network/networkSettings`, `Microsoft.ApiManagement/service`, `Microsoft.Apollo/npu`, `Microsoft.App/environments`, `Microsoft.App/testClients`, `Microsoft.AVS/PrivateClouds`, `Microsoft.AzureCosmosDB/clusters`, `Microsoft.BareMetal/AzureHostedService`, `Microsoft.BareMetal/AzureHPC`, `Microsoft.BareMetal/AzurePaymentHSM`, `Microsoft.BareMetal/AzureVMware`, `Microsoft.BareMetal/CrayServers`, `Microsoft.BareMetal/MonitoringServers`, `Microsoft.Batch/batchAccounts`, `Microsoft.CloudTest/hostedpools`, `Microsoft.CloudTest/images`, `Microsoft.CloudTest/pools`, `Microsoft.Codespaces/plans`, `Microsoft.ContainerInstance/containerGroups`, `Microsoft.ContainerService/managedClusters`, `Microsoft.ContainerService/TestClients`, `Microsoft.Databricks/workspaces`, `Microsoft.DBforMySQL/flexibleServers`, `Microsoft.DBforMySQL/servers`, `Microsoft.DBforMySQL/serversv2`, `Microsoft.DBforPostgreSQL/flexibleServers`, `Microsoft.DBforPostgreSQL/serversv2`, `Microsoft.DBforPostgreSQL/singleServers`, `Microsoft.DelegatedNetwork/controller`, `Microsoft.DevCenter/networkConnection`, `Microsoft.DocumentDB/cassandraClusters`, `Microsoft.Fidalgo/networkSettings`, `Microsoft.HardwareSecurityModules/dedicatedHSMs`, `Microsoft.Kusto/clusters`, `Microsoft.LabServices/labplans`, `Microsoft.Logic/integrationServiceEnvironments`, `Microsoft.MachineLearningServices/workspaces`, `Microsoft.Netapp/volumes`, `Microsoft.Network/dnsResolvers`, `Microsoft.Network/managedResolvers`, `Microsoft.Network/fpgaNetworkInterfaces`, `Microsoft.Network/networkWatchers.`, `Microsoft.Network/virtualNetworkGateways`, `Microsoft.Orbital/orbitalGateways`, `Microsoft.PowerPlatform/enterprisePolicies`, `Microsoft.PowerPlatform/vnetaccesslinks`, `Microsoft.ServiceFabricMesh/networks`, `Microsoft.ServiceNetworking/trafficControllers`, `Microsoft.Singularity/accounts/networks`, `Microsoft.Singularity/accounts/npu`, `Microsoft.Sql/managedInstances`, `Microsoft.Sql/managedInstancesOnebox`, `Microsoft.Sql/managedInstancesStage`, `Microsoft.Sql/managedInstancesTest`, `Microsoft.Sql/servers`, `Microsoft.StoragePool/diskPools`, `Microsoft.StreamAnalytics/streamingJobs`, `Microsoft.Synapse/workspaces`, `Microsoft.Web/hostingEnvironments`, `Microsoft.Web/serverFarms`, `NGINX.NGINXPLUS/nginxDeployments`, `PaloAltoNetworks.Cloudngfw/firewalls`, `Qumulo.Storage/fileSystems`, and `Oracle.Database/networkAttachments`.

---
`timeouts` block supports the following:

- `create` - (Defaults to 30 minutes) Used when creating the Subnet.
- `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
- `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
- `update` - (Defaults to 30 minutes) Used when updating the Subnet.

Type:

```hcl
map(object({
    address_prefixes                = list(string)
    name                            = string
    default_outbound_access_enabled = optional(bool, false)
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id  = optional(string)
      key = optional(string)
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id  = optional(string)
      key = optional(string)
    }))
    service_endpoint_policy_ids = optional(set(string))
    service_endpoints           = optional(set(string))
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_network_security_groups"></a> [network\_security\_groups](#output\_network\_security\_groups)

Description: A map of all network security groups created.

### <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables)

Description: A map of all route tables created.

### <a name="output_subnets"></a> [subnets](#output\_subnets)

Description: A map of all subnets created.

## Modules

The following Modules are called:

### <a name="module_network_security_groups"></a> [network\_security\_groups](#module\_network\_security\_groups)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.2.0

### <a name="module_route_tables"></a> [route\_tables](#module\_route\_tables)

Source: Azure/avm-res-network-routetable/azurerm

Version: 0.3.1

### <a name="module_subnets"></a> [subnets](#module\_subnets)

Source: Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet

Version: 0.2.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->