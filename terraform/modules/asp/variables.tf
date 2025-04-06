variable "name" {
  description = "The Service plan name"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group that will contain ASP"
  type        = string
}

variable "location" {
  description = "The location of the ASP will be located"
  type        = string
}


variable "sku_name" {
  description = "Azure service plan size ( SKU )"
  type        = string
}

variable "os_type" {
  description = "OS type that ASP will be created Linux/Windows"
  type        = string
  default     = "Windows"
}
