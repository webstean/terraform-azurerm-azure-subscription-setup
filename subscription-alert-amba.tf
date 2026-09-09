locals {
  amba_version             = "2026-03-06"
  amba_base_url            = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/${local.amba_version}/patterns/alz4Subs"
  amba_template_uri        = "${local.amba_base_url}/alzArm4Subs.json"
  amba_resource_group_name = "rg-amba-monitoring-001"
}

resource "azurerm_resource_group" "amba_monitoring" {
  name     = local.amba_resource_group_name
  location = var.location
  tags     = module.global_resource_group.resource.tags
}

resource "azapi_resource" "amba_alerting_reployment_for_subscription" {
  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "amba-main"
  parent_id = "/subscriptions/${var.subscription_id}"

  location = var.location

  depends_on = [azurerm_resource_group.amba_monitoring]

  body = {
    properties = {
      mode = "Incremental"

      templateLink = {
        uri = local.amba_template_uri
      }

      parameters = {
        telemetryOptOut = {
          value = !var.enable_telemetry
        }
        ALZMonitorResourceGroupName = {
          value = local.amba_resource_group_name
        }
        topLevelSubscriptionId = {
          value = var.subscription_id
        }
        ALZMonitorResourceGroupLocation = {
          value = var.location
        }
        ALZMonitorResourceGroupTags = {
          value = module.global_resource_group.resource.tags
        }
        ALZMonitorActionGroupEmail = {
          value = var.alert_email
        }
      }
    }
  }
}

output "amba_deployment_id" {
  description = "AMBA ARM deployment resource ID."
  value       = azapi_resource.amba_alerting_reployment_for_subscription.id
}

output "amba_template_uri" {
  description = "Pinned AMBA template used by the deployment."
  value       = local.amba_template_uri
}

output "amba_version" {
  description = "AMBA ARM template release deployed."
  value       = local.amba_version
}
