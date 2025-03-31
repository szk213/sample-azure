resource "azurerm_service_plan" "app_service_plans" {
  for_each = var.app_service_plans

  name                = "asp-${var.project}-${each.key}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = each.value.sku_name

  zone_balancing_enabled = each.value.zone_balancing_enabled

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}