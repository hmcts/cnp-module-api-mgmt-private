data "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "api-management"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}

resource "azurerm_public_ip" "apim" {
  name                = "${var.department}-api-mgmt-${var.env}-private-pip"
  resource_group_name = var.vnet_rg
  location            = var.location
  allocation_method   = "Static"

  tags = var.common_tags
  sku  = "Standard"

}

resource "azurerm_template_deployment" "apim" {
  name                = "core-infra-subnet-apimgmt-${local.env}"
  resource_group_name = var.vnet_rg
  deployment_mode     = "Incremental"
  template_body       = file("${path.module}/arm/apim.json")
  parameters = {
    name                    = local.name
    location                = var.location
    sku_name                = var.sku_name
    publisherEmail          = var.publisher_email
    publisherName           = var.publisher_name
    subnetResourceId        = data.azurerm_subnet.api-mgmt-subnet.id
    notificationSenderEmail = var.notification_sender_email
    virtualNetworkType      = var.virtualNetworkType
    publicIpAddressId       = azurerm_public_ip.apim.id
  }
}

resource "azurerm_role_assignment" "apim" {
  principal_id = data.azurerm_api_management.apim.identity[0]["principal_id"]
  scope        = data.azurerm_key_vault.main.id

  role_definition_name = "Key Vault Secrets User"

  depends_on = [
    azurerm_template_deployment.apim,
    data.azurerm_api_management.apim
  ]
}

resource "azurerm_api_management_custom_domain" "api-management-custom-domain" {
  api_management_id = data.azurerm_api_management.apim.id

  proxy {
    host_name                    = "${var.department}-api-mgmt.${var.env}.platform.hmcts.net"
    negotiate_client_certificate = true
    key_vault_id                 = data.azurerm_key_vault_certificate.certificate.secret_id
  }

  depends_on = [
    azurerm_template_deployment.apim,
    data.azurerm_api_management.apim,
    azurerm_role_assignment.apim
  ]
}
