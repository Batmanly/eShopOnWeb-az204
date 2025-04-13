location = "northeurope"
ASP_OBJECTS = {
  "aspwebwest" = {
    location = "westeurope"
    os_type  = "Windows"
    sku_name = "S1"
  },
  "aspwebnorth" = {
    location = "northeurope"
    os_type  = "Windows"
    sku_name = "S1"
  },
  "aspapinorth" = {
    location = "northeurope"
    os_type  = "Windows"
    sku_name = "S1"
  },
}

AWAPP_OBJECTS = {
  "aspwebwest" = {
    dotnet_version   = "v9.0"
    service_plan_key = "aspwebwest"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  },
  "aspwebnorth" = {
    dotnet_version   = "v9.0"
    service_plan_key = "aspwebnorth"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  },
  "aspapinorth" = {
    dotnet_version   = "v9.0"
    service_plan_key = "aspapinorth"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  }
}

AWAPPSLOT_OBJECTS = {
  "staging" = {
    name             = "staging"
    service_plan_key = "aspwebnorth"
    dotnet_version   = "v9.0"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }

  }
}

TRAF_ENDPOINT_OBJECTS = {
  "aspwebwest" = {
    endpoint_key = "aspwebwest"

  },
  "aspapinorth" = {
    endpoint_key = "aspapinorth"

  }
}

