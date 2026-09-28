locals {
  amba_version             = "2026-03-06"
  amba_base_url            = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/${local.amba_version}/patterns/alz4Subs"
  amba_template_uri        = "${local.amba_base_url}/alzArm4Subs.json"
  amba_resource_group_name = "rg-amba-monitoring-001"
}

#import {
#  to = module.amba_resource_group.azapi_resource.this
#  id = "/subscriptions/${var.subscription_id}/resourceGroups/${local.amba_resource_group_name}"
#}

module "amba_resource_group" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name     = local.amba_resource_group_name
  location = var.location
  retry = {
    error_message_regex  = [".*"]
    interval_seconds     = 10
    max_interval_seconds = 180
  }
  tags = merge(local.temporary_tags, {
    type = "permanent"
  })
}

resource "random_id" "amba_deployment" {
  byte_length = 8
}

resource "azapi_resource" "amba_alerting_reployment_for_subscription" {
  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "amba-main-${random_id.amba_deployment.hex}"
  parent_id = "/subscriptions/${var.subscription_id}"

  location = var.location

  depends_on = [module.amba_resource_group]

  body = {
    properties = {
      mode = "Incremental"

      templateLink = {
        uri = local.amba_template_uri
      }

      parameters = {
        telemetryOptOut = {
          value = var.enable_telemetry ? "No" : "Yes"
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
          value = module.amba_resource_group.resource.tags
        }
        ALZMonitorActionGroupEmail = {
          value = [for email in coalesce(var.alert_emails, []) : trimspace(email)]
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
