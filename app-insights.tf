module "application_insights" {
  source = "git::https://github.com/hmcts/terraform-module-application-insights?ref=main"

  env     = var.env
  product = var.product
  name    = "${var.department}-api-mgmt"

  resource_group_name = var.virtual_network_resource_group

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.apim
  to   = module.application_insights.azurerm_application_insights.this
}
