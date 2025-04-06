variable "PREFIX" {
  description = "Prefix of the resources"
  type        = string
  default     = "AZ204"
}

variable "ENV" {
  type        = string
  description = "Suffix of the resources"
  default     = "DEV"
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default     = "northeurope"
}

variable "subscription_id" {
  description = "The azure subscription ID"
  type        = string
}

variable "ASP_OBJECTS" {
  type = map(object({
    location = string
    os_type  = string
    sku_name = string
  }))
}

variable "AWAPP_OBJECTS" {
  type = map(object({
    dotnet_version   = string
    service_plan_key = string
  }))
}

variable "AWAPPSLOT_OBJECTS" {
  type = map(object({
    name             = string
    service_plan_key = string
    dotnet_version   = string
  }))

}


variable "TRAF_ENDPOINT_OBJECTS" {
  type = map(object({
    endpoint_key = string
  }))
}
