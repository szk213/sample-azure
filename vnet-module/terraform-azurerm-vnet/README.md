# Azure Virtual Network Terraform モジュール

このTerraformモジュールは、Azure Virtual Network（VNET）とサブネットを作成します。ネットワークプレフィックスとインデックスを指定することで、サブネットを動的に作成できます。

## 特徴

- Azure Resource Manager プロバイダーバージョン 4.24.0 を使用
- ネットワークプレフィックスとインデックスを指定してサブネットを作成
- サブネットの委任（delegation）をサポート
- サービスエンドポイントの設定をサポート
- 再利用可能なモジュール設計

## 使用方法

```hcl
module "vnet" {
  source = "path/to/terraform-azurerm-vnet"

  resource_group_name = "example-rg"
  location            = "japaneast"
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]

  subnets = [
    {
      name    = "subnet1"
      newbits = 8  # /16から/24へ
      netnum  = 0  # 最初のサブネット（10.0.0.0/24）
    },
    {
      name    = "subnet2"
      newbits = 8
      netnum  = 1  # 2番目のサブネット（10.0.1.0/24）
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    },
    {
      name    = "subnet3"
      newbits = 8
      netnum  = 2
      delegation = {
        name = "delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  ]

  tags = {
    Environment = "Production"
    Department  = "IT"
  }
}
```

## サブネットの計算方法

このモジュールでは、`cidrsubnet`関数を使用してサブネットのアドレス範囲を計算します。

例えば、VNETのアドレス空間が`10.0.0.0/16`の場合：

- `newbits = 8, netnum = 0` → `10.0.0.0/24`
- `newbits = 8, netnum = 1` → `10.0.1.0/24`
- `newbits = 8, netnum = 2` → `10.0.2.0/24`

`newbits`パラメータは、サブネットマスクに追加するビット数を指定します。VNETのアドレス空間が/16の場合、`newbits = 8`を指定すると、サブネットマスクは/24になります。

`netnum`パラメータは、サブネットのインデックスを指定します。これにより、同じサイズの複数のサブネットを作成できます。

## 入力変数

| 名前 | 説明 | タイプ | デフォルト | 必須 |
|------|-------------|------|---------|:--------:|
| create_resource_group | リソースグループを作成するかどうか | `bool` | `false` | いいえ |
| resource_group_name | リソースグループ名 | `string` | n/a | はい |
| location | Azureリージョン | `string` | n/a | はい |
| vnet_name | 仮想ネットワーク名 | `string` | n/a | はい |
| address_space | 仮想ネットワークのアドレス空間 | `list(string)` | n/a | はい |
| dns_servers | DNSサーバーのIPアドレスリスト | `list(string)` | `[]` | いいえ |
| tags | リソースに付与するタグ | `map(string)` | `{}` | いいえ |
| subnets | サブネット設定のリスト | `list(object)` | `[]` | いいえ |

## 出力値

| 名前 | 説明 |
|------|-------------|
| vnet_id | 仮想ネットワークのID |
| vnet_name | 仮想ネットワークの名前 |
| vnet_address_space | 仮想ネットワークのアドレス空間 |
| vnet_location | 仮想ネットワークのリージョン |
| subnet_ids | 作成されたサブネットのIDマップ |
| subnet_address_prefixes | 作成されたサブネットのアドレスプレフィックスマップ |
| resource_group_name | リソースグループ名 |

## 注意事項

- このモジュールはAzure RMプロバイダーバージョン4.24.0を使用しています。他のバージョンでは動作が異なる場合があります。
- サブネットの作成には`cidrsubnet`関数を使用しているため、適切な`newbits`と`netnum`の値を指定する必要があります。
- リソースグループを作成する場合は、`create_resource_group = true`を指定してください。

## ライセンス

MIT