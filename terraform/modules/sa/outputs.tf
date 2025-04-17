output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.sa.name

}

output "primary_blob_connection_string" {
  description = "The primary blob connection string for the storage account."
  value       = azurerm_storage_account.sa.primary_blob_connection_string
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account."
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.sa.primary_access_key

}

output "primary_file_endpoint" {
  description = "The primary file endpoint for the storage account."
  value       = azurerm_storage_account.sa.primary_file_endpoint
}

output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.sa.id

}
output "primary_web_endpoint" {
  description = "The primary web endpoint for the storage account."
  value       = azurerm_storage_account.sa.primary_web_endpoint
}
output "primary_queue_endpoint" {
  description = "The primary queue endpoint for the storage account."
  value       = azurerm_storage_account.sa.primary_queue_endpoint
}


output "connection_string" {
  description = "The connection string for the storage account."
  value       = azurerm_storage_account.sa.primary_blob_connection_string

}
