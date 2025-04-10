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

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${local.prefix}-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${local.prefix}-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"

  tags = {
    environment = "dev"
    source      = "terraform"
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
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
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
    WEBSITE_DNS_SERVER = "168.63.129.16",
    APPINSIGHTS_INSTRUMENTATIONKEY =  azurerm_application_insights.app_insights.instrumentation_key,
    APPLICATIONINSIGHTS_CONNECTION_STRING =  azurerm_application_insights.app_insights.connection_string,
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}

resource "azurerm_linux_web_app" "back_webapp" {
  name                = "${local.prefix}-back"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.app_service_plan.id

  public_network_access_enabled = false
  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    WEBSITE_DNS_SERVER = "168.63.129.16",
    APPINSIGHTS_INSTRUMENTATIONKEY =  azurerm_application_insights.app_insights.instrumentation_key,
    APPLICATIONINSIGHTS_CONNECTION_STRING =  azurerm_application_insights.app_insights.connection_string,
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}

resource "azurerm_monitor_diagnostic_setting" "back_webapp_diagnostic" {
  name               = "${local.prefix}-back-webapp-diagnostic"
  target_resource_id = azurerm_linux_web_app.back_webapp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration_connection" {
  app_service_id  = azurerm_linux_web_app.back_webapp.id
  subnet_id       = azurerm_subnet.integration_subnet.id
}

resource "azurerm_private_dns_zone" "dns_privatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name = "${local.prefix}-dnszonelink"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_privatezone.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${local.prefix}-back-webapp-privateendpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_privatezone.id]
  }

  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_linux_web_app.back_webapp.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

resource "azurerm_linux_web_app_slot" "back_webapp_slot" {
  name                = "${local.prefix}-back-slot"

  app_service_id = azurerm_linux_web_app.back_webapp.id
  virtual_network_subnet_id = azurerm_subnet.integration_subnet.id
  public_network_access_enabled = false

  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    WEBSITE_DNS_SERVER = "168.63.129.16",
    APPINSIGHTS_INSTRUMENTATIONKEY =  azurerm_application_insights.app_insights.instrumentation_key,
    APPLICATIONINSIGHTS_CONNECTION_STRING =  azurerm_application_insights.app_insights.connection_string,
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}

resource "azurerm_monitor_diagnostic_setting" "back_webapp_slot_diagnostic" {
  name               = "${local.prefix}-back-webapp-diagnostic"
  target_resource_id = azurerm_linux_web_app_slot.back_webapp_slot.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_private_endpoint" "privateendpoint_slot" {
  name                = "${local.prefix}-back-webapp-privateendpoint-slot"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_privatezone.id]
  }

  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_linux_web_app.back_webapp.id
    subresource_names = ["sites-${azurerm_linux_web_app_slot.back_webapp_slot.name}"]
    is_manual_connection = false
  }
}

