resource "azurerm_kubernetes_cluster" "this" {

  name                = var.cluster_name

  location            = var.location

  resource_group_name = var.resource_group_name

  dns_prefix          = var.cluster_name

  default_node_pool {

    name       = "system"

    vm_size    = "Standard_D2s_v5"

    node_count = 2

    vnet_subnet_id = var.subnet_id

  }

  identity {

    type = "SystemAssigned"

  }

  network_profile {

    network_plugin = "azure"

  }

}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {

  name                  = "apps"

  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vm_size               = "Standard_D4s_v5"

  node_count            = 2

}
