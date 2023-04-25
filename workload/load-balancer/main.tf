data "azurerm_lb" "aglb" {
  name                = var.lb_name
  resource_group_name = var.lb_resource_group_name
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_public_ip" "public_ip" {
  name                = "elb-pip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "application-elb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-elb"
    public_ip_address_id = azurerm_public_ip.public_ip.id
    gateway_load_balancer_frontend_ip_configuration_id = data.azurerm_lb.aglb.frontend_ip_configuration[0].id
  }
}