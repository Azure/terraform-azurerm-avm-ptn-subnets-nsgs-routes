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

resource "azurerm_route_table" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.route_table.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "this" {
  address_prefix      = "10.0.0.0/16"
  name                = module.naming.route.name_unique
  next_hop_type       = "VnetLocal"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
}

locals {
  network_security_groups = {
    nsg0 = {
      name = module.naming.network_security_group.name_unique
      security_rules = {
        "http_inbound" = {
          "access"                     = "Allow"
          "name"                       = "httpInbound"
          "direction"                  = "Inbound"
          "priority"                   = 150
          "protocol"                   = "Tcp"
          "source_address_prefix"      = "*"
          "source_port_range"          = "*"
          "destination_address_prefix" = "*"
          "destination_port_ranges"    = [80, 443]
        }
      }
    }
  }
  route_tables = {
    rt0 = {
      name = "${module.naming.route_table.name_unique}-created"
      routes = {
        r0 = {
          address_prefix = "1.2.3.4/24"
          name           = "${module.naming.route.name_unique}-created"
          next_hop_type  = "Internet"
        }
      }
    }
  }
  subnets = {
    snet0 = {
      name             = "${module.naming.subnet.name_unique}0"
      address_prefixes = ["10.0.0.0/24"]
      route_table = {
        id = azurerm_route_table.this.id
      }
    },
    snet1 = {
      name             = "${module.naming.subnet.name_unique}1"
      address_prefixes = ["10.0.1.0/24"]
      network_security_group = {
        key = "nsg0"
      }
      route_table = {
        key = "rt0"
      }
    },
    snet2 = {
      name             = "${module.naming.subnet.name_unique}2"
      address_prefixes = ["10.0.2.0/24"]
      delegation = [{
        name = "Microsoft.Web.serverFarms"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }
  }
}

# This is the module call
module "test" {
  source = "../../"
  # source                      = "Azure/avm-ptn-subnets/azurerm"
  # version                     = "..."
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  virtual_network_resource_id = azurerm_virtual_network.this.id

  network_security_groups = local.network_security_groups
  route_tables            = local.route_tables
  subnets                 = local.subnets

}
