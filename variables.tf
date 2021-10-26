variable "location" {
  default = "UK South"
}

variable "env" {}

variable "vnet_rg" {}

variable "vnet_name" {}
variable "sku_name" {}
variable "virtualNetworkType" {}
variable "department" {}
variable "common_tags" {}

variable "publisher_email" {
  default = "api-mangement@hmcts.net"
}

variable "publisher_name" {
  default = "HMCTS Platform Operations"
}

variable "notification_sender_email" {
  default = "apimgmt-noreply@mail.windowsazure.com"
}


