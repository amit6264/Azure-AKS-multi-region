resource "azurerm_kubernetes_cluster" "this" {

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = var.dns_prefix

  sku_tier = "Standard"

  private_cluster_enabled = true

  azure_policy_enabled = true

  oidc_issuer_enabled = true

  workload_identity_enabled = true

  image_cleaner_enabled = true

  local_account_disabled = true

  default_node_pool {

    name = "system"

    vm_size = "Standard_D4s_v5"

    node_count = 3

    vnet_subnet_id = var.aks_subnet_id

    type = "VirtualMachineScaleSets"

    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {

    network_plugin = "azure"

    network_policy = "azure"

    outbound_type = "loadBalancer"

    service_cidr = "172.16.0.0/16"

    dns_service_ip = "172.16.0.10"
  }

  oms_agent {

    log_analytics_workspace_id =
    var.log_analytics_workspace_id
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {

  name = "apps"

  kubernetes_cluster_id =
  azurerm_kubernetes_cluster.this.id

  vm_size = "Standard_D4s_v5"

  node_count = 3

  vnet_subnet_id = var.aks_subnet_id

  mode = "User"

  enable_auto_scaling = true

  min_count = 3

  max_count = 10
}
