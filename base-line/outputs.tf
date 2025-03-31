# ネットワーク関連の出力
output "vnet_id" {
  description = "作成されたVNETのID"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "作成されたVNETの名前"
  value       = module.network.vnet_name
}

output "webapp_subnet_id" {
  description = "WebApp用サブネットのID"
  value       = module.network.webapp_subnet_id
}

output "db_subnet_id" {
  description = "データベース用サブネットのID"
  value       = module.network.db_subnet_id
}

# App Serviceプラン関連の出力
output "app_service_plan_ids" {
  description = "作成されたApp Serviceプランのマップ（キー: プラン名, 値: ID）"
  value       = module.app_service_plan.app_service_plan_ids
}

output "app_service_plan_names" {
  description = "作成されたApp Serviceプランの名前のマップ（キー: プラン名, 値: 名前）"
  value       = module.app_service_plan.app_service_plan_names
}

# WebApp関連の出力
output "web_app_ids" {
  description = "作成されたWebアプリのマップ（キー: アプリ名, 値: ID）"
  value       = module.webapp.web_app_ids
}

output "web_app_names" {
  description = "作成されたWebアプリの名前のマップ（キー: アプリ名, 値: 名前）"
  value       = module.webapp.web_app_names
}

output "web_app_hostnames" {
  description = "作成されたWebアプリのホスト名のマップ（キー: アプリ名, 値: デフォルトホスト名）"
  value       = module.webapp.web_app_hostnames
}

# SQLデータベース関連の出力
output "sql_server_id" {
  description = "作成されたSQL ServerのID"
  value       = module.database.sql_server_id
}

output "sql_server_name" {
  description = "作成されたSQL Serverの名前"
  value       = module.database.sql_server_name
}

output "sql_server_fqdn" {
  description = "作成されたSQL ServerのFQDN"
  value       = module.database.sql_server_fqdn
}

output "sql_database_ids" {
  description = "作成されたSQLデータベースのマップ（キー: データベース名, 値: ID）"
  value       = module.database.sql_database_ids
}

output "sql_database_names" {
  description = "作成されたSQLデータベースの名前のマップ（キー: データベース名, 値: 名前）"
  value       = module.database.sql_database_names
}