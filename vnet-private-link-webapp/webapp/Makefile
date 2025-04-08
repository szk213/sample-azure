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

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?# .*$$' Makefile | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

