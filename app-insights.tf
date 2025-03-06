module "application_insights" {
  source = "git::https://github.com/hmcts/terraform-module-application-insights?ref=fix-test-app-insight-location"

  env     = local.environment
  product = var.department
  name    = "${var.department}-api-mgmt"
  alert_location = var.alert_location

  resource_group_name = var.virtual_network_resource_group
  application_type    = "other"

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.apim
  to   = module.application_insights.azurerm_application_insights.this
}
