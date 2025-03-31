resource "azurerm_windows_web_app" "web_apps" {
  for_each = var.web_apps

  name                = "app-${var.project}-${each.key}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_service_plan_ids[each.value.app_service_plan_key]

  https_only = true

  site_config {
    always_on                = each.value.site_config.always_on
    minimum_tls_version      = each.value.site_config.minimum_tls_version
    ftps_state               = each.value.site_config.ftps_state
    health_check_path        = each.value.site_config.health_check_path
    http2_enabled            = each.value.site_config.http2_enabled
    websockets_enabled       = each.value.site_config.websockets_enabled

    application_stack {
      current_stack  = each.value.site_config.application_stack.current_stack
      dotnet_version = each.value.site_config.application_stack.dotnet_version
      java_version   = each.value.site_config.application_stack.java_version
      node_version   = each.value.site_config.application_stack.node_version
      php_version    = each.value.site_config.application_stack.php_version
    }
  }

  app_settings = each.value.app_settings

  # VNETとの統合
  virtual_network_subnet_id = var.webapp_subnet_id

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  lifecycle {
    ignore_changes = [
      # アプリケーションの設定は、デプロイ時に変更される可能性があるため無視
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}