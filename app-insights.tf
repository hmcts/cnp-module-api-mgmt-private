resource "azurerm_application_insights" "apim" {
  name                = local.name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group
  application_type    = "other"
}
