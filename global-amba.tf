locals {
  amba_version = "2026-03-06"

  amba_base_url = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/${local.amba_version}/patterns/alz4Subs"

  amba_template_uri = "${local.amba_base_url}/alzArm4Subs.json"
}

resource "azapi_resource" "amba" {
  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "amba-main"
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"

  location = var.location

  body = {
    properties = {
      mode = "Incremental"

      template = jsondecode(
        file("${path.module}/amba/alzArm4Subs.json")
      )

      parameters = jsondecode(
        file("${path.module}/amba/alzArm4Subs.parameters.json")
      )
    }
  }
}

output "amba_deployment_id" {
  description = "AMBA ARM deployment resource ID."
  value       = azapi_resource.amba.id
}

output "amba_template_uri" {
  description = "Pinned AMBA template used by the deployment."
  value       = local.amba_template_uri
}

output "amba_version" {
  description = "AMBA release deployed."
  value       = local.amba_version
}

/*

module "amba_alz" {
  source  = "Azure/avm-ptn-monitoring-amba-alz/azurerm"
  version = "0.3.0"

  location = var.location

  resource_group_name = "rg-amba-${var.location}"

  user_assigned_managed_identity_name = "uami-amba"

  action_group_email = var.monitoring_email

  tags = var.tags
}

*/
