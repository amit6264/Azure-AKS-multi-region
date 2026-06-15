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
