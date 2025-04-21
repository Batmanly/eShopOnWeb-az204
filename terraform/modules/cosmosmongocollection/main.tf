resource "azurerm_cosmosdb_mongo_collection" "mongodbcollection" {
  name                = var.name
  resource_group_name = var.resource_group_name
  account_name        = var.account_name
  database_name       = var.database_name

  default_ttl_seconds = "777"
  shard_key           = var.shard_key
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}
