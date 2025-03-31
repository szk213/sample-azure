output "web_app_ids" {
  description = "作成されたWebアプリのマップ（キー: アプリ名, 値: ID）"
  value       = { for k, v in azurerm_windows_web_app.web_apps : k => v.id }
}

output "web_app_names" {
  description = "作成されたWebアプリの名前のマップ（キー: アプリ名, 値: 名前）"
  value       = { for k, v in azurerm_windows_web_app.web_apps : k => v.name }
}

output "web_app_hostnames" {
  description = "作成されたWebアプリのホスト名のマップ（キー: アプリ名, 値: デフォルトホスト名）"
  value       = { for k, v in azurerm_windows_web_app.web_apps : k => v.default_hostname }
}