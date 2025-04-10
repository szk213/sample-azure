## .envファイルが存在する場合は読み込む
ifneq (,$(wildcard ./.env))
  include .env
  export
endif

.PHONY: install
install: ## 依存パッケージのクリーンインストール
	npm ci

.PHONY: dev
dev: ## アプリを開発モードで起動
	npm run dev

.PHONY: clean
clean: ## distディレクトリを削除
	npm run clean

.PHONY: build
build: clean ## アプリをビルド
	npm run build

.PHONY: pack
pack: ## アプリをzip化
	npm run zip

.PHONY: deploy
deploy: ## アプリをデプロイ
	az webapp deployment source config-zip --resource-group $(RESOURCE_GROUP_NAME) --name $(APP_SERVICE_NAME) --src $(ZIP_FILE_NAME)

.PHONY: upload
upload: ## ZIPファイルをAzure Storageコンテナにアップロード
	az storage blob upload \
		--account-name $(STORAGE_ACCOUNT_NAME) \
		--container-name $(CONTAINER_NAME) \
		--name $(ZIP_FILE_NAME) \
		--file $(ZIP_FILE_NAME) \
		--auth-mode key

.PHONY: generate-sas-url
generate-sas-url: ## SASトークン付きのダウンロードURLを生成
	@SAS_EXPIRY=$$(date -u -d "30 minutes" +"%Y-%m-%dT%H:%M:%SZ") && \
	SAS_TOKEN=$$(az storage blob generate-sas \
		--account-name $(STORAGE_ACCOUNT_NAME) \
		--container-name $(CONTAINER_NAME) \
		--name $(ZIP_FILE_NAME) \
		--permissions r \
		--expiry $$SAS_EXPIRY \
		--auth-mode key \
		-o tsv) && \
	SAS_URL="https://$(STORAGE_ACCOUNT_NAME).blob.core.windows.net/$(CONTAINER_NAME)/$(ZIP_FILE_NAME)?$$SAS_TOKEN" && \
	az rest --method PUT --uri https://management.azure.com/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(RESOURCE_GROUP_NAME)/providers/Microsoft.Web/sites/$(WEB_APP_NAME)/slots/$(SLOT_NAME)/extensions/onedeploy?api-version=2022-03-01 --body '{ "properties": { "type": "zip", "packageUri": "'"$$SAS_URL"'" } }'

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?# .*$$' Makefile | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

