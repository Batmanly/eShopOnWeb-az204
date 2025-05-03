output "LogicAppTriggerUrl" {
  value = module.LOGICAPP.access_endpoint

}

output "TF_URL" {
  value = "https://${module.TRAF.fqdn}"

}

