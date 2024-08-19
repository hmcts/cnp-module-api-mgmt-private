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
name = string
address_prefix = string
next_hop_type = string
next_hop_in_ip_address = string
}))
default = []
}

variable "aks_subscription_id" {
  type        = string
  description = "The AKS subscription id for the environment.  Set by pipeline."
}

variable "apim_suffix" {
  type        = string
  description = "The suffix to use for the APIM name.  If not set then the environment name will be used."
  default     = ""
}

variable "product" {
  type        = string
  description = "The value of the product variable that is defined in the Jenkinsfile.  Set by pipeline."
}

variable "component" {
  type        = string
  description = "The value of the component variable that is defined in the Jenkinsfile.  Set by pipeline."
}
