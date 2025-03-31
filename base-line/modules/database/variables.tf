variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境（dev, stg, prod）"
  type        = string
}

variable "location" {
  description = "リソースのリージョン"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "sql_server" {
  description = "SQL Serverの設定"
  type = object({
    administrator_login          = string
    administrator_login_password = string
    version                      = string
    minimum_tls_version          = string
  })
}

variable "sql_databases" {
  description = "SQLデータベースの設定"
  type = map(object({
    sku_name       = string
    max_size_gb    = number
    zone_redundant = bool
    read_scale     = bool
    geo_backup_enabled = bool
  }))
}

variable "db_subnet_id" {
  description = "データベース用サブネットのID"
  type        = string
}

variable "vnet_id" {
  description = "VNETのID"
  type        = string
}