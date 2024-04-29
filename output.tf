output "name" {
  value = data.azurerm_api_management.apim.name
}

output "temp_pub_id" {
  value = azurerm_public_ip.pip_test.id
}
