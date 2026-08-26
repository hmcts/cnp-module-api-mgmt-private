variable "location" {
  default = "uksouth"
}

variable "environment" {}

variable "virtual_network_resource_group" {}

variable "virtual_network_name" {}
variable "sku_name" {}
variable "virtual_network_type" {}
variable "department" {}
variable "common_tags" {}

variable "publisher_email" {
  default = "DTSPlatformOperations@justice.gov.uk"
}

variable "publisher_name" {
  default = "HMCTS Platform Operations"
}

variable "notification_sender_email" {
  default = "apimgmt-noreply@mail.windowsazure.com"
}

variable "route_name" {
  default = "default"
}
variable "route_address_prefix" {
  default = "0.0.0.0/0"
}
variable "route_next_hop_type" {
  default = "VirtualAppliance"
}

variable "route_next_hop_in_ip_address" {
  default = "10.10.1.1"
}

variable "additional_routes_apim" {
  description = "A list of additional route configurations"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "disable_trusted_service_connectivity" {
  description = "Disable Trusted Service Connectivity (Managed Identity over-privileged access) for APIM. Set to true to disable this feature."
  type        = bool
  default     = false
}

variable "user_assigned_managed_identity_name" {
  description = "The name of a User Assigned Managed Identity to assign to the API Management Service. If not provided, only SystemAssigned identity is used."
  type        = string
  default     = null
}

variable "user_assigned_managed_identity_resource_group" {
  description = "The resource group of the User Assigned Managed Identity. Required when user_assigned_managed_identity_name is set."
  type        = string
  default     = null
}

variable "cert_domain" {
  default = "platform"
}

variable "certificate_secret_id" {
  description = "Versionless Key Vault secret ID of the gateway certificate. When set, it is used directly as the custom domain key_vault_id and the department-derived vault/certificate lookup is skipped. The certificate is fetched at runtime via the UAMI, which must have Key Vault Secrets User on the source vault."
  type        = string
  default     = null
}

variable "custom_name" {
  description = "Overrides the derived instance name (department-api-mgmt-environment) used for the APIM service, public IP, NSG, route table and logger. Defaults to null (the derived name). Use when a distinct name is needed — e.g. a second APIM in a department that already owns the derived name. Does not affect department-driven vault/subscription/prefix selection."
  type        = string
  default     = null
}

variable "custom_gateway_hostnames" {
  description = "List of custom gateway hostnames. If not provided, defaults to the standard department-based naming."
  type = list(object({
    host_name                    = string
    negotiate_client_certificate = optional(bool, true)
    default_ssl_binding          = optional(bool, true)
  }))
  default = null
}

variable "sampling_percentage" {
  description = "The sampling percentage for Application Insights. Defaults to null (uses the module default)."
  type        = number
  default     = null
}

variable "app_insights_custom_name" {
  description = "Overrides the derived Application Insights name prefix (department-api-mgmt). The environment suffix is still appended automatically. Defaults to null (the derived name). Use when a distinct name is needed to avoid clashing with other Application Insights resources."
  type        = string
  default     = null
}

variable "enable_access_redis_service_nsg_rule" {
  description = "Controls creation of the AccessRedisService NSG rule (inbound TCP 6381-6383 for internal cache communication between machines/nodes within the APIM deployment)."
  type        = bool
  default     = true
}

variable "enable_sync_counter_nsg_rule" {
  description = "Controls creation of the SyncCounter NSG rule (inbound UDP 4290 for rate-limit counter synchronization between machines/nodes within the APIM deployment)."
  type        = bool
  default     = true
}

variable "enable_loadbalancer_nsg_rule" {
  description = "Controls creation of the loadbalancer NSG rule (inbound TCP from VirtualNetwork)."
  type        = bool
  default     = true
}

variable "custom_nsg_rules" {
  description = "A map of custom NSG rules to apply in addition to the default rules"
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = {}
}

variable "developer_portal" {
  description = "Configuration for the APIM developer portal custom domain and certificate"
  type = object({
    sign_in_enabled = optional(bool, false)
    sign_up = optional(object({
      enabled = bool
      terms_of_service = object({
        consent_required = bool
        show_tos         = bool
        text             = string
      })
    }))
    custom_domain = optional(object({
      fqdn         = string
      key_vault_id = string
      cert_name    = string
    }))
  })
  default = {}
}

variable "management" {
  type = object({
    fqdn         = string
    key_vault_id = string
    cert_name    = string
  })
  default = null
}

variable "apim_diagnostic_settings" {
  description = "Configuration for the APIM Application Insights diagnostic settings"
  type = object({
    sampling_percentage          = optional(number, 100)
    always_log_errors            = optional(bool, true)
    http_correlation_protocol    = optional(string, "W3C")
    verbosity                    = optional(string, "information")
    frontend_request_body_bytes  = optional(number, 0)
    frontend_response_body_bytes = optional(number, 0)
    backend_request_body_bytes   = optional(number, 0)
    backend_response_body_bytes  = optional(number, 0)
  })
  default = {}
}

variable "acme_environment" {
  description = "Allows overriding the environment used for the ACME Key Vault name. If not provided, defaults to the local.acme_environment value."
  type        = string
  default     = null
}

variable "acme_rg_name" {
  description = "Allows overriding the resource group name used for the ACME Key Vault. If not provided, defaults to the local.acme_rg_name value."
  type        = string
  default     = null
}

variable "key_vault_environment" {
  description = "Allows overriding the environment used for the Key Vault certificate name. If not provided, defaults to the local.key_vault_environment value."
  type        = string
  default     = null
}

variable "certificates" {
  description = "A map of certificates to be added to the Root or CertificateAuthority store of the API Management service. Each certificate should be an object with the following attributes: base64 (the base64-encoded certificate), store_name (the store name, e.g., 'Root' or 'CertificateAuthority'), and password (the password for the certificate, if applicable)."
  type = map(object({
    base64     = string
    store_name = optional(string, "Root")
    password   = optional(string, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for cert in values(var.certificates) : contains(["Root", "CertificateAuthority"], cert.store_name)])
    error_message = "All certificates must have a store_name of either 'Root' or 'CertificateAuthority'."
  }
}
