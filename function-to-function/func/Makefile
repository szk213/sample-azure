ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: clean
clean: ## 生成したファイルを削除します。
	rm -rf cdktf.out

.PHONY: build
build: ## アプリをビルド
	npm run build

.PHONY: pack
pack: ## アプリをパッケージング
	npm run pack

.PHONY: deploy
deploy: ## アプリをデプロイ
	az functionapp deployment source config-zip --resource-group $(RESOURCE_GROUP_NAME) --name $(APP_NAME) --src $(ZIP_FILE_NAME)

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
