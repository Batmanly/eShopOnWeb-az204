output "name" {
  value = azurerm_container_registry.acr.name

}
output "location" {
  value = azurerm_container_registry.acr.location
}

output "id" {
  value = azurerm_container_registry.acr.id

}

output "admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  value = azurerm_container_registry.acr.admin_password
}
output "georeplications" {
  value = azurerm_container_registry.acr.georeplications
}
output "login_server" {
  value = azurerm_container_registry.acr.login_server
}
output "sku" {
  value = azurerm_container_registry.acr.sku
}
