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
      AI                            = "AI"
      Api                           = "Api"
      AppServices                   = "AppServices"
      ContainerRegistry             = "ContainerRegistry"
      KeyVaults                     = "KeyVaults"
      KubernetesService             = "KubernetesService"
      SqlServers                    = "SqlServers"
      SqlServerVirtualMachines      = "SqlServerVirtualMachines"
      StorageAccounts               = "StorageAccounts"
      VirtualMachines               = "VirtualMachines"
      Arm                           = "Arm"
      Dns                           = "Dns"
      OpenSourceRelationalDatabases = "OpenSourceRelationalDatabases"
      Containers                    = "Containers"
      CosmosDbs                     = "CosmosDbs"
      CloudPosture                  = "CloudPosture"
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


