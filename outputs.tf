# Outputs

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

output "azure_location_details" {
  description = "Details of the location being used with this subscription."
  sensitive   = false
  value = {
    id            = data.azurerm_location.current.id
    display_name  = data.azurerm_location.current.display_name
    zone_mappings = data.azurerm_location.current.zone_mappings
  }
}
