provider "azurerm" {
  features {}
}

variable "resource_group" {
  type = string
  name = "FireWallResourceGroup"
}
resource "azurerm_resource_group" "FireWallResourceGroup" {
  location = "eastus"
  name = var.resource_group
}

resource "azurerm_virtual_network" "AdminClasses" {
  address_space = [192.168.0.1/16]
  location = "eastus"
  name = "AdminClass_11thApril"
  resource_group_name = var.resource_group
}

