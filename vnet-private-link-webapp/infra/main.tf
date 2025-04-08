variable "namespace" {
  type = string
}

variable "project_name" {
  type = string
}

locals {
  prefix = "${var.namespace}-${var.project_name}"
  storage_name_prefix = lower(replace("${local.prefix}","/[^[:alnum:]]/", ""))
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

resource "azurerm_subnet" "integration_subnet" {
  name                 = "${local.prefix}-integration-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "${local.prefix}-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  private_endpoint_network_policies             = "Enabled"

}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${local.prefix}-app_service_plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P0v3"
}



resource "azurerm_linux_web_app" "front_webapp" {
  name                = "${local.prefix}-front"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    "WEBSITE_DNS_SERVER" = "168.63.129.16",
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration_connection" {
  app_service_id  = azurerm_linux_web_app.front_webapp.id
  subnet_id       = azurerm_subnet.integration_subnet.id
}

resource "azurerm_linux_web_app" "backwebapp" {
  name                = "${local.prefix}-back"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.app_service_plan.id

  site_config {}
}

resource "azurerm_private_dns_zone" "dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name = "${local.prefix}-dnszonelink"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${local.prefix}-backwebappprivateendpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  }

  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_linux_web_app.backwebapp.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

