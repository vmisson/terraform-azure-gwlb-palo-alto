# You can uncomment this resource if you need the marketplace agreement
# resource "azurerm_marketplace_agreement" "paloaltonetworks" {
#   publisher = "paloaltonetworks"
#   offer     = "vmseries-flex"
#   plan      = "byol"
# }

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}