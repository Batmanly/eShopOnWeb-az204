variable "location" {
  description = "The Azure location where the storage account will be created."
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group where the storage account will be created."
  type        = string
}

variable "name" {
  description = "The name of the storage account. Must be between 3 and 24 characters in length and use numbers and lower-case letters only."
  type        = string
}
variable "account_tier" {
  description = "The performance tier of the storage account. Default is 'Standard'."
  type        = string
  default     = "Standard"
}
variable "account_replication_type" {
  description = "The replication type of the storage account. Default is 'LRS'."
  type        = string
  default     = "LRS"
}
