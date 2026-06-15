terraform {

  backend "azurerm" {

    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod12345"
    container_name       = "tfstate"
    key                  = "aks-prod.tfstate"

  }
}
