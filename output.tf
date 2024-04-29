output "name" {
  value = data.azurerm_api_management.apim.name
}

output "temp_pub_id" {
  value = data.azurerm_api_management.pip_test.id
}
