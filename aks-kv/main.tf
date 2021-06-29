provider "azurerm" {
  features {}
}

provider "azuread" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-aks-rg"
  location = var.location
  tags = {
    environment = var.env
  }
}

provider "helm" {
  debug = true
  kubernetes {
    # load_config_file       = "false"
    host                   = module.aks.admin_host
    username               = module.aks.admin_username
    password               = module.aks.admin_password
    client_certificate     = base64decode(module.aks.admin_client_certificate)
    client_key             = base64decode(module.aks.admin_client_key)
    cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
  }
}