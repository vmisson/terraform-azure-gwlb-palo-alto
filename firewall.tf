resource "azurerm_network_security_group" "fw01-mgmt-nsg" {
  name                = "${var.firewall_vm_name}-mgmt-nsg-01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "network_security_rule_mgmt" {
  name                        = "mgmt-allow-inbound"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.fw01-mgmt-nsg.name
  access                      = "Allow"
  direction                   = "Inbound"
  priority                    = 1000
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = var.allow_inbound_mgmt_ips
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

resource "azurerm_subnet_network_security_group_association" "network_security_group_association_mgmt" {
  subnet_id                 = azurerm_subnet.subnet_pan_mgmt.id
  network_security_group_id = azurerm_network_security_group.fw01-mgmt-nsg.id
}

resource "random_integer" "id" {
  min = 100
  max = 999
}

resource "random_password" "password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

module "bootstrap" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/bootstrap"
  version = "0.5.5"

  location             = azurerm_resource_group.resource_group.location
  resource_group_name  = azurerm_resource_group.resource_group.name
  storage_account_name = "paloaltobootstrap${random_integer.id.result}"
  storage_share_name   = "sharepaloaltobootstrap${random_integer.id.result}"
  files = {
    "files/init-cfg.txt"  = "config/init-cfg.txt"
    "files/bootstrap.xml" = "config/bootstrap.xml"
  }
}

resource "azurerm_public_ip" "fw01_mgmt_pip_01" {
  name                = "${var.firewall_vm_name}-01-mgmt-pip-01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.firewall_vm_name}-01-mgmt-${random_integer.id.result}"
}

module "paloalto_vmseries_01" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/vmseries"
  version = "0.5.5"

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${var.firewall_vm_name}-01"
  username            = var.username
  password            = coalesce(var.password, random_password.password.result)
  img_version         = var.common_vmseries_version
  img_sku             = var.common_vmseries_sku
  vm_size             = var.common_vmseries_vm_size
  enable_zones        = true
  bootstrap_options = (join(",",
    [
      "storage-account=${module.bootstrap.storage_account.name}",
      "access-key=${module.bootstrap.storage_account.primary_access_key}",
      "file-share=${module.bootstrap.storage_share.name}",
      "share-directory=None"
    ]
  ))
  interfaces = [
    {
      name                 = "${var.firewall_vm_name}-01-mgmt"
      subnet_id            = azurerm_subnet.subnet_pan_mgmt.id
      public_ip_address_id = azurerm_public_ip.fw01_mgmt_pip_01.id
    },
    {
      name                = "${var.firewall_vm_name}-01-data"
      subnet_id           = azurerm_subnet.subnet_pan_data.id
      enable_backend_pool = true
      lb_backend_pool_id  = azurerm_lb_backend_address_pool.backend_address_pool.id
    },
  ]
  depends_on = [module.bootstrap]
}

resource "azurerm_public_ip" "fw02_mgmt_pip_01" {
  name                = "${var.firewall_vm_name}-02-mgmt-pip-01"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.firewall_vm_name}-02-mgmt-${random_integer.id.result}"
}

module "paloalto_vmseries_02" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/vmseries"
  version = "0.5.5"

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${var.firewall_vm_name}-02"
  username            = var.username
  password            = coalesce(var.password, random_password.password.result)
  img_version         = var.common_vmseries_version
  img_sku             = var.common_vmseries_sku
  enable_zones        = true
  bootstrap_options = (join(",",
    [
      "storage-account=${module.bootstrap.storage_account.name}",
      "access-key=${module.bootstrap.storage_account.primary_access_key}",
      "file-share=${module.bootstrap.storage_share.name}",
      "share-directory=None"
    ]
  ))
  interfaces = [
    {
      name                 = "${var.firewall_vm_name}-02-mgmt"
      subnet_id            = azurerm_subnet.subnet_pan_mgmt.id
      public_ip_address_id = azurerm_public_ip.fw02_mgmt_pip_01.id
    },
    {
      name                = "${var.firewall_vm_name}-02-data"
      subnet_id           = azurerm_subnet.subnet_pan_data.id
      enable_backend_pool = true
      lb_backend_pool_id  = azurerm_lb_backend_address_pool.backend_address_pool.id
    },
  ]
  depends_on = [module.bootstrap]
}
