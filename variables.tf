variable "location" {
  default = "UK South"
}

variable "env" {
  type = string
}

variable "vnet_rg" {
  type = string
}

variable "vnet_name" {
  type = string
}
variable "sku_name" {
  type = string
}
variable "virtual_network_type" {
  type = string
}
variable "department" {
  type = string
}
variable "common_tags" {
}

variable "publisher_email" {
  default = "api-mangement@hmcts.net"
}

variable "publisher_name" {
  default = "HMCTS Platform Operations"
}

variable "notification_sender_email" {
  default = "apimgmt-noreply@mail.windowsazure.com"
}


