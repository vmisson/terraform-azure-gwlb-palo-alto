variable "location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type    = string
  default = "palo-alto-aglb"
}

variable "vnet_security_name" {
  type    = string
  default = "security-vnet-01"
}

variable "vnet_security_address_space" {
  type    = string
  default = "10.123.0.0/24"
}

variable "firewall_vm_name" {
  type    = string
  default = "fwvm"
}

variable "allow_inbound_mgmt_ips" {
  default = ["1.1.1.1"]
  type    = list(string)

  validation {
    condition     = length(var.allow_inbound_mgmt_ips) > 0
    error_message = "At least one address has to be specified."
  }
}

variable "common_vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "byol"
  type        = string
}

variable "common_vmseries_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "latest"
  type        = string
}

variable "common_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = ""
  type        = string
}

variable "avzones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "enable_zones" {
  type    = bool
  default = true
}