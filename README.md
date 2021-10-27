Terraform module to create Azure APIM Instance with Private Endpoint
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_azurerm.acmedcdcftapps"></a> [azurerm.acmedcdcftapps](#provider\_azurerm.acmedcdcftapps) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_api_management_api.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api) | resource |
| [azurerm_api_management_api_operation.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_operation) | resource |
| [azurerm_api_management_api_policy.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_policy) | resource |
| [azurerm_api_management_custom_domain.api-management-custom-domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_custom_domain) | resource |
| [azurerm_network_security_group.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.AccessRedisService](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.SyncCounter](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.apimanagement](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.deny](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.loadbalancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.palo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet_network_security_group_association.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_template_deployment.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/template_deployment) | resource |
| [azurerm_api_management.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/api_management) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_certificate.certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate) | data source |
| [azurerm_subnet.api-mgmt-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | n/a | `any` | n/a | yes |
| <a name="input_department"></a> [department](#input\_department) | n/a | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"UK South"` | no |
| <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email) | n/a | `string` | `"apimgmt-noreply@mail.windowsazure.com"` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | n/a | `string` | `"api-mangement@hmcts.net"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | n/a | `string` | `"HMCTS Platform Operations"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_type"></a> [virtual_network_type](#input\_virtual_network_type) | n/a | `any` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `any` | n/a | yes |
| <a name="input_vnet_rg"></a> [vnet\_rg](#input\_vnet\_rg) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | n/a |