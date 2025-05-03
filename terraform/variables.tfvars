location = "northeurope"
ASP_OBJECTS = {
  "aspwebwest" = {
    location = "westeurope"
    os_type  = "Linux"
    sku_name = "S1"
  },
  "aspwebnorth" = {
    location = "northeurope"
    os_type  = "Linux"
    sku_name = "S1"
  },
  "aspapinorth" = {
    location = "northeurope"
    os_type  = "Linux"
    sku_name = "S1"
  },
  "aspapinorthOrderItemReserver" = {
    location = "northeurope"
    os_type  = "Windows"
    sku_name = "Y1"
  },
  "aspapinorthOrderItemSave" = {
    location = "northeurope"
    os_type  = "Windows"
    sku_name = "Y1"
  }
}

AWAPP_OBJECTS = {
  "aspwebwest" = {
    # dotnet_version   = "v9.0"
    service_plan_key  = "aspwebwest"
    docker_image_name = "web:latest"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  },
  "aspwebnorth" = {
    # dotnet_version   = "v9.0"
    service_plan_key  = "aspwebnorth"
    docker_image_name = "web:latest"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  },
  "aspapinorth" = {
    # dotnet_version   = "v9.0"
    service_plan_key  = "aspapinorth"
    docker_image_name = "publicapi:latest"
    app_settings = {
      ASPNETCORE_ENVIRONMENT = "Development"
    }
  }
}

AWAPPSLOT_OBJECTS = {
  "staging" = {
    name              = "staging"
    service_plan_key  = "aspwebnorth"
    docker_image_name = "web:latest"
    # dotnet_version   = "v9.0"
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


ip_address = "78.169.156.21"
