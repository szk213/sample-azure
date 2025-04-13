ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: clean
clean: ## 生成したファイルを削除します。
	rm -rf cdktf.out

.PHONY: upgrade
upgrade: ## tfのバージョンをアップグレードします。
	terraform init -upgrade

.PHONY: migrate
migrate: ## tfの状態を移行します。
	terraform init -migrate-state

.PHONY: plan
plan: ## tfの変更点を確認します。
	terraform plan

.PHONY: apply
apply: ## tfの変更を適用します。
	terraform apply

.PHONY: destroy
destroy: ## アプリをデプロイ
	terraform destroy

.PHONY: console
console: ## アプリをデプロイ
	terraform console

.PHONY: import
import: ## tfの状態を移行します。
	terraform import azurerm_firewall_application_rule_collection.allow_check_ip "/subscriptions/74db08eb-931d-4dd4-bbba-2daab9574c33/resourceGroups/szk213-agvplwhsf-firewall-rg/providers/Microsoft.Network/azureFirewalls/fw-hub/applicationRuleCollections/AllowCheckip"

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
