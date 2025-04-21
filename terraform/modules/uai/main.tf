resource "azurerm_user_assigned_identity" "uai" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}
