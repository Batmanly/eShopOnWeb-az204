resource "azurerm_traffic_manager_azure_endpoint" "endpoint" {
  name                 = var.name
  profile_id           = var.profile_id
  always_serve_enabled = true
  target_resource_id   = var.target_resource_id
  weight               = 100
}
