output "name" {
  value = azurerm_linux_web_app.awapp.name
}


output "id" {
  value = azurerm_linux_web_app.awapp.id
}

output "default_hostname" {
  value = azurerm_linux_web_app.awapp.default_hostname
}

output "identity" {
  value = azurerm_linux_web_app.awapp.identity

}
