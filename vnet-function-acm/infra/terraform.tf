terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.28.0"
    }

    azapi = {
      source = "Azure/azapi"
      version = "2.4.0"
    }
  }
}
