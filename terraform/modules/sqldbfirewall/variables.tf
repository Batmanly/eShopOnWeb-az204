variable "name" {
  description = "The name of the SQL Database Firewall Rule."
  type        = string

}

variable "server_id" {
  description = "The name of the resource group where the SQL Database Firewall Rule should be created."
  type        = string
}

variable "start_ip_address" {
  description = "IP address range to start the firewall rule."
  type        = string
}


variable "end_ip_address" {
  description = "IP address range to end the firewall rule."
  type        = string

}
