variable "location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type    = string
  default = "loadbalancer-workload"
}

variable "lb_resource_group_name" {
  type    = string
  default = "palo-alto-aglb"
}

variable "lb_name" {
  type    = string
  default = "security-lb-01"
}
