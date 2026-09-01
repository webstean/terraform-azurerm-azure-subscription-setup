
variable "subscription_id" {
  type        = string
  description = <<DESC
The Azure subscription ID in which the resources will be deployed.
DESC

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", trimspace(var.subscription_id)))
    error_message = "subscription_id must be a valid GUID."
  }
}

variable "owner_email" {
  type        = string
  description = <<DESC
Email address of the resource owner, used for contact and billing notifications
DESC

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", trimspace(var.owner_email)))
    error_message = "The variable 'owner_email' must be a valid email address."
  }
}

variable "owner_entra_object_id" {
  type        = string
  description = <<DESC
The Entra ID object ID for the owner of this environment
DESC

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", trimspace(var.owner_entra_object_id)))
    error_message = "The variable 'owner_entra_object_id' must be a valid GUID."
  }
}
variable "owner_entra_display_name" {
  type        = string
  description = <<DESC
Display name of the owner in Entra ID for RBAC role assignment and resource access control.
DESC
}

variable "location" {
  type        = string
  description = <<DESC
The Azure region where resources will be deployed.
DESC
  default     = "australiaeast"
  validation {
    condition     = contains(["australiasoutheast", "australiaeast", "australiacentral", "australiacentral2", "perth", "centralindia", "westus3"], lower(trimspace(var.location)))
    error_message = "location must be one of the currently known Azure regions defined in locals.regions."
  }
}

variable "enable_telemetry" {
  type        = bool
  description = <<DESC
This variable controls whether or not the AVM (Azure Verified Modules) telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESC
  default     = false
}

/*
variable "org_shortname" {
  type        = string
  description = "The short name of the organization"
  default     = "andrew"
}
*/

/*
variable "org_longname" {
  type        = string
  description = "The long name of the organization"
  default     = "Andrew Webster"
}
*/

variable "data_pii" {
  type        = bool
  description = <<DESC
If true, this environment contains PII (Personally Identifiable Information) so deploy additional security controls. If false, deploys a non-PII environment.
DESC
  default     = false
}

variable "data_phi" {
  type        = bool
  description = <<DESC
If true, this environment contains PHI (Protected Health Information) so deploy additional security controls. If false, deploys a non-PHI environment.
DESC
  default     = false
}

variable "deploy_private_endpoints" {
  type        = bool
  description = <<DESC
If true, deploys private endpoints for secure access to Azure services. If false, does not deploy private endpoints.
DESC
  default     = false
}

variable "alert_name" {
  type        = string
  description = "The name for alerts"
  default     = "MSDN SubscriptionAlerts"
}

variable "alert_email" {
  type        = string
  description = "The email address for alerts"

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", trimspace(var.alert_email)))
    error_message = "The variable 'alert_email' must be a valid email address."
  }
}

variable "alert_sms_number" {
  type        = string
  description = "The phone number for SMS alerts"
}

variable "alert_sms_country" {
  type        = string
  description = "The country code for SMS alerts"
  default     = "+61"
}

variable "locations_tomonitor" {
  type        = list(string)
  description = "The list of locations to monitor"
  default     = ["australiaeast", "australiasoutheast", "australiacentral", "australiacentral2"]
}
