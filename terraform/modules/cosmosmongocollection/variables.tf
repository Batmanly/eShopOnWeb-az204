variable "name" {
  description = "The name of the Cosmos DB collection"
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string

}

variable "account_name" {
  description = "The name of the Cosmos DB account"
  type        = string

}

variable "database_name" {
  description = "The name of the Cosmos DB database"
  type        = string

}

variable "shard_key" {
  description = "The shard key for the Cosmos DB collection"
  type        = string
  default     = "OrderId"

}
