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
  address_space       = ["10.1.0.0/16"]
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
  address_prefix      = "10.3.0.0/16"
  name                = module.naming.route.name_unique
  next_hop_type       = "VnetLocal"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
}

resource "azurerm_network_security_group" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    environment = "Demo"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "test123"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

locals {
  subnets = {
    snet0 = {
      name             = "${module.naming.subnet.name_unique}0"
      address_prefixes = ["10.1.0.0/24"]
      network_security_group = {
        id = azurerm_network_security_group.this.id
      }
      route_table = {
        id = azurerm_route_table.this.id
      }
    },
    snet1 = {
      name             = "${module.naming.subnet.name_unique}1"
      address_prefixes = ["10.1.1.0/24"]
      network_security_group = {
        id = azurerm_network_security_group.this.id
      }
    }
    snet2 = {
      name             = "${module.naming.subnet.name_unique}2"
      address_prefixes = ["10.1.2.0/24"]
      route_table = {
        id = azurerm_route_table.this.id
      }
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

  subnets = local.subnets

}
