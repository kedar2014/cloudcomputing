provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}


variable "region" {default = "eastus"}

resource "azurerm_resource_group" "RsGrp" {
  location = var.region
  name = "az104-04-rg1"
}


resource "azurerm_virtual_network" "Vnet" {
  address_space = ["10.40.0.0/20"]
  location = var.region
  name = "az104-04-vnet1"
  resource_group_name = azurerm_resource_group.RsGrp.name
}


resource "azurerm_subnet" "subnet0" {
  name = "subnet0"
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes = ["10.40.0.0/24"]
}


resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = azurerm_resource_group.RsGrp.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes = ["10.40.1.0/24"]
}




resource "azurerm_public_ip" "publicIp0" {
  allocation_method = "Dynamic"
  location = var.region
  name = "publicIp0"
  resource_group_name = azurerm_resource_group.RsGrp.name
}

resource "azurerm_network_interface" "nic0" {
  location = var.region
  name = "nic0"
  resource_group_name = azurerm_resource_group.RsGrp.name
  ip_configuration {
    name = "ip0"
    private_ip_address_allocation = "static"
    private_ip_address = "10.40.0.4"
    subnet_id = azurerm_subnet.subnet0.id
    public_ip_address_id = azurerm_public_ip.publicIp0.id
    }

}

resource "azurerm_public_ip" "publicIp1" {
  allocation_method = "Dynamic"
  location = var.region
  name = "publicIp1"
  resource_group_name = azurerm_resource_group.RsGrp.name
}

resource "azurerm_network_interface" "nic1" {
  location = var.region
  name = "nic1"
  resource_group_name = azurerm_resource_group.RsGrp.name
  ip_configuration {
    name = "ip1"
    private_ip_address_allocation = "static"
    private_ip_address = "10.40.1.4"
    subnet_id = azurerm_subnet.subnet1.id
    public_ip_address_id = azurerm_public_ip.publicIp1.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  location = var.region
  name = "az104-04-nsg01"
  resource_group_name = azurerm_resource_group.RsGrp.name

  security_rule {
    access = "Allow"
    direction = "Inbound"
    name = "AllowRDPInBound"
    priority = 300
    protocol = "TCP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "nsg_nic0" {
  network_interface_id = azurerm_network_interface.nic0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg_nic1" {
  network_interface_id = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_virtual_machine" "vm0" {

  location = var.region
  name = "vm0"
  resource_group_name = azurerm_resource_group.RsGrp.name
  network_interface_ids = [azurerm_network_interface.nic0.id]
  vm_size = "Standard_B1ms"
  storage_os_disk {
    create_option = "FromImage"
    name = "myosdisk0"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}



