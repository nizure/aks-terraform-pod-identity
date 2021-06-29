data "azurerm_resource_group" "aks_node_rg" {
  name = module.aks.node_resource_group
}

resource "azurerm_user_assigned_identity" "podIdentity" {
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  name                = "${var.env}podid"
  tags                = var.tags
  depends_on          = [module.aks]
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_reader" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "Reader"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

# resource "azurerm_role_assignment" "network_contributor" {
#   scope                = module.vnet.vnet_id
#   role_definition_name = "Network Contributor"
#   principal_id         = module.aks.system_assigned_identity.0.principal_id
# }

resource "azurerm_role_assignment" "vm_contributor" {
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name             = "Virtual Machine Contributor"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "all_mi_operator" {
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = module.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true

}

resource "azurerm_role_assignment" "mi_operator" {
  scope                = azurerm_user_assigned_identity.podIdentity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_identity.0.object_id
}

resource "helm_release" "aad_pod_identity_release" {
  name       = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart      = "aad-pod-identity"
  namespace  = "kube-system"
  values = [
    <<-EOF
    azureIdentities:
    - name: "${azurerm_user_assigned_identity.podIdentity.name}"
      resourceID: "${azurerm_user_assigned_identity.podIdentity.id}"
      clientID: "${azurerm_user_assigned_identity.podIdentity.client_id}"
      binding:
        name: "${azurerm_user_assigned_identity.podIdentity.name}-identity-binding"
        selector: "${var.aad_pod_id_binding_selector}"
    EOF
  ]
}