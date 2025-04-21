output "policy_id" {
  value = azurerm_key_vault_access_policy.kv_policy.id

}

output "policy_object_id" {
  value = azurerm_key_vault_access_policy.kv_policy.object_id

}
