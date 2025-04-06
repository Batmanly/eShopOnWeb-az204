output "WEB_API_ENDPOINT_URL" {
  value = module.AWAPP["aspapinorth"].default_hostname

}

output "WEB_WEST_ENDPOINT_URL" {
  value = module.AWAPP["aspwebwest"].default_hostname

}


output "WEB_NORTH_ENDPOINT_URL" {
  value = module.AWAPP["aspwebnorth"].default_hostname

}

output "TRAFFIC_MANAGER_FQDN" {
  value = module.TRAF.fqdn
}

resource "local_file" "WEB_API" {
  content = templatefile("${path.module}/templates/api_appsettings.json.tpl",
    {
      API_URL = module.AWAPP["aspapinorth"].default_hostname
      WEB_URL = module.TRAF.fqdn
    }
  )
  filename = "${path.module}/../src/PublicApi/appsettings.json"
}

resource "local_file" "WEB_APP" {
  content = templatefile("${path.module}/templates/web_appsettings.json.tpl",
    {
      API_URL = module.AWAPP["aspapinorth"].default_hostname
    }
  )
  filename = "${path.module}/../src/Web/appsettings.json"
}
