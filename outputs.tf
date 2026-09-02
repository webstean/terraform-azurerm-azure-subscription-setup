# Outputs

output "data_pii" {
  description = "Whether the data contains personally identifiable information (PII)."
  sensitive   = false
  value       = var.data_pii
}

output "data_phi" {
  description = "Whether the data contains protected health information (PHI)."
  sensitive   = false
  value       = var.data_phi
}

output "deploy_private_endpoints" {
  description = "Whether to deploy private endpoints."
  sensitive   = false
  value       = var.deploy_private_endpoints
}

output "location" {
  description = "The location of the resources."
  sensitive   = false
  value       = var.location
}

output "subscription_id" {
  description = "The subscription ID of the Azure resources."
  sensitive   = false
  value       = var.subscription_id
}

output "owner_email" {
  description = "The email of the resource owner."
  sensitive   = false
  value       = var.owner_email
}

output "owner_entra_display_name" {
  description = "The display name of the owner's Entra ID account."
  sensitive   = false
  value       = var.owner_entra_display_name
}

output "owner_entra_object_id" {
  description = "The object ID of the owner's Entra ID account."
  sensitive   = false
  value       = var.owner_entra_object_id
}

output "container_registry_id" {
  description = "The ID of the Azure Container Registry."
  sensitive   = false
  value       = try(module.containerregistry.resource_id, "")
}

output "container_registry_url" {
  description = "The URL of the Azure Container Registry."
  sensitive   = false
  value       = try(format("https://%s", module.containerregistry.login_server), "")
}

output "automation_account_id" {
  description = "The ID of the Azure Automation Account."
  sensitive   = false
  value       = try(azurerm_automation_account.this.id, "")
}

output "automation_account_name" {
  description = "The name of the Azure Automation Account."
  sensitive   = false
  value       = try(azurerm_automation_account.this.name, "")
}

output "virtual_wan_id" {
  description = "The ID of the Azure Virtual WAN."
  sensitive   = false
  value       = try(azurerm_virtual_wan.this[0].id, var.virtual_wan_id)
}
