locals {
  name = "${var.department}-api-mgmt-${local.env}"
  # platform_api_mgmt_sku = var.env == "prod" ? "Premium_1" : "Developer_1"

  env = (var.env == "aat") ? "stg" : (var.env == "sandbox") ? "sbox" : "${(var.env == "perftest") ? "test" : "${var.env}"}"

  department = var.department == "sds" ? "dtssds" : "dcdcft"

  acmekv = var.department == "sds" ? "dtssds" : "dcdcftapps"

  criticality = {
    sbox      = "Low"
    aat       = "High"
    stg       = "High"
    prod      = "High"
    prod-int  = "High"
    ithc      = "Medium"
    test      = "Medium"
    perftest  = "Medium"
    demo      = "Medium"
    dev       = "Low"
    ptl       = "High"
    preview   = "Low"
    ldata     = "High"
    sandbox   = "Low"
    nle       = "High"
    nonprod   = "Medium"
    nonprodi  = "Medium"
    ptlsbox   = "Low"
    sbox-int = "Low"
  }

  env_mapping = {
    production  = ["ptl", "prod", "prod-int"]
    development = ["dev", "preview"]
    staging     = ["ldata", "stg", "aat", "nle", "nonprod", "nonprodi"]
    testing     = ["test", "perftest"]
    sandbox     = ["sandbox", "sbox", "ptlsbox", "sbox-int"]
    demo        = ["demo"]
    ithc        = ["ithc"]
  }


  acmedcdcftapps = {
    sbox = {
      subscription = "b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb"
    }
  }

  acmedtssdsapps = {
    sbox = {
      subscription = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
  }

  palo_env_mapping = {
    sbox    = ["sbox"]
    nonprod = ["demo", "ithc", "test"]
    prod    = ["prod", "stg"]
  }

  palo_ip_addresses = {
    sbox = {
      addresses = "10.10.200.37,10.10.200.38"
    },
    nonprod = {
      addresses = "10.11.72.37,10.11.72.38"
    },
    prod = {
      addresses = "10.11.8.37,10.11.8.38"
    }
  }
}

provider "azurerm" {
  alias                      = "acmedcdcftapps"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.department == "sds" ? local.acmedtssdsapps[local.env].subscription : local.acmedcdcftapps[local.env].subscription
}