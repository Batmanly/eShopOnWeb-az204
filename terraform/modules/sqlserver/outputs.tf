output "name" {
  value = azurerm_mssql_server.sql_server.name

}


output "id" {
  value = azurerm_mssql_server.sql_server.id

}

output "fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name

}

output "administrator_login" {
  value = azurerm_mssql_server.sql_server.administrator_login

}
