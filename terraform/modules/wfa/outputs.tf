output "name" {
  description = "The name of the storage account."
  value       = azurerm_windows_function_app.wfa.name

}

output "id" {
  description = "The ID of the storage account."
  value       = azurerm_windows_function_app.wfa.id

}

output "default_hostname" {
  description = "The default hostname of the storage account."
  value       = azurerm_windows_function_app.wfa.default_hostname

}
