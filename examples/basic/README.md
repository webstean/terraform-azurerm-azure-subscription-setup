# Setup a single Azure subscription like a MSDN subscription

This module will create a series of low-cost resources, at the subscription level, than can be used accross many environments.

Check out [SARD](https://registry.terraform.io/modules/webstean/sard/azurerm) to create resources for an environment.

```hcl
module "azure_msdn_subscription_setup" {
  source           = "webstean/azure-subscription-setup/azurerm"
  version          = "< 1.0.0"
  enable_telemetry = var.enable_telemetry

  ## Location (must be one of: "australiasoutheast", "australiaeast", "australiacentral", "australiacentral2", "centralindia", "westus3")
  location = "australiaeast"

  ## Change these to match your Unisys MSDN account
  subscription_id          = "3fdbf472-cbf2-43ca-9f61-3c34bdc1397c"
  owner_email              = "email@org.com"                          ## needs to match your organisation account exactly 
  owner_entra_display_name = "Firstname, Lastname"                    ## needs to match your organisation account exactly
  owner_entra_object_id    = "11111111-2222-3333-4444-555555555555"   ## needs to match your organisation account exactly

  ## Alerting - suggest you use a non-organisation account
  alert_emails      = ["gmail@gmail.com"]
  alert_sms_country = null ## currently getting an error message, than +61 is not supported (when the documentation suggests it should be)
  alert_sms_number  = null

  ## Optional: Peer this environment into an existing Azure vWAN (including the Hub - which should be in the same region as this environment)
  ## If this is a excluded (or set to Null), then this module will create an Azure vWAN and peer the created vNet into a Basic (free) vWAN Hub.
  # virtual_wan_id = "<existing_virtual_wan_id>"
  # virtual_wan_hub_id = "<existing_virtual_wan_hub_id>"
  # virtual_wan_hub_firewall_id = "<existing_virtual_wan_hub_firewall_id>" ## we need the firewall ID to setup the routing intent, to use the vWAN hub.
}
```

This will result in the creation of around 16 low-cost resources in your subscription, all within a single Azure resource group.

> [!Note]
> The total cost over a month, should be < $15 USD. If the resources just sit there doing nothing. Of course, if you use them, then there will be more charges.

Here is a examples of the resources that will be created.

- An Azure Container Registry
- An Azure Automation Account
- An Azure Action Group (with the specified email (and phone number (if specified) as the destination for alerts))
- An Azure Managed Identity - permissioned appropriately
- An Azure vWAN (basic SKU, which free), unless you specified an existing
- An Azure Log Analytics Workspace
- An Azure Application Insights (web)
