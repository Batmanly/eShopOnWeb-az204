variable "name" {
  description = "The name of the User Assigned Identity."
  type        = string

}

variable "location" {
  description = "The location where the User Assigned Identity should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the User Assigned Identity."
  type        = string
}
