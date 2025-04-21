variable "name" {
  description = "The name of the SQL Database"
  type        = string
  
}

variable "location" {
  description = "The location of the SQL Database"
  type        = string
  
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  
}

variable "server_id" {
  description = "The name of the SQL Server"
  type        = string
  
}

variable "collation" {
  description = "The collation of the SQL Database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  
}

variable "license_type" {
  description = "The license type of the SQL Database"
  type        = string
  default     = "LicenseIncluded"
  
}

variable "sku_name" {
  description = "The SKU name of the SQL Database"
  type        = string
  default     = "S0"
  
}

variable "enclave_type" {
  description = "The enclave type of the SQL Database"
  type        = string
  default     = "VBS"
  
}


variable "max_size_gb" {
  description = "The maximum size of the SQL Database in GB"
  type        = number
  default     = 5
  
}
