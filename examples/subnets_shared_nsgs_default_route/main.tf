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
