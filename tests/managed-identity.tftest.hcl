mock_provider "azurerm" {
  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/api-management"
    }
  }

  mock_data "azurerm_user_assigned_identity" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/named-identity"
      client_id = "00000000-0000-0000-0000-000000000002"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/apim"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/apim"
    }
  }

  mock_resource "azurerm_route_table" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/apim"
    }
  }

  mock_resource "azurerm_api_management" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/apim"
      identity = {
        principal_id = "5317151b-61e6-4959-8e08-66bb198eb7b3"
        tenant_id    = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
      }
    }
  }

  mock_resource "azurerm_api_management_logger" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/apim/loggers/apim"
    }
  }
}

mock_provider "azurerm" {
  alias = "acmedcdcftapps"

  mock_data "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/certificates"
    }
  }
}

mock_provider "azapi" {}

override_data {
  target = data.azurerm_key_vault_certificate.certificate[0]
  values = {
    secret_id = "https://certificates.vault.azure.net/secrets/wildcard/123456"
    version   = "123456"
  }
}

override_module {
  target = module.application_insights
  outputs = {
    id                = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.Insights/components/apim"
    connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000003"
  }
}

variables {
  environment                    = "sbox"
  department                     = "sps"
  virtual_network_name           = "test-vnet"
  virtual_network_resource_group = "test-rg"
  virtual_network_type           = "Internal"
  sku_name                       = "Developer"
  common_tags                    = {}
  custom_gateway_hostnames       = [{ host_name = "sandbox.api.hmcts.net" }]
}

run "sps_provider_version" {
  command = plan

  module {
    source = "./tests/fixtures/provider-versions"
  }
}

run "system_identity_default" {
  command = apply

  assert {
    condition     = azurerm_api_management.apim.identity[0].type == "SystemAssigned" && length(azurerm_api_management.apim.identity[0].identity_ids) == 0
    error_message = "Default callers must retain only the system-assigned identity."
  }

  assert {
    condition     = length(azurerm_role_assignment.apim) == 1 && azurerm_role_assignment.apim[0].principal_id == azurerm_api_management.apim.identity[0].principal_id
    error_message = "Default callers must retain the system identity's certificate role."
  }
}

run "additional_identity_preserves_system_access" {
  command = apply

  variables {
    additional_user_assigned_managed_identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/token-translation",
      "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/token-translation"
    ]
  }

  assert {
    condition     = azurerm_api_management.apim.identity[0].type == "SystemAssigned, UserAssigned"
    error_message = "Additional identities must not disable the system-assigned identity."
  }

  assert {
    condition = azurerm_api_management.apim.identity[0].identity_ids == toset([
      "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/token-translation"
    ])
    error_message = "Attach exactly the requested identities, without duplicates."
  }

  assert {
    condition     = azurerm_api_management.apim.identity[0].principal_id == "5317151b-61e6-4959-8e08-66bb198eb7b3"
    error_message = "Combined mode must use the mocked system principal."
  }

  assert {
    condition     = length(azurerm_role_assignment.apim) == 1 && azurerm_role_assignment.apim[0].principal_id == azurerm_api_management.apim.identity[0].principal_id && azurerm_role_assignment.apim[0].role_definition_name == "Key Vault Secrets User"
    error_message = "Combined mode must retain the system identity's certificate role."
  }

  assert {
    condition     = alltrue([for gateway in azurerm_api_management_custom_domain.api-management-custom-domain.gateway : gateway.ssl_keyvault_identity_client_id == null])
    error_message = "Additional identities must not change the gateway certificate identity."
  }

  assert {
    condition     = azurerm_role_assignment.apim_app_insights.principal_id == azurerm_api_management.apim.identity[0].principal_id
    error_message = "Monitoring must continue to use the system identity."
  }
}

run "named_identity_compatibility" {
  command = apply

  variables {
    user_assigned_managed_identity_name           = "named-identity"
    user_assigned_managed_identity_resource_group = "test-rg"
  }

  assert {
    condition     = azurerm_api_management.apim.identity[0].type == "UserAssigned" && azurerm_api_management.apim.identity[0].identity_ids == toset([data.azurerm_user_assigned_identity.uami[0].id])
    error_message = "Existing named-identity callers must retain user-assigned-only mode."
  }

  assert {
    condition     = length(azurerm_role_assignment.apim) == 0 && alltrue([for gateway in azurerm_api_management_custom_domain.api-management-custom-domain.gateway : gateway.ssl_keyvault_identity_client_id == data.azurerm_user_assigned_identity.uami[0].client_id])
    error_message = "Existing named-identity callers must retain their certificate access behaviour."
  }
}

run "named_identity_with_additional_identity" {
  command = apply

  variables {
    user_assigned_managed_identity_name           = "named-identity"
    user_assigned_managed_identity_resource_group = "test-rg"
    additional_user_assigned_managed_identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/token-translation"
    ]
  }

  assert {
    condition     = azurerm_api_management.apim.identity[0].type == "UserAssigned" && length(azurerm_api_management.apim.identity[0].identity_ids) == 2 && contains(azurerm_api_management.apim.identity[0].identity_ids, data.azurerm_user_assigned_identity.uami[0].id)
    error_message = "Additional identities must retain the named identity and user-assigned-only mode."
  }
}

run "invalid_identity_id" {
  command = plan

  variables {
    additional_user_assigned_managed_identity_ids = ["not-an-azure-resource-id"]
  }

  expect_failures = [var.additional_user_assigned_managed_identity_ids]
}
