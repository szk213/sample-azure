variable "create_resource_group" {
  description = "リソースグループを作成するかどうか"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "vnet_name" {
  description = "仮想ネットワーク名"
  type        = string
}

variable "address_space" {
  description = "仮想ネットワークのアドレス空間"
  type        = list(string)
}

variable "dns_servers" {
  description = "DNSサーバーのIPアドレスリスト"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "サブネット設定のリスト"
  type = list(object({
    name                 = string
    newbits              = number
    netnum               = number
    service_endpoints    = optional(list(string))
    delegation           = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = []
}