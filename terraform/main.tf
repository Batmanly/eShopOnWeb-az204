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
  source              = "./modules/awapp"
  for_each            = var.AWAPP_OBJECTS
  name                = join("", [lower(var.PREFIX), each.key, local.YEAR, lower(var.ENV)])
  resource_group_name = module.RG.name
  location            = module.ASP[each.value.service_plan_key].location
  service_plan_id     = module.ASP[each.value.service_plan_key].id
  dotnet_version      = each.value.dotnet_version
  app_settings        = each.value.app_settings
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
