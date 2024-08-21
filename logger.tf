locals {
  api_mgmt_name = var.apim_suffix == "" ? "cft-api-mgmt-${var.environment}" : "cft-api-mgmt-${var.apim_suffix}"
  api_mgmt_resource_group = "cft-${var.environment}-network-rg"
  api_mgmt_logger_name = "${local.api_mgmt_name}-logger"
  api_mgmt_api_name = "${var.product}-${var.component}-api"
}

# Configure Application insights logging for API
# Terraform doesn't currently provide an azurerm_api_management_logger data source, so instead of using
# the value of an output variable for the api_management_logger_id parameter it has to be set explicitly.
resource "azurerm_api_management_api_diagnostic" "api_mgmt_api_diagnostic" {
  identifier               = "applicationinsights"
  api_management_logger_id = azurerm_api_management_logger.apim.id
  api_management_name      = local.api_mgmt_name
  api_name                 = local.api_mgmt_api_name
  resource_group_name      = local.api_mgmt_resource_group

  sampling_percentage       = 100.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "error"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 8192
    headers_to_log = concat(
      ["content-type",
        "content-length"],
        var.sdt_headers ?
        ["soapaction",
        "URI-PATH-AGW",
        "X-ARR-ClientCertSub-AGW"] : []
    )
  }

  frontend_response {
    body_bytes = 8192
  }
}

resource "azurerm_api_management_logger" "apim" {
  name                = "${local.name}-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.virtual_network_resource_group
  resource_id         = module.application_insights.id

  application_insights {
    instrumentation_key = module.application_insights.instrumentation_key
  }
}