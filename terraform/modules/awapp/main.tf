resource "azurerm_windows_web_app" "awapp" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }
  }
  app_settings = var.app_settings

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }
  key_vault_reference_identity_id = var.key_vault_reference_identity_id
}
