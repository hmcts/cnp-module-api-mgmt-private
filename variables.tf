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

variable "trigger_migration" {
  default = false
}

variable "trigger_migration_temp_pip" {
  default = false
}

variable "temp_subnet_address_prefixes" {
  type = string
  default = ""

  validation {
    condition = var.temp_subnet_address_prefixes != null || var.temp_subnet_address_prefixes != ""
    error_message = "Temporary subnet adress prefix cannot be left null or empty"
  }
}
