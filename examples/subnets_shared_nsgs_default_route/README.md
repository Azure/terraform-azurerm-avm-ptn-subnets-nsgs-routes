<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module illustrating how to use NSG across mutiple subnets, with a pre-existing route table which defines the default route.

```hcl
terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_virtual_network" "this" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route_table" "default_route" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.route_table.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "default_route" {
  address_prefix         = "10.0.0.0/16"
  name                   = module.naming.route.name_unique
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.default_route.name
  next_hop_in_ip_address = "10.0.0.5"
}

locals {
  network_security_groups = {
    nsg0 = {
      name = "${module.naming.network_security_group.name_unique}0"
      security_rules = {
        "http_https_outbound" = {
          access                     = "Allow"
          name                       = "httphttpsOutbound"
          direction                  = "Outbound"
          priority                   = 150
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          source_port_range          = "*"
          destination_address_prefix = "*"
          destination_port_ranges    = [80, 443]
        },
        "deny_all_outbound" = {
          access                     = "Deny"
          direction                  = "Inbound"
          name                       = "deny_all_outbound"
          priority                   = 4096
          protocol                   = "Tcp"
          destination_address_prefix = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          source_port_range          = "*"
        }
      }
    }
    nsg1 = {
      name = "${module.naming.network_security_group.name_unique}1"
      security_rules = {
        "https_inbound" = {
          access                     = "Allow"
          name                       = "httpsInbound"
          direction                  = "Inbound"
          priority                   = 150
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          source_port_range          = "*"
          destination_address_prefix = "*"
          destination_port_range     = 443
        }
      }
    }
  }
  subnets = {
    snet0 = {
      name             = "${module.naming.subnet.name_unique}0"
      address_prefixes = ["10.0.0.0/24"]
      network_security_group = {
        key = "nsg0"
      }
      route_table = {
        id = azurerm_route_table.default_route.id
      }
    },
    snet1 = {
      name             = "${module.naming.subnet.name_unique}1"
      address_prefixes = ["10.0.1.0/24"]
      network_security_group = {
        key = "nsg0"
      }
      route_table = {
        id = azurerm_route_table.default_route.id
      }
    },
    snet2 = {
      name             = "${module.naming.subnet.name_unique}2"
      address_prefixes = ["10.0.2.0/24"]
      network_security_group = {
        key = "nsg1"
      }
      route_table = {
        id = azurerm_route_table.default_route.id
      }
    }
  }
}

module "this" {
  source = "../../"
  # source                      = "Azure/avm-ptn-subnets/azurerm"
  # version                     = "..."
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  virtual_network_resource_id = azurerm_virtual_network.this.id

  network_security_groups = local.network_security_groups
  subnets                 = local.subnets

  depends_on = [
    azurerm_route.default_route
  ]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.74)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_route.default_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) (resource)
- [azurerm_route_table.default_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: ~> 0.3

### <a name="module_this"></a> [this](#module\_this)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->