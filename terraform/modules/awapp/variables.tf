variable "name" {
  description = "The Web APP name"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name that will contain Web APP"
  type        = string
}

variable "location" {
  description = "The location where Web app will be located"
  type        = string
}

variable "service_plan_id" {
  description = "The ASP ID , where web app will be runnning"
  type        = string
}

variable "dotnet_version" {
  description = "The dotnet core version"
  type        = string
  default     = "v9.0"

}

variable "app_settings" {
  description = "The application settings"
  type        = map(string)
}

variable "identity_ids" {
  description = "The identity ids"
  type        = list(string)
  default     = []
}
