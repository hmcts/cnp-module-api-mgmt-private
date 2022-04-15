resource "azurerm_application_insights" "apim" {
  name                = local.name
  location            = azurerm_resource_group.example.location
  resource_group_name = var.location
  application_type    = "other"
}

resource "azurerm_api_management_logger" "apim" {
  name                = "${local.name}-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim.name
  resource_id         = azurerm_application_insights.apim.id

  application_insights {
    instrumentation_key = azurerm_application_insights.apim.instrumentation_key
  }
}