resource "azurerm_windows_web_app_slot" "awappslot" {
  name           = var.name
  app_service_id = var.app_service_id

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }
  }
  app_settings = var.app_settings

}
