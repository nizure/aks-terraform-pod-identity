module "vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_prefix]
  subnet_prefixes     = [var.aks_subnet_address_prefix]
  subnet_names        = ["aks-subnet"]
  #   subnet_prefixes     = [var.aks_subnet_address_prefix, var.gateway_subnet_address_prefix, var.admin_subnet_address_prefix]
  #   subnet_names        = ["aks-subnet", "gateway-subnet", "admin-subnet"]

  tags = {
    environment = var.env
  }
  depends_on = [azurerm_resource_group.rg]
}