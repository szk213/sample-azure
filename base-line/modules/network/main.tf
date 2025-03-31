resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "azurerm_subnet" "webapp_subnet" {
  name                 = "snet-webapp-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes["webapp"]]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes["db"]]

  # プライベートエンドポイント用のサブネット設定
  # 最新のAzureRMプロバイダーではこの設定は不要になりました
}

# NSGの作成
resource "azurerm_network_security_group" "webapp_nsg" {
  name                = "nsg-webapp-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "nsg-db-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# NSGとサブネットの関連付け
resource "azurerm_subnet_network_security_group_association" "webapp_nsg_association" {
  subnet_id                 = azurerm_subnet.webapp_subnet.id
  network_security_group_id = azurerm_network_security_group.webapp_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "db_nsg_association" {
  subnet_id                 = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}