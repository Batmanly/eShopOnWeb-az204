variable "name" {
  description = "The name of the SQL Server"
  type        = string

}

variable "location" {
  description = "The location of the SQL Server"
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string

}

variable "offer_type" {
  description = "The offer type of the SQL Server"
  type        = string

  default = "Standard"
}


variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled"
  type        = bool

  default = true

}

variable "geo_location" {
  description = "The geo location of the SQL Server"
  type = list(object({
    location          = string
    failover_priority = number
  }))

  default = [
    {
      location          = "eastus"
      failover_priority = 1
    }
  ]

}

variable "identity_id" {
  description = "The ID of the User Assigned Identity"
  type        = string
}
