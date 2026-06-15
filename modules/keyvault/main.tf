

resource "azurerm_key_vault" "this" {

  name                = var.keyvault_name

  location            = var.location

  resource_group_name = var.resource_group_name

  tenant_id           = var.tenant_id

  sku_name            = "premium"

  enable_rbac_authorization = true

  public_network_access_enabled = false

  soft_delete_retention_days = 90

  purge_protection_enabled = true

  tags = var.tags
}

resource "azurerm_private_dns_zone" "kv" {

  name = "privatelink.vaultcore.azure.net"

  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {

  name = "kv-dns-link"

  resource_group_name = var.resource_group_name

  private_dns_zone_name =
  azurerm_private_dns_zone.kv.name

  virtual_network_id = var.vnet_id
}


resource "azurerm_private_endpoint" "kv" {

  name = "${var.keyvault_name}-pe"

  location = var.location

  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {

    name = "${var.keyvault_name}-connection"

    private_connection_resource_id =
    azurerm_key_vault.this.id

    subresource_names = [
      "vault"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {

    name = "kv-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.kv.id
    ]
  }
}
