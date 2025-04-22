output "name" {
  description = "The name of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.uai.name

}

output "id" {
  description = "The ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.uai.id
}


output "principal_id" {
  description = "The principal ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.uai.principal_id

}
output "client_id" {
  description = "The client ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.uai.client_id

}

output "tenant_id" {
  description = "The tenant_id of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.uai.tenant_id

}

