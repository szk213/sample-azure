variable "config_list" {
}

resource "azurerm_route_table" "rt" {
  for_each = var.config_list.route_tables
  name                          = "route-table-${each.key}"
  location                      = var.config_list.resource_group.location
  resource_group_name           = var.config_list.resource_group.name
  bgp_route_propagation_enabled = false

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = "route-to-${route.key}"
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }

  }
}

resource "azurerm_subnet_route_table_association" "rt" {
  for_each = var.config_list.route_tables
  subnet_id      = var.config_list.subnets[each.value.subnet].id
  route_table_id = azurerm_route_table.rt[each.key].id
}
