resource "azurerm_virtual_network" "virtual_network_security" {
  name                = var.vnet_security_name
  address_space       = [var.vnet_security_address_space]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet_pan_mgmt" {
  name                 = "pan-mgmt-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_security.name
  address_prefixes     = [cidrsubnet(var.vnet_security_address_space, 4, 0)]
}

resource "azurerm_subnet" "subnet_pan_data" {
  name                 = "pan-data-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_security.name
  address_prefixes     = [cidrsubnet(var.vnet_security_address_space, 4, 1)]
}

resource "azurerm_lb" "aglb" {
  name                = "security-lb-01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku = "Gateway"

  frontend_ip_configuration {
    name      = "firewall-inspection"
    subnet_id = azurerm_subnet.subnet_pan_data.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.aglb.id

  tunnel_interface {
    type       = "Internal"
    identifier = "800"
    port       = "2000"
    protocol   = "VXLAN"
  }
  tunnel_interface {
    type       = "External"
    identifier = "801"
    port       = "2001"
    protocol   = "VXLAN"
  }
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.aglb.id

  name     = "probe-tcp-443"
  port     = 443
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "lb_rule" {
  name            = "lb-rule-firewall"
  loadbalancer_id = azurerm_lb.aglb.id
  probe_id        = azurerm_lb_probe.lb_probe.id

  frontend_ip_configuration_name = azurerm_lb.aglb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_address_pool.id]

  # HA port rule - required by Azure GWLB
  protocol      = "All"
  backend_port  = 0
  frontend_port = 0
}