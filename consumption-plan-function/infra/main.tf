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

resource "azurerm_storage_account" "function_storage" {
  name                     = substr("${local.storage_name_prefix}storage",0,24)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
    tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_storage_container" "storage_container" {
  name                 = "${local.prefix}storagecontainer"
  storage_account_name = azurerm_storage_account.function_storage.name
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${local.prefix}-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_application_insights" "insights" {
  name                = "${local.prefix}-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "Node.JS"

  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_linux_function_app" "function" {
  name                = "${local.prefix}-function"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.func_service_plan.id

  site_config {
    application_stack {
      node_version = 20
    }

    # Y1の場合falseしか指定できない
    always_on = false

    application_insights_connection_string = azurerm_application_insights.insights.connection_string
  }

  app_settings = {
    "STORAGE_ACCOUNT_CONNECTION_STRING" = azurerm_storage_account.function_storage.primary_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_service_plan" "func_service_plan" {
  name                = "${local.prefix}-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags = {
    environment = "dev"
    source = "terraform"
  }
}

data "azurerm_function_app_host_keys" "example" {
  name                = azurerm_linux_function_app.function.name
  resource_group_name = azurerm_linux_function_app.function.resource_group_name
}

output "default_function_key" {
  value     = data.azurerm_function_app_host_keys.example.default_function_key
  sensitive = true
}

