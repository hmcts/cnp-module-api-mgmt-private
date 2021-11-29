resource "azurerm_route_table" "route_table" {
  name                = "${local.name}-route-table"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group
}

resource "azurerm_route" "default_route" {
  name                   = var.route_name
  route_table_name       = azurerm_route_table.route_table.name
  resource_group_name    = var.virtual_network_resource_group
  address_prefix         = var.route_address_prefix
  next_hop_type          = var.route_next_hop_type
  next_hop_in_ip_address = var.route_next_hop_in_ip_address
}

resource "azurerm_route" "azure_control_plane" {
  name                = "azure-control-plane"
  route_table_name    = azurerm_route_table.route_table.name
  resource_group_name = var.virtual_network_resource_group
  address_prefix      = "51.145.56.125/32"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "api-mgmt-subnet" {
  subnet_id      = data.azurerm_subnet.api-mgmt-subnet.id
  route_table_id = azurerm_route_table.route_table.id
}
