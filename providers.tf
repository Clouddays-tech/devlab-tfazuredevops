terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  client_id                       = var.spn-client-id
  client_secret                   = var.spn-client-secret
  tenant_id                       = var.spn-tenant-id
  subscription_id                 = local.subscription_id

}
