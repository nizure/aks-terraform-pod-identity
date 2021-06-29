data "azurerm_client_config" "current" {}

# data "azurerm_key_vault" "mkv" {
#   name                = var.kv-name
#   resource_group_name = var.kv-rg

# }

resource "azurerm_key_vault" "mkv" {
  name                = "kv-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
  soft_delete_retention_days = 7

    access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  depends_on = [module.aks]
}

resource "azurerm_role_assignment" "kv" {
  scope                = azurerm_key_vault.mkv.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.podIdentity.principal_id
}

# Install Secrets Store CSI Driver and Azure Provider 

resource "helm_release" "kv_csi" {
  name       = "csi-secrets-provider-azure"
  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
  namespace  = "kube-system"
  depends_on = [module.aks]
}

resource "azurerm_key_vault_access_policy" "mi" {
  key_vault_id       = azurerm_key_vault.mkv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.podIdentity.principal_id
  secret_permissions = ["Get"]
}


resource "azurerm_key_vault_secret" "demo" {
  name         = "demo-secret"
  value        = "demo-value"
  key_vault_id = azurerm_key_vault.mkv.id

}