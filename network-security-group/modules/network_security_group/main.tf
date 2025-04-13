variable "config_list" {
}

resource "azurerm_network_security_group" "this"{
  for_each = var.config_list.network_security_groups
  name = "network-security-group-${each.key}"
  resource_group_name = var.config_list.resource_group.name
  location = var.config_list.resource_group.location

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                                        = "security-rule-${security_rule.key}-${each-key}"
      protocol                                    = security_rule.value.protocol
      access                                      = security_rule.value.access
      priority                                    = security_rule.value.priority
      direction                                   = security_rule.value.direction
      source_port_range                           = try(security_rule.value.source_port_range, null)
      source_port_ranges                          = try(security_rule.value.source_port_ranges, null)
      destination_port_range                      = try(security_rule.value.destination_port_range, null)
      destination_port_ranges                     = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix                       = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes                     = try(security_rule.value.source_address_prefixes, null)
      source_application_security_group_ids       = try(security_rule.value.source_application_security_group_ids, null)
      destination_address_prefix                  = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes                = try(security_rule.value.destination_address_prefixes, null)
      destination_application_security_group_ids  = try(security_rule.value.destination_application_security_group_ids, null)
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this"{
  for_each = var.config_list.network_security_groups
  subnet_id      = var.config_list.subnets[each.value.subnet].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
