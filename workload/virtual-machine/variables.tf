variable "location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type    = string
  default = "vm-workload"
}

variable "lb_resource_group_name" {
  type    = string
  default = "palo-alto-aglb"
}

variable "lb_name" {
  type    = string
  default = "security-lb-01"
}

variable "vm_name" {
  type    = string
  default = "vm-01"
}

variable "username" {
  type    = string
  default = "azureuser"
}

variable "password" {
  type    = string
  default = ""
}