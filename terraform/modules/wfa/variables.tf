variable "location" {
  description = "The Azure location where the storage account will be created."
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group where the storage account will be created."
  type        = string
}

variable "name" {
  description = "The name of Azure Function APP"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account. Must be between 3 and 24 characters in length and use numbers and lower-case letters only."
  type        = string
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "The storage account name must be between 3 and 24 characters long and can only contain lower-case letters and numbers."
  }

}


variable "storage_account_access_key" {
  description = "The access key for the storage account."
  type        = string

}

variable "service_plan_id" {
  description = "The ID of the service plan to use for the function app."
  type        = string
}

variable "app_settings" {
  description = "A map of app settings to configure for the function app."
  type        = map(string)
  default     = {}
}
