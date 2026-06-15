module "resource_groups" {

  source = "./modules/resource-group"

  for_each = var.regions

  name     = "rg-${each.key}-prod"

  location = each.value.location

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Platform    = "AKS"
  }
}

module "network" {

  source = "./modules/network"

  for_each = var.regions

  resource_group_name =
  module.resource_groups[each.key].name

  location = each.value.location

  vnet_name = "vnet-${each.key}"

  vnet_cidr = each.value.vnet_cidr

  aks_subnet_cidr =
  each.value.aks_subnet_cidr

  private_endpoint_subnet_cidr =
  each.value.private_endpoint_subnet_cidr

  firewall_subnet_cidr =
  each.value.firewall_subnet_cidr

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

module "aks" {

  source = "./modules/aks"

  for_each = var.regions

  cluster_name = "aks-${each.key}-prod"

  location = each.value.location

  resource_group_name = module.resource_groups[each.key].name

  subnet_id = module.network[each.key].subnet_id
}
