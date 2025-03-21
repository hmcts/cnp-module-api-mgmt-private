resource "azurerm_api_management_api" "apim" {
  name                  = "health"
  resource_group_name   = var.virtual_network_resource_group
  api_management_name   = azurerm_api_management.apim.name
  revision              = "1"
  display_name          = "Health Check"
  path                  = "health"
  protocols             = ["http", "https"]
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "apim" {
  operation_id        = "liveness-check"
  api_name            = azurerm_api_management_api.apim.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.virtual_network_resource_group
  display_name        = "Liveness check"
  method              = "GET"
  url_template        = "/liveness"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
    representation {
      content_type = "application/json"
      example {
        name  = "sample value"
        value = "{\"status\": \"Up\"}"
      }
    }
  }

}

resource "azurerm_api_management_api_policy" "apim" {
  api_name            = azurerm_api_management_api.apim.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.virtual_network_resource_group

  xml_content = <<XML
<policies>
    <inbound>
        <mock-response status-code="200" content-type="application/json" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}
