variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string

}

variable "tenant_id" {
  description = "The tenant ID of the Azure subscription"
  type        = string

}

variable "object_id" {
  description = "The object ID of the user or service principal"
  type        = string

}

variable "key_permissions" {
  description = "The key permissions for the access policy"
  type        = list(string)
  default     = ["Get"]
}
variable "secret_permissions" {
  description = "The secret permissions for the access policy"
  type        = list(string)
  default     = ["Get"]
}

variable "certificate_permissions" {
  description = "The certificate permissions for the access policy"
  type        = list(string)
  default     = ["Get"]
}