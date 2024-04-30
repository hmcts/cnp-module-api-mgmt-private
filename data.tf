data "azurerm_client_config" "current" {}

data "azurerm_api_management" "apim" {
  name                = local.name
  resource_group_name = var.virtual_network_resource_group

  depends_on = [
    azurerm_api_management.apim
  ]
}

# data "azurerm_key_vault" "main" {
#   provider            = azurerm.acmedcdcftapps
#   name                = "acme${local.acmekv}${local.acme_environment}"
#   resource_group_name = "${var.department}-platform-${local.acme_environment}-rg"
# }

# data "azurerm_key_vault_certificate" "certificate" {
#   name         = (local.key_vault_environment == "prod") ? "wildcard-platform-hmcts-net" : "wildcard-${local.key_vault_environment}-platform-hmcts-net"
#   key_vault_id = data.azurerm_key_vault.main.id
# }