resource "azurerm_windows_web_app_slot" "awappslot" {
  name           = var.name
  app_service_id = var.app_service_id

  site_config {
    application_stack {
      # dotnet_version = var.dotnet_version
      docker_image_name        = var.docker_image_name
      docker_registry_url      = var.docker_registry_url
      docker_registry_password = var.docker_image_password
      docker_registry_username = var.docker_image_username
    }
  }
  app_settings = var.app_settings

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }
  key_vault_reference_identity_id = var.key_vault_reference_identity_id
  dynamic "connection_string" {
    for_each = var.connection_string
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
}
