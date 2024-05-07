// temp resources
// use iaas for cft-api-mgmt-sbox only
data "azurerm_subnet" "temp_subnet" {
  count                = (var.trigger_migration == true ? 1 : 0)
  name                 = "iaas"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

resource "azurerm_subnet_network_security_group_association" "apim_temp" {
  count                     = (var.trigger_migration == true ? 1 : 0)
  subnet_id                 = data.azurerm_subnet.temp_subnet[0].id
  network_security_group_id = azurerm_network_security_group.apim.id
}

resource "azurerm_subnet_route_table_association" "temp_subnet" {
  count          = (var.trigger_migration == true ? 1 : 0)
  subnet_id      = data.azurerm_subnet.temp_subnet[0].id
  route_table_id = azurerm_route_table.route_table.id
}

resource "azurerm_public_ip" "temp_pip" {
  count               = (var.trigger_migration_temp_pip == true ? 1 : 0)
  name                = "${var.department}-api-mgmt-${var.environment}-private-pip-temp"
  resource_group_name = var.virtual_network_resource_group
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "${var.department}-api-mgmt-${var.environment}-pip-temp"
  zones               = local.zones

  tags = var.common_tags
  sku  = "Standard"
}
