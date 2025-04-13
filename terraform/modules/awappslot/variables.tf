variable "name" {
  description = "The Web APP name"
  type        = string
}

variable "app_service_id" {
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
