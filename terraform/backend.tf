terraform {
backend "azurerm" {
  storage_account_name = "devlabstg"
  container_name       = "devlabblob"
  key                  = "tf_prod.tfstate"
}
}
