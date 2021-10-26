{
      "name": {
        "value": "${name}"
      },
      "location": {
        "value": "${location}"
      },
      "subnetResourceId": {
        "value": "${subnetResourceId}"
      },
      "sku_name": {
        "value": "${sku_name}"
      },
      "publisherEmail": {
        "value": "${publisherEmail}"
      },
     "publisherName": {
        "value": "${publisherName}"
      },
      "notificationSenderEmail": {
        "value": "${notificationSenderEmail}"
      },
      "virtualNetworkType": {
        "value": "${virtualNetworkType}"
      },
    "publicIpAddressId": {
        "value": "${publicIpAddressId}"
    },
    "common_tags": {
        "value": "${common_tags}"
    }
}


    common_tags             = var.common_tags
    name                    = local.name
    location                = var.location
    sku_name                = var.sku_name
    publisherEmail          = var.publisher_email
    publisherName           = var.publisher_name
    subnetResourceId        = data.azurerm_subnet.api-mgmt-subnet.id
    notificationSenderEmail = var.notification_sender_email
    virtualNetworkType      = var.virtualNetworkType
    publicIpAddressId       = azurerm_public_ip.apim.id