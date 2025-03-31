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

variable "address_space" {
  description = "VNETのアドレス空間"
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "サブネットのプレフィックス"
  type        = map(string)
}