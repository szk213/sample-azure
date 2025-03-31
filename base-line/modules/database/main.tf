resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project}-${var.environment}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = var.sql_server.version
  administrator_login          = var.sql_server.administrator_login
  administrator_login_password = var.sql_server.administrator_login_password
  minimum_tls_version          = var.sql_server.minimum_tls_version

  public_network_access_enabled = false

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "azurerm_mssql_database" "sql_databases" {
  for_each = var.sql_databases

  name        = "sqldb-${var.project}-${each.key}-${var.environment}"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = each.value.sku_name
  max_size_gb = each.value.max_size_gb

  zone_redundant    = each.value.zone_redundant
  read_scale        = each.value.read_scale
  geo_backup_enabled = each.value.geo_backup_enabled

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# プライベートエンドポイントの作成
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "pe-sql-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "psc-sql-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# プライベートDNSゾーンの作成
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# プライベートDNSゾーンとVNETのリンク
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_zone_link" {
  name                  = "pdnslink-sql-${var.project}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# プライベートDNSゾーンとプライベートエンドポイントのリンク
resource "azurerm_private_dns_a_record" "sql_dns_a_record" {
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}