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

# variable "dotnet_version" {
#   description = "The dotnet core version"
#   type        = string
#   default     = "v9.0"

# }

variable "app_settings" {
  description = "The application settings"
  type        = map(string)
}

variable "identity_ids" {
  description = "The identity ids"
  type        = list(string)
  default     = []
}

variable "key_vault_reference_identity_id" {
  description = "The identity id that will be used to access the key vault"
  type        = string
}

variable "docker_image_name" {
  description = "The docker image name"
  type        = string

}

variable "docker_image_username" {
  description = "The docker image username"
  type        = string
}
variable "docker_image_password" {
  description = "The docker image password"
  type        = string
}
variable "docker_registry_url" {
  description = "The docker image server url"
  type        = string
}

variable "connection_string" {
  description = "The connection string for the web app"
  type = map(object({
    key   = string
    type  = string
    value = string
  }))
  default = {}
}
