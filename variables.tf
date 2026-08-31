// +===========================================================================================================+
// NO defaults

variable "customer" {
  type        = string
  description = <<DESC
The name of the customer (free-text)
DESC
}

variable "prefix" {
  type        = string
  description = <<DESC
A short name (typically 3-8 characters, lowercase) for the customer, used as a prefix for all Azure resource names to ensure global uniqueness.
DESC
}

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

variable "sql_administrator_group_object_id" {
  type        = string
  description = <<DESC
The Entra ID object ID for the SQL administrator group (can be a user or a group)
DESC
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", trimspace(var.sql_administrator_group_object_id)))
    error_message = "The variable 'sql_administrator_group_object_id' must be a valid GUID."
  }
}
variable "sql_administrator_group_display_name" {
  type        = string
  description = <<DESC
Entra ID display name for the user or group that will have SQL Server administrator permissions.
DESC
}

