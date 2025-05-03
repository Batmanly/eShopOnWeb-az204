variable "name" {
  description = "The name of the Container Registry."
  type        = string
}

variable "location" {
  description = "The location of the Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry."
  type        = string
}

variable "sku" {
  description = "The SKU of the Container Registry."
  type        = string
}

variable "admin_enabled" {
  description = "Whether to enable admin user for the Container Registry."
  type        = bool
}
variable "georeplications" {
  description = "A list of georeplication configurations for the Container Registry."
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
  }))
}
