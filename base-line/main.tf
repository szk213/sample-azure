# ワークスペース名から環境を取得
locals {
  workspace_to_environment_map = {
    dev  = "dev"
    stg  = "stg"
    prod = "prod"
  }
  environment = local.workspace_to_environment_map[terraform.workspace]

  # 環境ごとの設定を取得
  current_env_settings = var.env_settings[local.environment]
}

# リソースグループの作成
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = local.environment
    Project     = var.project
  }
}

# ネットワークモジュールの呼び出し
module "network" {
  source = "./modules/network"

  project            = var.project
  environment        = local.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space      = var.vnet_address_space
  subnet_prefixes    = var.subnet_prefixes
}

# App Serviceプランモジュールの呼び出し
module "app_service_plan" {
  source = "./modules/app_service_plan"

  project            = var.project
  environment        = local.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # 環境ごとに異なるApp Serviceプラン設定を適用
  app_service_plans  = local.current_env_settings.app_service_plan_settings
}

# WebAppモジュールの呼び出し
module "webapp" {
  source = "./modules/webapp"

  project            = var.project
  environment        = local.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.rg.name

  web_apps           = var.web_apps
  app_service_plan_ids = module.app_service_plan.app_service_plan_ids
  webapp_subnet_id   = module.network.webapp_subnet_id

  depends_on = [
    module.app_service_plan,
    module.network
  ]
}

# SQLデータベースモジュールの呼び出し
module "database" {
  source = "./modules/database"

  project            = var.project
  environment        = local.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sql_server         = var.sql_server
  # 環境ごとに異なるSQLデータベース設定を適用
  sql_databases      = local.current_env_settings.sql_database_settings
  db_subnet_id       = module.network.db_subnet_id
  vnet_id            = module.network.vnet_id

  depends_on = [
    module.network
  ]
}