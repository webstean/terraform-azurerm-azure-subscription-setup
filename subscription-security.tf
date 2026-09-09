/*
resource "azurerm_security_center_setting" "this" {
  ## whole subscription level

  ## setting_name - (Required) The setting to manage.
  ## MCAS: Microsoft Cloud App Security
  ## WDATP: Windows Defender ATP
  ##

  ## Possible values are MCAS , WDATP, WDATP_EXCLUDE_LINUX_PUBLIC_PREVIEW, WDATP_UNIFIED_SOLUTION and Sentinel.

  ## MCAS — controls whether Defender for Cloud shares subscription security findings with Microsoft Defender for Cloud Apps (formerly Microsoft Cloud App Security). Enable to surface alerts/security posture data in MCAS/Defender for Cloud Apps.
  ## WDATP — controls integration with Microsoft Defender for Endpoint (formerly Windows Defender ATP). Enabling this lets Defender for Cloud auto-provision the MDE sensor and pull its signals into Defender for Cloud's recommendations/alerts.
  ## WDATP_EXCLUDE_LINUX_PUBLIC_PREVIEW — a scoping flag for the above, specifically excluding Linux machines from that MDE integration during its public preview period.
  ## WDATP_UNIFIED_SOLUTION — opts into the newer "unified" MDE-Defender for Cloud integration solution (the modernized onboarding/data-sharing path Microsoft's been migrating customers toward, superseding the older WDATP mechanism).
  ## Sentinel — controls whether Defender for Cloud alerts/data are shared with Microsoft Sentinel.

  setting_name = "WDATP_UNIFIED_SOLUTION"
  enabled      = true
}
*/

/*
resource "azurerm_security_center_contact" "security" {
  name  = "ALERT"
  email = var.alert_email
  #phone = format("%s-%s", startswith(var.alert_sms_country, "+") ? var.alert_sms_country : "+${var.alert_sms_country}", var.alert_sms_number)

  alert_notifications = true
  alerts_to_admins    = false
  lifecycle {
    create_before_destroy = true
  }
}
*/

## Needs Owner permission on subscription
#resource "azurerm_security_center_server_vulnerability_assessments_setting" "security" {
# ## The vulnerability assessment provider to use for virtual machines. The only possible value is MdeTvm.
#  vulnerability_assessment_provider = "MdeTvm"
#}


### https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/deploy-microsoft-defender-for-cloud-via-terraform/ba-p/3563710
### https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-cloud-security-posture-management

/*
resource "azurerm_subscription_policy_assignment" "mcsb_assignment" {
  name                 = "mcsb"
  display_name         = "Microsoft Cloud Security Benchmark"
  description          = "Microsoft Cloud Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  subscription_id      = var.subscription_id
}
*/

/*
Azure Policy effect quick reference:

addToNetworkGroup
  Adds matching resources to a network group. This effect is available for
  policies that manage Azure Virtual Network Manager network groups.
append
  Adds fields to the resource request during create or update. Use modify
  instead for new policy definitions where possible.
audit
  Allows the request, but records a non-compliant resource for compliance
  reporting.
auditIfNotExists
  Audits the resource when a related resource does not exist or is not
  compliant. Commonly used with an existence condition.
deny
  Rejects create or update requests that match the policy.
denyAction
  Blocks a specified action, such as deleting a resource, when the policy
  rule matches.
deployIfNotExists
  Deploys a related resource or configuration when it does not exist or is
  not compliant. Requires a managed identity and a deployment template.
disabled
  Disables evaluation of the policy rule without removing its assignment.
manual
  Creates a compliance record that must be attested manually.
modify
  Adds, updates, or removes resource properties during create or update.
mutate
  Changes the request or resource using a mutation rule. This effect is
  primarily used with Kubernetes admission control policies.
*/

/*
resource "azurerm_security_center_subscription_pricing" "defender_arm" {
  tier          = var.defender_for_cloud_enabled ? "Standard" : "Free"
  resource_type = "Arm"
  subplan       = "PerApiCall"
}
*/

/*
resource "azurerm_security_center_subscription_pricing" "defender_servers" {
  tier          = var.defender_for_cloud_enabled ? "Standard" : "Free"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}
*/

/*
resource "azurerm_security_center_subscription_pricing" "defender_cspm" {
  tier          = var.defender_for_cloud_enabled ? "Standard" : "Free"
  resource_type = "CloudPosture"
}
*/

/*
resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = var.defender_for_cloud_enabled ? "Standard" : "Free"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}
*/

/*
resource "azapi_resource" "setting_agentless_vm" {
  type = "Microsoft.Security/vmScanners@2022-03-01-preview"
  name = "default"
  parent_id = data.azurerm_subscription.current.id
  body = {
    properties = {
      scanningMode = "Default"
    }
  }
  schema_validation_enabled = false
}
*/

/*
resource "azapi_update_resource" "setting_cspm" {
  type = "Microsoft.Security/pricings@2023-01-01"
  name = "CloudPosture"
  parent_id = var.subscription_id
  body = {
    properties = {
      pricingTier = "Standard"
      extensions = [
         {
             name = "SensitiveDataDiscovery"
             isEnabled = "True"
         },
         {
             name = "ContainerRegistriesVulnerabilityAssessments"
             isEnabled = "True"
         },
         {
             name = "AgentlessDiscoveryForKubernetes"
             isEnabled = "True"
         }
      ]
    }
  }
}
*/
