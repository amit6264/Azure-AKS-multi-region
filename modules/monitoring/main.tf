resource "azurerm_log_analytics_workspace" "this" {

  name                = var.log_analytics_name

  location            = var.location

  resource_group_name = var.resource_group_name

  sku                 = "PerGB2018"

  retention_in_days   = 30

  tags = var.tags
}


resource "azurerm_log_analytics_workspace" "this" {

  name                = var.log_analytics_name

  location            = var.location

  resource_group_name = var.resource_group_name

  sku                 = "PerGB2018"

  retention_in_days   = 30

  tags = var.tags
}


resource "azurerm_monitor_workspace" "this" {

  name                = var.monitor_workspace_name

  location            = var.location

  resource_group_name = var.resource_group_name

  tags = var.tags
}


resource "azurerm_dashboard_grafana" "this" {

  name                = var.grafana_name

  location            = var.location

  resource_group_name = var.resource_group_name

  api_key_enabled = true

  deterministic_outbound_ip_enabled = true

  public_network_access_enabled = true

  tags = var.tags
}


resource "azurerm_role_assignment" "grafana_monitor_reader" {

  scope = azurerm_monitor_workspace.this.id

  role_definition_name = "Monitoring Reader"

  principal_id =
  azurerm_dashboard_grafana.this.identity[0].principal_id
}


resource "azurerm_role_assignment" "grafana_log_reader" {

  scope =
  azurerm_log_analytics_workspace.this.id

  role_definition_name = "Log Analytics Reader"

  principal_id =
  azurerm_dashboard_grafana.this.identity[0].principal_id
}



resource "azurerm_dashboard_grafana" "this" {

  name                = var.grafana_name

  location            = var.location

  resource_group_name = var.resource_group_name

  api_key_enabled = true

  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
