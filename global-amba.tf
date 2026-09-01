locals {
  amba_version      = "2026-03-06"
  amba_base_url     = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/${local.amba_version}/patterns/alz4Subs"
  amba_template_uri = "${local.amba_base_url}/alzArm4Subs.json"
}

resource "azapi_resource" "amba_subscription" {
  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "amba-main"
  parent_id = "/subscriptions/${var.subscription_id}"

  location = var.location

  body = {
    properties = {
      mode = "Incremental"

      templateLink = {
        uri = local.amba_template_uri
      }

      parameters = {
        topLevelSubscriptionId = {
          value = var.subscription_id
        }
      }
    }
  }
}

output "amba_deployment_id" {
  description = "AMBA ARM deployment resource ID."
  value       = azapi_resource.amba_subscription.id
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
