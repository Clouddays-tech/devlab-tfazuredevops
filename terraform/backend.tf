terraform {
  backend "azurerm" {
    storage_account_name = "devopsstgacc"
    container_name       = "devops-blob"
    key                  = "tf_prod.tfstate"
  }
}
