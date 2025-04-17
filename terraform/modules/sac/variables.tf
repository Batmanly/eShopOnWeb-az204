variable "name" {
  description = "The name of the Azure Function App"
  type        = string
}

variable "container_access_type" {
  description = "The access type for the storage container. Can be 'private', 'blob', or 'container'."
  type        = string
  default     = "private"

}

variable "storage_account_id" {
  description = "The ID of the storage account."
  type        = string

}
