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

variable "migration_variables" {
  description = "Migration related variables"
  type = object({
    trigger_migration            = optional(bool, false)
    trigger_migration_temp_pip   = optional(bool, false)
    temp_subnet_address_prefixes = optional(string, "")
  })

  validation {
    condition = var.migration_variables.trigger_migration == true ? (length(var.migration_variables.temp_subnet_address_prefixes) > 0 &&
    var.migration_variables.temp_subnet_address_prefixes != null) : true
    error_message = "Temporary subnet adress prefix cannot be empty or null"
  }
}
