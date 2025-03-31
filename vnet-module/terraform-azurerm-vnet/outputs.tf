output "vnet_id" {
  description = "仮想ネットワークのID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "仮想ネットワークの名前"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "仮想ネットワークのアドレス空間"
  value       = azurerm_virtual_network.this.address_space
}

output "vnet_location" {
  description = "仮想ネットワークのリージョン"
  value       = azurerm_virtual_network.this.location
}

output "subnet_ids" {
  description = "作成されたサブネットのIDマップ"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "subnet_address_prefixes" {
  description = "作成されたサブネットのアドレスプレフィックスマップ"
  value       = { for k, v in azurerm_subnet.this : k => v.address_prefixes }
}

output "resource_group_name" {
  description = "リソースグループ名"
  value       = local.resource_group_name
}