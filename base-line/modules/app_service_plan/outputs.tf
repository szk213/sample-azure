output "app_service_plan_ids" {
  description = "作成されたApp Serviceプランのマップ（キー: プラン名, 値: ID）"
  value       = { for k, v in azurerm_service_plan.app_service_plans : k => v.id }
}

output "app_service_plan_names" {
  description = "作成されたApp Serviceプランの名前のマップ（キー: プラン名, 値: 名前）"
  value       = { for k, v in azurerm_service_plan.app_service_plans : k => v.name }
}