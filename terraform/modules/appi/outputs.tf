output "name" {
  description = "The name of the Application Insights resource."
  value       = azurerm_application_insights.appi.name

}

output "id" {
  description = "The ID of the Application Insights resource."
  value       = azurerm_application_insights.appi.id

}
output "instrumentation_key" {
  description = "The instrumentation key of the Application Insights resource."
  value       = azurerm_application_insights.appi.instrumentation_key

}

output "connection_string" {
  description = "The connection string of the Application Insights resource."
  value       = azurerm_application_insights.appi.connection_string

}
