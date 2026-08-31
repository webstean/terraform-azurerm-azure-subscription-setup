/*
resource "azurerm_security_center_setting" "sentinel" {
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

resource "azurerm_security_center_contact" "security" {
  name  = "ALERT"
  email = var.alert_email
  phone = format("%s-%s", startswith(var.alert_sms_country, "+") ? var.alert_sms_country : "+${var.alert_sms_country}", var.alert_sms_number)

  alert_notifications = true
  alerts_to_admins    = false
}


## Needs Owner permission on subscription
#resource "azurerm_security_center_server_vulnerability_assessments_setting" "security" {
# ## The vulnerability assessment provider to use for virtual machines. The only possible value is MdeTvm.
#  vulnerability_assessment_provider = "MdeTvm"
#}
