provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "japaneast"
}

module "vnet" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]

  # サブネットの定義
  subnets = [
    {
      name    = "frontend"
      newbits = 8
      netnum  = 0
    },
    {
      name    = "backend"
      newbits = 8
      netnum  = 1
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    },
    {
      name    = "database"
      newbits = 8
      netnum  = 2
    },
    {
      name    = "appservice"
      newbits = 8
      netnum  = 3
      delegation = {
        name = "appservice-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

# 出力値
output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}

output "subnet_address_prefixes" {
  value = module.vnet.subnet_address_prefixes
}