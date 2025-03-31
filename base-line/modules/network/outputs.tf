output "vnet_id" {
  description = "作成されたVNETのID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "作成されたVNETの名前"
  value       = azurerm_virtual_network.vnet.name
}

output "webapp_subnet_id" {
  description = "WebApp用サブネットのID"
  value       = azurerm_subnet.webapp_subnet.id
}

output "db_subnet_id" {
  description = "データベース用サブネットのID"
  value       = azurerm_subnet.db_subnet.id
}

output "webapp_subnet_name" {
  description = "WebApp用サブネットの名前"
  value       = azurerm_subnet.webapp_subnet.name
}

output "db_subnet_name" {
  description = "データベース用サブネットの名前"
  value       = azurerm_subnet.db_subnet.name
}