provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}


variable "region0" {default = "eastus"}
variable "resource_grp0" {default = "linux_vm_rsgrp0"}
variable "vnet0" {default = "linux_vm_vnet0"}
variable "subnet0" {default = "linux_vm_subnet0"}
variable "publicIP0" {default = "linux_vm_publicIP0"}
variable "nic0" {default = "linux_vm_nic0"}
variable "vm0" {default = "linuxvm0"}


resource "azurerm_resource_group" "RsGrp" {
  location = var.region0
  name = var.resource_grp0
}


resource "azurerm_virtual_network" "Vnet" {
  address_space = ["10.40.0.0/20"]
  location = var.region0
  name = var.vnet0
  resource_group_name = azurerm_resource_group.RsGrp.name
}


resource "azurerm_subnet" "subnet0" {
  name = var.subnet0
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes = ["10.40.0.0/24"]
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
    private_ip_address = "10.40.0.4"
    subnet_id = azurerm_subnet.subnet0.id
    public_ip_address_id = azurerm_public_ip.publicIp0.id
  }

}



//resource "azurerm_network_security_group" "nsg" {
//  location = var.region
//  name = "az104-04-nsg01"
//  resource_group_name = azurerm_resource_group.RsGrp.name
//
//  security_rule {
//    access = "Allow"
//    direction = "Inbound"
//    name = "AllowRDPInBound"
//    priority = 300
//    protocol = "TCP"
//    source_port_range          = "*"
//    destination_port_range     = "*"
//    source_address_prefix      = "*"
//    destination_address_prefix = "*"
//  }
//}
//
//
//resource "azurerm_network_interface_security_group_association" "nsg_nic0" {
//  network_interface_id = azurerm_network_interface.nic0.id
//  network_security_group_id = azurerm_network_security_group.nsg.id
//}

resource "azurerm_linux_virtual_machine" "vm0" {
  admin_username = "adminuser"
  location = var.region0
  name = var.vm0
  network_interface_ids = [azurerm_network_interface.nic0.id]
  resource_group_name = azurerm_resource_group.RsGrp.name
  size = "Standard_B1ms"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }


}



