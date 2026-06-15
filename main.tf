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


module "acr" {

  source = "./modules/acr"

  acr_name = "globalacrprod001"

  resource_group_name =
  module.shared_rg.name

  location = "westeurope"

  private_endpoint_subnet_id =
  module.network["eu"].private_endpoint_subnet_id

  vnet_id =
  module.network["eu"].vnet_id

  log_analytics_workspace_id =
  module.log_analytics.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}


module "aks" {

  source = "./modules/aks"

  for_each = var.regions

  cluster_name = "aks-${each.key}-prod"

  dns_prefix = "aks-${each.key}"

  location = each.value.location

  resource_group_name =
  module.resource_groups[each.key].name

  aks_subnet_id =
  module.network[each.key].aks_subnet_id

  log_analytics_workspace_id =
  module.log_analytics.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}


resource "azurerm_role_assignment" "acr_pull" {

  for_each = module.aks

  principal_id =
  each.value.kubelet_identity_object_id

  role_definition_name = "AcrPull"

  scope = module.acr.id
}


resource "azurerm_role_assignment" "acr_pull" {

  for_each = module.aks

  principal_id =
  each.value.kubelet_identity_object_id

  role_definition_name = "AcrPull"

  scope = module.acr.id
}

module "keyvault" {

  source = "./modules/keyvault"

  keyvault_name = "kv-prod-global-001"

  resource_group_name = module.shared_rg.name

  location = "westeurope"

  tenant_id = data.azurerm_client_config.current.tenant_id

  private_endpoint_subnet_id =
  module.network["eu"].private_endpoint_subnet_id

  vnet_id =
  module.network["eu"].vnet_id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_role_assignment" "kv_secrets_user" {

  scope = module.keyvault.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = "<managed-identity-object-id>"
}



module "frontdoor" {

  source = "./modules/frontdoor"

  frontdoor_name = "global-frontdoor-prod"

  resource_group_name =
  module.shared_rg.name

  origin_hostnames = {

    eu   = "eu.company.com"

    asia = "asia.company.com"

    me   = "me.company.com"
  }

  tags = {
    Environment = "Production"
  }
}
