provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}


variable "region0" {default = "eastus"}
variable "region1" {default = "westus"}
variable "resource_grp0" {default = "intersite_rsgrp0"}
variable "vnet0" {default = "intersite_vnet0"}
variable "vnet1" {default = "intersite_vnet1"}
variable "vnet2" {default = "intersite_vnet2"}
variable "subnet0" {default = "intersite_subnet0"}
variable "subnet1" {default = "intersite_subnet1"}
variable "subnet2" {default = "intersite_subnet2"}
variable "publicIP0" {default = "intersite_publicIP0"}
variable "nic0" {default = "intersite_nic0"}
variable "nic1" {default = "intersite_nic1"}
variable "nic2" {default = "intersite_nic2"}
variable "vm0" {default = "intersitevm0"}
variable "vm1" {default = "intersitevm1"}
variable "vm2" {default = "intersitevm2"}

resource "azurerm_resource_group" "RsGrp" {
  location = var.region0
  name = var.resource_grp0
}

// First Vnet with 1 windows VM

resource "azurerm_virtual_network" "Vnet0" {
  address_space = ["10.40.0.0/16"]
  location = var.region0
  name = var.vnet0
  resource_group_name = azurerm_resource_group.RsGrp.name
}


resource "azurerm_subnet" "subnet0" {
  name = var.subnet0
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet0.name
  address_prefixes = ["10.40.1.0/24"]
}


resource "azurerm_public_ip" "publicIp0" {
  allocation_method = "Dynamic"
  location = var.region0
  name = var.publicIP0
  resource_group_name = azurerm_resource_group.RsGrp.name
}

resource "azurerm_network_interface" "nic0" {
  location = var.region0
  name = var.nic0
  resource_group_name = azurerm_resource_group.RsGrp.name
  ip_configuration {
    name = "ip0"
    private_ip_address_allocation = "static"
    private_ip_address = "10.40.1.4"
    subnet_id = azurerm_subnet.subnet0.id
    public_ip_address_id = azurerm_public_ip.publicIp0.id
  }

}


resource "azurerm_windows_virtual_machine" "vm0" {
  name                = var.vm0
  resource_group_name = azurerm_resource_group.RsGrp.name
  location            = var.region0
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic0.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

// Second Vnet with 1 windows VM

resource "azurerm_virtual_network" "Vnet1" {
  address_space = ["10.41.0.0/16"]
  location = var.region0
  name = var.vnet1
  resource_group_name = azurerm_resource_group.RsGrp.name
}


resource "azurerm_subnet" "subnet1" {
  name = var.subnet1
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet1.name
  address_prefixes = ["10.41.1.0/24"]
}




resource "azurerm_network_interface" "nic1" {
  location = var.region0
  name = var.nic1
  resource_group_name = azurerm_resource_group.RsGrp.name
  ip_configuration {
    name = "ip0"
    private_ip_address_allocation = "static"
    private_ip_address = "10.41.1.4"
    subnet_id = azurerm_subnet.subnet1.id
  }

}


resource "azurerm_windows_virtual_machine" "vm1" {
  name                = var.vm1
  resource_group_name = azurerm_resource_group.RsGrp.name
  location            = var.region0
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

// Third Vnet with 1 windows VM in a different Region

resource "azurerm_virtual_network" "Vnet2" {
  address_space = ["10.42.0.0/16"]
  location = var.region1
  name = var.vnet2
  resource_group_name = azurerm_resource_group.RsGrp.name
}


resource "azurerm_subnet" "subnet2" {
  name = var.subnet2
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet2.name
  address_prefixes = ["10.42.1.0/24"]
}




resource "azurerm_network_interface" "nic2" {
  location = var.region1
  name = var.nic2
  resource_group_name = azurerm_resource_group.RsGrp.name
  ip_configuration {
    name = "ip0"
    private_ip_address_allocation = "static"
    private_ip_address = "10.42.1.4"
    subnet_id = azurerm_subnet.subnet2.id
  }

}


resource "azurerm_windows_virtual_machine" "vm2" {
  name                = var.vm2
  resource_group_name = azurerm_resource_group.RsGrp.name
  location            = var.region1
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


// creating vnet peering between vnet0-vnet1 & vnet1-vnet0

resource "azurerm_virtual_network_peering" "vnet0To1" {
  name = "vnet0To1"
  remote_virtual_network_id = azurerm_virtual_network.Vnet1.id
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet0.name
}

resource "azurerm_virtual_network_peering" "vnet1To0" {
  name = "vnet1To0"
  remote_virtual_network_id = azurerm_virtual_network.Vnet0.id
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet1.name
}

// creating vnet peering between vnet0-vnet2 & vnet2-vnet0

resource "azurerm_virtual_network_peering" "vnet0To2" {
  name = "vnet0To2"
  remote_virtual_network_id = azurerm_virtual_network.Vnet2.id
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet0.name
}

resource "azurerm_virtual_network_peering" "vnet2To0" {
  name = "vnet2To0"
  remote_virtual_network_id = azurerm_virtual_network.Vnet0.id
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet2.name
}