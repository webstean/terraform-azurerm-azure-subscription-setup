
module "azure_msdn_subscription_setup" {
  source           = "webstean/azure-subscription-setup/azurerm"
  version          = "~> 0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  ## Location (must be one of: "australiasoutheast", "australiaeast", "australiacentral", "australiacentral2", "centralindia", "westus3")
  location = "australiaeast"

  ## Change these to match your Unisys MSDN account
  subscription_id          = "3fdbf472-cbf2-43ca-9f61-3c34bdc1397c"
  owner_email              = "email@org.com"                        ## needs to match your organisation account exactly 
  owner_entra_display_name = "Firstname, Lastname"                  ## needs to match your organisation account exactly
  owner_entra_object_id    = "11111111-2222-3333-4444-555555555555" ## needs to match your organisation account exactly

  ## Alerting - suggest you use a non-orgamisation account
  alert_emails      = ["gmail@gmail.com"]
  alert_sms_country = null ## currently getting an error message, than +61 is not supported (when the documentation suggests it should be)
  alert_sms_number  = null

  ## Optional: Peer this environment into an existing Azure vWAN (including the Hub - which should be in the same region as this environment)
  ## If this is a excluded (or set to Null), then this module will create an Azure vWAN and peer the created vNet into a Basic (free) vWAN Hub.
  # virtual_wan_id = "<existing_virtual_wan_id>"
  # virtual_wan_hub_id = "<existing_virtual_wan_hub_id>"
  # virtual_wan_hub_firewall_id = "<existing_virtual_wan_hub_firewall_id>" ## we need the firewall ID to setup the routing intent, to use the vWAN hub.
}
