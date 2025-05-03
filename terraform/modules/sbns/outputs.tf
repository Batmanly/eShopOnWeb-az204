output "id" {
  value = azurerm_servicebus_namespace.sbns.id

}
output "name" {
  value = azurerm_servicebus_namespace.sbns.name
}

output "endpoint" {
  value = azurerm_servicebus_namespace.sbns.endpoint

}

output "default_primary_connection_string" {
  value = azurerm_servicebus_namespace.sbns.default_primary_connection_string
}
output "default_secondary_connection_string" {
  value = azurerm_servicebus_namespace.sbns.default_secondary_connection_string
}

