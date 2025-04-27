resource "azurerm_servicebus_queue" "sbq" {
  name         = var.name
  namespace_id = var.namespace_id

  partitioning_enabled                    = var.partitioning_enabled
  duplicate_detection_history_time_window = "PT10M"
}
