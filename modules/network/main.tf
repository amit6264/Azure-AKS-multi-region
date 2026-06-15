resource "azurerm_virtual_network" "this" {

  name                = var.vnet_name

  location            = var.location

  resource_group_name = var.resource_group_name

  address_space       = [var.vnet_cidr]

  tags = var.tags
}

resource "azurerm_subnet" "aks" {

  name                 = "aks-subnet"

  resource_group_name  = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "private_endpoint" {

  name                 = "private-endpoint-subnet"

  resource_group_name  = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes     = [var.private_endpoint_subnet_cidr]

  private_endpoint_network_policies = "Disabled"
}


resource "azurerm_subnet" "firewall" {

  name                 = "AzureFirewallSubnet"

  resource_group_name  = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_network_security_group" "this" {

  name                = "${var.vnet_name}-nsg"

  location            = var.location

  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "allow_vnet" {

  name                        = "AllowVnet"

  priority                    = 100

  direction                   = "Inbound"

  access                      = "Allow"

  protocol                    = "*"

  source_port_range           = "*"

  destination_port_range      = "*"

  source_address_prefix       = "VirtualNetwork"

  destination_address_prefix  = "VirtualNetwork"

  resource_group_name         = var.resource_group_name

  network_security_group_name =
  azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "deny_internet" {

  name                        = "DenyInternet"

  priority                    = 200

  direction                   = "Inbound"

  access                      = "Deny"

  protocol                    = "*"

  source_port_range           = "*"

  destination_port_range      = "*"

  source_address_prefix       = "Internet"

  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name

  network_security_group_name =
  azurerm_network_security_group.this.name
}

resource "azurerm_route_table" "this" {

  name                = "${var.vnet_name}-rt"

  location            = var.location

  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_route" "default" {

  name = "default-route"

  resource_group_name = var.resource_group_name

  route_table_name = azurerm_route_table.this.name

  address_prefix = "0.0.0.0/0"

  next_hop_type = "Internet"
}

resource "azurerm_subnet_network_security_group_association" "aks" {

  subnet_id =
  azurerm_subnet.aks.id

  network_security_group_id =
  azurerm_network_security_group.this.id
}

resource "azurerm_subnet_route_table_association" "aks" {

  subnet_id =
  azurerm_subnet.aks.id

  route_table_id =
  azurerm_route_table.this.id
}

resource "azurerm_subnet_network_security_group_association" "pe" {

  subnet_id =
  azurerm_subnet.private_endpoint.id

  network_security_group_id =
  azurerm_network_security_group.this.id
}
