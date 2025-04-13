variable "name" {
  description = "The name of the Application Insights resource."
  type        = string
  
}

variable "location" {
  description = "The location where the Application Insights resource will be created."
  type        = string
  
}
variable "resource_group_name" {
  description = "The name of the resource group where the Application Insights resource will be created."
  type        = string
  
}
variable "workspace_id" {
  description = "The ID of the Log Analytics workspace to link to Application Insights."
  type        = string
  
}

variable "application_type" {
  description = "The type of the Application Insights resource."
  type        = string
  default     = "web"
  
}