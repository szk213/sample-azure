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