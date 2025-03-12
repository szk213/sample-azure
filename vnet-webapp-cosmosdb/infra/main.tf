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
    always_on = true

    application_insights_connection_string = azurerm_application_insights.insights.connection_string

    vnet_route_all_enabled = true
  }

  app_settings = {
    "STORAGE_ACCOUNT_CONNECTION_STRING" = azurerm_storage_account.function_storage.primary_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.ngw_subnet.id

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
  sku_name            = "P0v3" # 例: Premiumプランに変更
  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_public_ip" "ngw_ip" {
  name                = "${local.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_subnet" "ngw_subnet" {
  name                 = "${local.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.ngw_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints     = ["Microsoft.Storage", "Microsoft.Web"]

  delegation {
    name = "Delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_virtual_network" "ngw_vnet" {
  name                = "${local.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_nat_gateway" "ngw" {
  name                = "${local.prefix}-nat-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"

  tags = {
    environment = "dev"
    source = "terraform"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "ngw_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.ngw.id
  public_ip_address_id = azurerm_public_ip.ngw_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "ngw_subnet_nat_gateway" {
  subnet_id      = azurerm_subnet.ngw_subnet.id
  nat_gateway_id = azurerm_nat_gateway.ngw.id
}

# resource "azurerm_app_service_virtual_network_swift_connection" "default" {
#   app_service_id = azurerm_linux_function_app.function.id
#   subnet_id      = azurerm_subnet.ngw_subnet.id
# }

data "azurerm_function_app_host_keys" "example" {
  name                = azurerm_linux_function_app.function.name
  resource_group_name = azurerm_linux_function_app.function.resource_group_name
}

output "default_function_key" {
  value     = data.azurerm_function_app_host_keys.example.default_function_key
  sensitive = true
}

# CosmosDBアカウントの作成
resource "azurerm_cosmosdb_account" "db" {
  name                = "${local.prefix}-cosmosdb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }

  public_network_access_enabled = false
  is_virtual_network_filter_enabled = true

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# CosmosDBデータベースの作成
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "${local.prefix}-database"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

# CosmosDB用のサブネットを作成
resource "azurerm_subnet" "cosmos_subnet" {
  name                 = "${local.prefix}-cosmos-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.ngw_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  # 最新のAzure Terraformプロバイダーではこの設定は不要
  # Private Endpointはデフォルトで許可されています

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

# Private Endpointの作成
resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "${local.prefix}-cosmos-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.cosmos_subnet.id

  private_service_connection {
    name                           = "${local.prefix}-cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.db.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# Private DNS Zoneの作成
resource "azurerm_private_dns_zone" "cosmos_dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# Private DNS ZoneとVNetのリンク
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_dns_link" {
  name                  = "${local.prefix}-cosmos-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_dns.name
  virtual_network_id    = azurerm_virtual_network.ngw_vnet.id

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# Private DNS A Recordの作成
resource "azurerm_private_dns_a_record" "cosmos_dns_record" {
  name                = azurerm_cosmosdb_account.db.name
  zone_name           = azurerm_private_dns_zone.cosmos_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.cosmos_pe.private_service_connection[0].private_ip_address]
}
