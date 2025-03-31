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

variable "app_service_plan_ids" {
  description = "App Serviceプランのマップ（キー: プラン名, 値: ID）"
  type        = map(string)
}

variable "webapp_subnet_id" {
  description = "WebApp用サブネットのID"
  type        = string
}