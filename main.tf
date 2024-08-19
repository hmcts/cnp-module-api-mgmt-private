locals {
  api_mgmt_name = var.apim_suffix == "" ? "cft-api-mgmt-${var.environment}" : "cft-api-mgmt-${var.apim_suffix}"
  api_mgmt_resource_group = "cft-${var.environment}-network-rg"
  api_mgmt_logger_name = "${local.api_mgmt_name}-logger"
  api_mgmt_api_name = "${var.product}-${var.component}-api"
}

data "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "api-management"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

resource "azurerm_public_ip" "apim" {
  name                = "${var.department}-api-mgmt-${var.environment}-private-pip"
  resource_group_name = var.virtual_network_resource_group
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "${var.department}-api-mgmt-${var.environment}-pip"
  zones               = local.zones

  tags = var.common_tags
  sku  = "Standard"
}

resource "azurerm_api_management" "apim" {
  name                      = local.name
  location                  = var.location
  resource_group_name       = var.virtual_network_resource_group
  publisher_name            = var.publisher_name
  publisher_email           = var.publisher_email
  notification_sender_email = var.notification_sender_email
  virtual_network_type      = var.virtual_network_type

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.api-mgmt-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  zones = local.zones
  public_ip_address_id = azurerm_public_ip.apim.id

  sku_name = local.sku_name

  security {
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled = (var.department == "sds") ? true : false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled = (var.department == "sds") ? true : false
    triple_des_ciphers_enabled                  = (var.department == "sds") ? true : false
  }

  tags = var.common_tags

  depends_on = [
    azurerm_public_ip.apim
  ]
}

resource "azurerm_role_assignment" "apim" {
  principal_id = data.azurerm_api_management.apim.identity[0]["principal_id"]
  scope        = data.azurerm_key_vault.main.id

  role_definition_name = "Key Vault Secrets User"

  depends_on = [
    azurerm_api_management.apim,
    data.azurerm_api_management.apim
  ]
}

# Configure Application insights logging for API
# Terraform doesn't currently provide an azurerm_api_management_logger data source, so instead of using
# the value of an output variable for the api_management_logger_id parameter it has to be set explicitly.
resource "azurerm_api_management_api_diagnostic" "api_mgmt_api_diagnostic" {
  identifier               = "applicationinsights"
  api_management_logger_id = "/subscriptions/${var.aks_subscription_id}/resourceGroups/${local.api_mgmt_resource_group}/providers/Microsoft.ApiManagement/service/${local.api_mgmt_name}/loggers/${local.api_mgmt_logger_name}"
  api_management_name      = local.api_mgmt_name
  api_name                 = local.api_mgmt_api_name
  resource_group_name      = local.api_mgmt_resource_group

  sampling_percentage       = 100.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 8192
    headers_to_log = [
      "content-type",
      "content-length",
      "soapaction",
      "URI-PATH-AGW",
      "X-ARR-ClientCertSub-AGW"
    ]
  }

  frontend_response {
    body_bytes = 8192
  }
}
