variable "name" {
  description = "The name of the Service Bus Namespace."
  type        = string

}

variable "location" {
  description = "The location where the Service Bus Namespace should be created."
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Service Bus Namespace."
  type        = string

}
