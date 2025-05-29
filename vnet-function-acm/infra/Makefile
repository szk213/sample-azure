ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: clean
clean: ## 生成したファイルを削除します。
	rm -rf cdktf.out

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
console: ## コンソールを起動
	terraform console

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
