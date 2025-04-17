output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_container.sac.name

}

output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_container.sac.id
}
