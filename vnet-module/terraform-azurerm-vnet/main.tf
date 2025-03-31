/**
 * # Azure Virtual Network モジュール
 *
 * このモジュールは Azure Virtual Network とサブネットを作成します。
 * ネットワークプレフィックスとインデックスを指定することで、サブネットを動的に作成できます。
 */

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.address_space[0], each.value.newbits, each.value.netnum)]

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []

    content {
      name = lookup(each.value.delegation, "name", null)

      dynamic "service_delegation" {
        for_each = lookup(each.value.delegation, "service_delegation", {}) != {} ? [1] : []

        content {
          name    = lookup(each.value.delegation.service_delegation, "name", null)
          actions = lookup(each.value.delegation.service_delegation, "actions", null)
        }
      }
    }
  }

  service_endpoints = lookup(each.value, "service_endpoints", null)
}