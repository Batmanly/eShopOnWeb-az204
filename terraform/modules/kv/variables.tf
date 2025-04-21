variable "name" {
  description = "The name of the Key Vault."
  type        = string
  
}

variable "location" {
  description = "The location where the Key Vault should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Key Vault should be created."
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure subscription."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault. Default is 'standard'."
  type        = string
  default     = "premium"
}