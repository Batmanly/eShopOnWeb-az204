variable "name" {
  description = "The name of the Service Bus Queue."
  type        = string

}

variable "namespace_id" {
  description = "The ID of the Service Bus Namespace."
  type        = string

}

variable "partitioning_enabled" {
  description = "Whether partitioning is enabled for the Service Bus Queue."
  type        = bool
  default     = true

}
