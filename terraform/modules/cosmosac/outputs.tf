output "id" {
  description = "The ID of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.cosmosdb_account.id

}

output "name" {
  description = "The name of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.cosmosdb_account.name

}

output "primary_key" {
  description = "The primary master key of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.cosmosdb_account.primary_key

}
output "endpoint" {
  description = "The primary read-only key of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.cosmosdb_account.endpoint

}

