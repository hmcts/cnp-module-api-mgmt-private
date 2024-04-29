output "name" {
  value = data.azurerm_api_management.apim.name
}

output "temp_pipid" {
  value = data.azurerm_api_management.pip_test.id
}