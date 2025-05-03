locals {
  YEAR = "2025"
}

module "RG" {
  source   = "./modules/rg"
  location = var.location
  name     = join("-", [var.PREFIX, "RG", local.YEAR, var.ENV])
}

module "ASP" {
  source              = "./modules/asp"
  for_each            = var.ASP_OBJECTS
  name                = join("", [lower(var.PREFIX), each.key, local.YEAR, lower(var.ENV)])
  resource_group_name = module.RG.name
  location            = each.value.location
  sku_name            = each.value.sku_name
  os_type             = each.value.os_type
}

module "AWAPP" {
  source                          = "./modules/awapp"
  for_each                        = var.AWAPP_OBJECTS
  name                            = join("", [lower(var.PREFIX), each.key, local.YEAR, lower(var.ENV)])
  resource_group_name             = module.RG.name
  location                        = module.ASP[each.value.service_plan_key].location
  service_plan_id                 = module.ASP[each.value.service_plan_key].id
  dotnet_version                  = each.value.dotnet_version
  key_vault_reference_identity_id = module.UAI.id
  app_settings = merge(
    each.value.app_settings,
    each.key == "aspapinorth" ? { "APPINSIGHTS_INSTRUMENTATIONKEY" = module.APPI.instrumentation_key } : {},
    // OrderItemsReserverUrl
    each.key == "aspwebnorth" ? { "OrderItemsReserverUrl" = "https://${module.WFAOrderItemReserver.default_hostname}/api/OrderItemsReserverServiceBus" } : {},
    each.key == "aspwebwest" ? { "OrderItemsReserverUrl" = "https://${module.WFAOrderItemReserver.default_hostname}/api/OrderItemsReserverServiceBus" } : {},
    each.key == "aspwebwest" ? { "OrderItemsSaveUrl" = "https://${module.WFAOrderItemSave.default_hostname}/api/OrderItemSave" } : {},
    each.key == "aspwebnorth" ? { "OrderItemsSaveUrl" = "https://${module.WFAOrderItemSave.default_hostname}/api/OrderItemSave" } : {},
    # access connection strings from key vault via references
    {
      "ConnectionStrings:CatalogConnection"  = "@Microsoft.KeyVault(SecretUri=${module.KV.vault_uri}secrets/sql-connection-string-catalog)"
      "ConnectionStrings:IdentityConnection" = "@Microsoft.KeyVault(SecretUri=${module.KV.vault_uri}secrets/sql-connection-string-identity)"
    },
    { "AZURE_CLIENT_ID" = module.UAI.client_id },
    { "KeyVaultName" = module.KV.name },
    { "keyVaultReferenceIdentity" = module.UAI.id },
    { "ServiceBusConnectionString" = module.SBNS.default_primary_connection_string },
    { "ServiceBusQueueName" = module.SBQ.name },

    # { "ConnectionStrings:CatalogConnection" = "Server=${module.SQLServer.fqdn};Database=${module.SQLDBIdentity.name};User Id=${module.SQLServer.administrator_login};Password=${random_password.sql_admin_password.result};" },
    # { "ConnectionStrings:IdentityConnection" = "Server=${module.SQLServer.fqdn};Database=${module.SQLDBCatalog.name};User Id=${module.SQLServer.administrator_login};Password=${random_password.sql_admin_password.result};" },
  )
  identity_ids = [module.UAI.id]
}

module "AWAPPSLOT" {
  source         = "./modules/awappslot"
  for_each       = var.AWAPPSLOT_OBJECTS
  name           = each.value.name
  app_service_id = module.AWAPP[each.value.service_plan_key].id
  dotnet_version = each.value.dotnet_version
  app_settings   = each.value.app_settings
}

