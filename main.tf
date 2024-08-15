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

resource "azurerm_api_management_custom_domain" "api-management-custom-domain" {
  api_management_id = data.azurerm_api_management.apim.id

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt.platform.hmcts.net" : "${var.department}-api-mgmt.${local.key_vault_environment}.platform.hmcts.net"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt-appgw.platform.hmcts.net" : "${var.department}-api-mgmt-appgw.${local.key_vault_environment}.platform.hmcts.net"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-mtls-api-mgmt-appgw.platform.hmcts.net" : "${var.department}-mtls-api-mgmt-appgw.${local.key_vault_environment}.platform.hmcts.net"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  depends_on = [
    data.azurerm_key_vault_certificate.certificate,
    azurerm_api_management.apim,
    data.azurerm_api_management.apim,
    azurerm_role_assignment.apim
  ]
}

resource "azurerm_api_management_diagnostic" "apim" {
  identifier               = "applicationinsights"
  resource_group_name      = var.virtual_network_resource_group
  api_management_name      = azurerm_api_management.apim.name
  api_management_logger_id = azurerm_api_management_logger.apim.id

  sampling_percentage       = 5.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "error"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
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
