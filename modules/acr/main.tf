resource "azurerm_container_registry" "this" {

  name                = var.acr_name

  resource_group_name = var.resource_group_name

  location            = var.location

  sku                 = "Premium"

  admin_enabled       = false

  public_network_access_enabled = false

  anonymous_pull_enabled = false

  network_rule_bypass_option = "None"

  tags = var.tags
}

resource "azurerm_container_registry_replication" "asia" {

  name                  = "eastasia"

  location              = "eastasia"

  container_registry_id =
  azurerm_container_registry.this.id
}

resource "azurerm_container_registry_replication" "uae" {

  name                  = "uaenorth"

  location              = "uaenorth"

  container_registry_id =
  azurerm_container_registry.this.id
}

resource "azurerm_private_dns_zone" "acr" {

  name = "privatelink.azurecr.io"

  resource_group_name =
  var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {

  name = "acr-dns-link"

  resource_group_name =
  var.resource_group_name

  private_dns_zone_name =
  azurerm_private_dns_zone.acr.name

  virtual_network_id =
  var.vnet_id
}

resource "azurerm_private_endpoint" "acr" {

  name = "${var.acr_name}-pe"

  location = var.location

  resource_group_name =
  var.resource_group_name

  subnet_id =
  var.private_endpoint_subnet_id

  private_service_connection {

    name = "${var.acr_name}-connection"

    private_connection_resource_id =
    azurerm_container_registry.this.id

    is_manual_connection = false

    subresource_names = [
      "registry"
    ]
  }

  private_dns_zone_group {

    name = "acr-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr.id
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "acr" {

  name = "acr-diagnostics"

  target_resource_id =
  azurerm_container_registry.this.id

  log_analytics_workspace_id =
  var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
  }
}
