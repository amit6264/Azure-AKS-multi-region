variable "frontdoor_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "Premium_AzureFrontDoor"
}

variable "origin_hostnames" {
  type = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
