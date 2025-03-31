variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境（dev, stg, prod）"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "環境はdev、stg、prodのいずれかである必要があります。"
  }
}

variable "location" {
  description = "リソースのリージョン"
  type        = string
  default     = "japaneast"
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

# ネットワーク関連の変数
variable "vnet_address_space" {
  description = "VNETのアドレス空間"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "サブネットのプレフィックス"
  type        = map(string)
  default = {
    webapp = "10.0.1.0/24"
    db     = "10.0.2.0/24"
  }
}

# App Serviceプラン関連の変数
variable "app_service_plans" {
  description = "App Serviceプランの設定"
  type = map(object({
    sku_name     = string
    tier         = string
    size         = string
    capacity     = number
    zone_balancing_enabled = bool
  }))
}

# WebApp関連の変数
variable "web_apps" {
  description = "WebAppの設定"
  type = map(object({
    app_service_plan_key = string
    app_settings         = map(string)
    site_config = object({
      always_on                = bool
      minimum_tls_version      = string
      ftps_state               = string
      health_check_path        = string
      http2_enabled            = bool
      websockets_enabled       = bool
      application_stack = object({
        current_stack          = string
        dotnet_version         = optional(string)
        java_version           = optional(string)
        node_version           = optional(string)
        php_version            = optional(string)
        python_version         = optional(string)
      })
    })
  }))
}

# SQLデータベース関連の変数
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

# 環境ごとの設定
variable "env_settings" {
  description = "環境ごとの設定"
  type = map(object({
    app_service_plan_settings = map(object({
      sku_name     = string
      tier         = string
      size         = string
      capacity     = number
      zone_balancing_enabled = bool
    }))
    sql_database_settings = map(object({
      sku_name       = string
      max_size_gb    = number
      zone_redundant = bool
      read_scale     = bool
      geo_backup_enabled = bool
    }))
  }))
}