output "paloalto_vmseries_01_dns" {
  value = "https://${azurerm_public_ip.fw01_mgmt_pip_01.fqdn}"
}

output "paloalto_vmseries_02_dns" {
  value = "https://${azurerm_public_ip.fw02_mgmt_pip_01.fqdn}"
}

output "paloalto_username" {
  value = var.username
}

output "paloalto_password" {
  value     = coalesce(var.password, random_password.password.result)
  sensitive = true
}