variable "regions" {

  type = map(object({

    location       = string
    vnet_cidr      = string
    subnet_cidr    = string

  }))

}
