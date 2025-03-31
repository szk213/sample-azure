# Azure Terraform ベーステンプレート

このリポジトリは、Terraformを使用してAzureインフラを構築するためのベーステンプレートです。
Terraform Workspaceを使用して、dev、stg、prod環境に対して同じ構成を取りつつ、環境ごとにマシンスペックなどを変えて構築できます。

## 機能

- 1つのVNET内に複数のサブネットを作成
- 1つ以上のApp Serviceプランと1つ以上のWebアプリを作成
- SQLデータベースの作成
- VNETの統合やプライベートエンドポイントによるセキュアな接続
- Webアプリの環境変数を変数として複数指定可能
- 環境ごとに異なるリソース設定（SKU、容量など）

## 前提条件

- Terraform v1.0.0以上
- Azure CLIまたはAzure PowerShell
- Azureサブスクリプション

## 使用方法

### 1. 環境変数の設定

Azureへの認証情報を環境変数として設定します。

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### 2. terraform.tfvarsファイルの作成

プロジェクト固有の変数を設定するために、`terraform.tfvars`ファイルを作成します。

```hcl
project = "yourproject"
location = "japaneast"
resource_group_name = "rg-yourproject"

vnet_address_space = ["10.0.0.0/16"]
subnet_prefixes = {
  webapp = "10.0.1.0/24"
  db     = "10.0.2.0/24"
}

web_apps = {
  app1 = {
    app_service_plan_key = "plan1"
    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "~14"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "your-key"
      # 他の環境変数をここに追加
    }
    site_config = {
      always_on           = true
      minimum_tls_version = "1.2"
      ftps_state          = "Disabled"
      health_check_path   = "/health"
      http2_enabled       = true
      websockets_enabled  = false
      application_stack = {
        current_stack  = "dotnet"
        dotnet_version = "v6.0"
        java_version   = null
        node_version   = null
        php_version    = null
      }
    }
  }
  # 他のWebアプリをここに追加
}

sql_server = {
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
  version                      = "12.0"
  minimum_tls_version          = "1.2"
}

env_settings = {
  dev = {
    app_service_plan_settings = {
      plan1 = {
        sku_name     = "B1"
        tier         = "Basic"
        size         = "B1"
        capacity     = 1
        zone_balancing_enabled = false
      }
    }
    sql_database_settings = {
      db1 = {
        sku_name       = "Basic"
        max_size_gb    = 2
        zone_redundant = false
        read_scale     = false
        geo_backup_enabled = false
      }
    }
  }
  stg = {
    app_service_plan_settings = {
      plan1 = {
        sku_name     = "S1"
        tier         = "Standard"
        size         = "S1"
        capacity     = 1
        zone_balancing_enabled = false
      }
    }
    sql_database_settings = {
      db1 = {
        sku_name       = "S1"
        max_size_gb    = 50
        zone_redundant = false
        read_scale     = false
        geo_backup_enabled = true
      }
    }
  }
  prod = {
    app_service_plan_settings = {
      plan1 = {
        sku_name     = "P1v2"
        tier         = "PremiumV2"
        size         = "P1v2"
        capacity     = 2
        zone_balancing_enabled = true
      }
    }
    sql_database_settings = {
      db1 = {
        sku_name       = "P1"
        max_size_gb    = 100
        zone_redundant = true
        read_scale     = true
        geo_backup_enabled = true
      }
    }
  }
}
```

### 3. Terraformの初期化

```bash
terraform init
```

### 4. ワークスペースの作成と選択

```bash
# 開発環境のワークスペースを作成
terraform workspace new dev

# ステージング環境のワークスペースを作成
terraform workspace new stg

# 本番環境のワークスペースを作成
terraform workspace new prod

# 使用するワークスペースを選択（例：開発環境）
terraform workspace select dev
```

### 5. 実行計画の確認

```bash
terraform plan
```

### 6. インフラのデプロイ

```bash
terraform apply
```

## カスタマイズ方法

このテンプレートは、各プロジェクトに展開するためのベースとして設計されています。以下の方法でカスタマイズできます：

1. 変数の追加や変更
2. モジュールの追加や変更
3. リソースの追加や変更

## 注意事項

- 本番環境では、パスワードなどの機密情報をterraform.tfvarsファイルに直接記述せず、Azure Key VaultやTerraform Cloudの変数機能を使用してください。
- SQLサーバーのパスワードは、本番環境では十分に強力なものを使用してください。
- 環境ごとに適切なスケーリング設定を行ってください。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
