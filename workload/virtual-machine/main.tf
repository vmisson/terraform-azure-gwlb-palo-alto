data "azurerm_lb" "aglb" {
  name                = var.lb_name
  resource_group_name = var.lb_resource_group_name
}

resource "random_password" "password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "network" {
  name                = "workload-vnet-01"
  address_space       = ["10.123.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.123.0.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                                               = "ipconfig"
    subnet_id                                          = azurerm_subnet.subnet.id
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.public_ip.id
    gateway_load_balancer_frontend_ip_configuration_id = data.azurerm_lb.aglb.frontend_ip_configuration[0].id
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.vm_name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = var.username
  admin_password                  = coalesce(var.password, random_password.password.result)
  disable_password_authentication = false

  boot_diagnostics {}
}
