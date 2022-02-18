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

  tags = var.common_tags
  sku  = "Standard"

}

# resource "azurerm_template_deployment" "apim" {
#   name                = "core-infra-subnet-apimgmt-${local.environment}"
#   resource_group_name = var.virtual_network_resource_group
#   deployment_mode     = "Incremental"
#   template_body       = file("${path.module}/arm/apim.json")
#   parameters = {
#     name                    = local.name
#     location                = var.location
#     sku_name                = var.sku_name
#     publisherEmail          = var.publisher_email
#     publisherName           = var.publisher_name
#     subnetResourceId        = data.azurerm_subnet.api-mgmt-subnet.id
#     notificationSenderEmail = var.notification_sender_email
#     virtualNetworkType      = var.virtual_network_type
#     publicIpAddressId       = azurerm_public_ip.apim.id
#     environment             = [for x in keys(local.environment_mapping) : x if contains(local.environment_mapping[x], var.environment)][0]
#     criticality             = local.criticality[var.environment]
#   }
# }

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
  public_ip_address_id = var.sku_name == "Premium" ? azurerm_public_ip.apim.id : null
  sku_name            = local.sku_name

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

  proxy {
    host_name                    = "${var.department}-api-mgmt.${local.key_vault_environment}.platform.hmcts.net"
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
