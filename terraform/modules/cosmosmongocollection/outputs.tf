output "name" {
  description = "Name"
  value       = azurerm_cosmosdb_mongo_collection.mongodbcollection.name

}


output "id" {
  description = "ID"
  value       = azurerm_cosmosdb_mongo_collection.mongodbcollection.id

}
output "database_name" {
  description = "Database Name"
  value       = azurerm_cosmosdb_mongo_collection.mongodbcollection.database_name

}

output "account_name" {
  description = "Account Name"
  value       = azurerm_cosmosdb_mongo_collection.mongodbcollection.account_name

}
