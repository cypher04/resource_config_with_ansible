// backend configuration for Terraform state
terraform {
  backend "azurerm" {
    resource_group_name  = "config_with_ansible-dev-rg"
    storage_account_name = "configwithansiblestate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}