# ストレージアカウントの作成
resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.namespace}deploy"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
    source      = "terraform"
  }
}

# Blob コンテナの作成
resource "azurerm_storage_container" "blob_container" {
  name                  = "deploy"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}