resource "azurerm_monitor_autoscale_setting" "amass" {
  name                = "AutoScaleForWebAPI"
  resource_group_name = module.RG.name
  location            = module.RG.location
  # target_resource_id  = azurerm_service_plan.appserviceplan.id
  target_resource_id = module.ASP["aspapinorth"].id

  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 4
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = module.ASP["aspapinorth"].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = module.ASP["aspapinorth"].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 20
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

module "TRAF" {
  source              = "./modules/traf"
  name                = join("-", [var.PREFIX, local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  relative_name       = join("", [lower(var.PREFIX), local.YEAR, lower(var.ENV)])

}

module "TRAF_ENDPOINT" {
  source             = "./modules/traf_endpoint"
  profile_id         = module.TRAF.id
  for_each           = var.TRAF_ENDPOINT_OBJECTS
  target_resource_id = module.AWAPP[each.key].id
  name               = each.key

}

module "LOG" {
  source              = "./modules/log"
  name                = join("-", [var.PREFIX, "LOG", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "APPI" {
  source              = "./modules/appi"
  name                = join("-", [var.PREFIX, "APPINS", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location
  application_type    = "web"
  workspace_id        = module.LOG.id
}


module "SA" {
  source                   = "./modules/sa"
  name                     = lower(join("", [var.PREFIX, "STORAGE", local.YEAR, var.ENV]))
  resource_group_name      = module.RG.name
  location                 = module.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "WFAOrderItemReserver" {
  source                     = "./modules/wfa"
  name                       = join("-", [var.PREFIX, "WFA", "OrderItemReserver", local.YEAR, var.ENV])
  resource_group_name        = module.RG.name
  location                   = module.RG.location
  storage_account_name       = module.SA.name
  storage_account_access_key = module.SA.primary_access_key
  service_plan_id            = module.ASP["aspapinorthOrderItemReserver"].id
  app_settings = {
    "application_insights_connection_string" = module.APPI.connection_string
    "application_insights_key"               = module.APPI.instrumentation_key
    "ServiceBusConnectionString"             = module.SBNS.default_primary_connection_string
    "ServiceBusQueueName"                    = module.SBQ.name
    "LogicAppTriggerUrl"                     = module.LOGICAPP.access_endpoint
  }
}

module "WFAOrderItemSave" {
  source                     = "./modules/wfa"
  name                       = join("-", [var.PREFIX, "WFA", "OrderItemSave", local.YEAR, var.ENV])
  resource_group_name        = module.RG.name
  location                   = module.RG.location
  storage_account_name       = module.SA.name
  storage_account_access_key = module.SA.primary_access_key
  service_plan_id            = module.ASP["aspapinorthOrderItemSave"].id
  app_settings = {
    "application_insights_connection_string" = module.APPI.connection_string
    "application_insights_key"               = module.APPI.instrumentation_key
    "CosmosMongoDbConnection"                = module.COSMOSACC.primary_mongodb_connection_string
    "DatabaseName"                           = module.cosmosmongodb.name
    "CollectionName"                         = module.COSMOSMONGODB_COLLECTION.name
    "ShardKey"                               = "OrderId"
  }
}

module "SAC" {
  source                = "./modules/sac"
  name                  = "orders"
  container_access_type = "private"
  storage_account_id    = module.SA.id
}

module "UAI" {
  source              = "./modules/uai"
  name                = join("-", [var.PREFIX, "UAI", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location

}

module "KV" {
  source              = "./modules/kv"
  name                = join("-", [var.PREFIX, "KV", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

}

module "KV_POLICY" {
  source                  = "./modules/kvpolicy"
  key_vault_id            = module.KV.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  key_permissions         = ["Get", "List", "Delete", "Create"]
  secret_permissions      = ["Get", "Set", "Delete", "List", "Purge"]
  certificate_permissions = ["Get"]

}

module "KV_POLICY_UAI" {
  source                  = "./modules/kvpolicy"
  key_vault_id            = module.KV.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = module.UAI.principal_id
  key_permissions         = ["Get", "List", "Delete", "Create"]
  secret_permissions      = ["Get", "Set", "Delete", "List", "Purge"]
  certificate_permissions = ["Get"]

}


resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}

module "SQLServer" {
  source                       = "./modules/sqlserver"
  name                         = lower(join("", [var.PREFIX, "SQL", local.YEAR, var.ENV]))
  resource_group_name          = module.RG.name
  location                     = module.RG.location
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result

}

module "SQLDBCatalog" {
  source              = "./modules/sqldatabase"
  name                = lower(join("", [var.PREFIX, "dbcatalog", local.YEAR, var.ENV]))
  server_id           = module.SQLServer.id
  resource_group_name = module.RG.name
  location            = module.RG.location
}

module "SQLDBIdentity" {
  source              = "./modules/sqldatabase"
  name                = lower(join("", [var.PREFIX, "dbidentity", local.YEAR, var.ENV]))
  server_id           = module.SQLServer.id
  resource_group_name = module.RG.name
  location            = module.RG.location
}


module "SQLDB_FIREWALL" {
  source           = "./modules/sqldbfirewall"
  name             = lower(join("", [var.PREFIX, "FW", local.YEAR, var.ENV]))
  server_id        = module.SQLServer.id
  start_ip_address = var.ip_address
  end_ip_address   = var.ip_address
}

module "SQLDB_FIREWALL_AZURE_RESOURCES" {
  source           = "./modules/sqldbfirewall"
  name             = lower(join("", [var.PREFIX, "FW", local.YEAR, var.ENV, "AZURE"]))
  server_id        = module.SQLServer.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


module "COSMOSACC" {
  source              = "./modules/cosmosac"
  name                = lower(join("", [var.PREFIX, "COSMOS", local.YEAR, var.ENV]))
  resource_group_name = module.RG.name
  location            = module.RG.location
  identity_id         = module.UAI.id
}

module "cosmosmongodb" {
  source              = "./modules/cosmosmongodb"
  name                = lower(join("", [var.PREFIX, "COSMOS", local.YEAR, var.ENV]))
  resource_group_name = module.RG.name
  account_name        = module.COSMOSACC.name
}

module "COSMOSMONGODB_COLLECTION" {
  source              = "./modules/cosmosmongocollection"
  name                = lower(join("", [var.PREFIX, "collection", local.YEAR, var.ENV]))
  resource_group_name = module.RG.name
  account_name        = module.COSMOSACC.name
  database_name       = module.cosmosmongodb.name
  shard_key           = "OrderId"

}


resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = module.KV.id
  depends_on   = [module.SQLServer, module.KV_POLICY]
}

# store connection string in key vault
resource "azurerm_key_vault_secret" "sql_connection_string_identity" {
  name         = "sql-connection-string-identity"
  value        = "Server=${module.SQLServer.fqdn};Database=${module.SQLDBIdentity.name};User Id=${module.SQLServer.administrator_login};Password=${random_password.sql_admin_password.result};"
  key_vault_id = module.KV.id
  depends_on   = [module.SQLDBIdentity, module.KV_POLICY]
}

resource "azurerm_key_vault_secret" "sql_connection_string_catalog" {
  name         = "sql-connection-string-catalog"
  value        = "Server=${module.SQLServer.fqdn};Database=${module.SQLDBCatalog.name};User Id=${module.SQLServer.administrator_login};Password=${random_password.sql_admin_password.result};"
  key_vault_id = module.KV.id
  depends_on   = [module.SQLDBCatalog, module.KV_POLICY]
}


resource "null_resource" "database_setup" {
  provisioner "local-exec" {
    command = <<EOT

    # execute init.sql
    sqlcmd -S ${module.SQLServer.fqdn} -d ${module.SQLDBIdentity.name} -U ${module.SQLServer.administrator_login} -P '${random_password.sql_admin_password.result}' -I -i ../src/Web/AppIdentityDbContext.sql
    sqlcmd -S ${module.SQLServer.fqdn} -d ${module.SQLDBCatalog.name} -U ${module.SQLServer.administrator_login} -P '${random_password.sql_admin_password.result}' -I -i ../src/Web/CatalogContext.sql

    EOT

  }
  depends_on = [
    module.SQLDBIdentity,
    module.SQLDBCatalog,
    module.SQLServer,
    azurerm_key_vault_secret.sql_admin_password
  ]
}

module "SBNS" {
  source              = "./modules/sbns"
  name                = join("-", [var.PREFIX, "SBNS", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location
  sku                 = "Standard"

}

module "SBQ" {
  source               = "./modules/sbq"
  name                 = join("-", [var.PREFIX, "Orders", "Queue", local.YEAR, var.ENV])
  namespace_id         = module.SBNS.id
  partitioning_enabled = true
}

module "LOGICAPP" {
  source              = "./modules/logicapp"
  name                = join("-", [var.PREFIX, "LogicApp", local.YEAR, var.ENV])
  resource_group_name = module.RG.name
  location            = module.RG.location

}

# Create Logic App Workflow
data "local_file" "logic_app" {
  filename = "${path.module}/workflow.json"
}

# Deploy Logic App Workflow
resource "azurerm_resource_group_template_deployment" "logic_app_deployment" {
  resource_group_name = module.RG.name
  deployment_mode     = "Incremental"
  name                = "logic-app-deployment"

  template_content = data.local_file.logic_app.content
  parameters_content = jsonencode({
    "logic_app_name" = { value = module.LOGICAPP.name }
    "location"       = { value = module.LOGICAPP.location }
  })
  depends_on = [module.LOGICAPP]
}
