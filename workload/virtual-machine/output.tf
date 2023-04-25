output "vm_publicip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "vm_username" {
  value = var.username
}

output "vm_password" {
  value     = coalesce(var.password, random_password.password.result)
  sensitive = true
}