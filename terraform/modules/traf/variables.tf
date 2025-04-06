variable "name" {
  description = "The name of the traffic manager profile"
  type        = string
}


variable "resource_group_name" {
  description = "The resource group name"
  type        = string

}

variable "traffic_routing_method" {
  description = "Traffic routing method"
  type        = string
  default     = "Performance"
}

variable "relative_name" {

  description = "The relative name for DNS"
  type        = string
}
