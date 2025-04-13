variable "namespace" {
  type = string
}

variable "project_name" {
  type = string
}


locals {
  prefix = "${var.namespace}-${var.project_name}"
  storage_name_prefix = lower(replace("${local.prefix}","/[^[:alnum:]]/", ""))
  env_config =  jsondecode(file("${path.module}/setting.json"))["network"]
  default_config = jsondecode(file("${path.module}/defaults.json"))["network"]

  route_tables = {
    for location_name, data in local.env_config:
      location_name =>
        {
          for key, value in data.route_tables : key => value
        }
  }

  security_groups = {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = "Japan East"
  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "storage_subnet" {
  name                 = "${local.prefix}-storage-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "${local.prefix}-db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

module "route_tables" {
  for_each = local.route_tables

  source = "./modules/route_table"

  config_list = {
    resource_group = azurerm_resource_group.rg
    subnets = {
      storage = azurerm_subnet.storage_subnet
      db = azurerm_subnet.db_subnet
    }
    route_tables = each.value
  }
}
