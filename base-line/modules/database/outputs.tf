output "sql_server_id" {
  description = "作成されたSQL ServerのID"
  value       = azurerm_mssql_server.sql_server.id
}

output "sql_server_name" {
  description = "作成されたSQL Serverの名前"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  description = "作成されたSQL ServerのFQDN"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_ids" {
  description = "作成されたSQLデータベースのマップ（キー: データベース名, 値: ID）"
  value       = { for k, v in azurerm_mssql_database.sql_databases : k => v.id }
}

output "sql_database_names" {
  description = "作成されたSQLデータベースの名前のマップ（キー: データベース名, 値: 名前）"
  value       = { for k, v in azurerm_mssql_database.sql_databases : k => v.name }
}

output "private_endpoint_id" {
  description = "作成されたプライベートエンドポイントのID"
  value       = azurerm_private_endpoint.sql_private_endpoint.id
}

output "private_dns_zone_id" {
  description = "作成されたプライベートDNSゾーンのID"
  value       = azurerm_private_dns_zone.sql_dns_zone.id
}