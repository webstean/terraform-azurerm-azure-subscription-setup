# Outputs

output "data_pii" {
  sensitive = false
  value     = var.data_pii
}

output "data_phi" {
  sensitive = false
  value     = var.data_phi
}

output "deploy_private_endpoints" {
  sensitive = false
  value     = var.deploy_private_endpoints
}

output "location" {
  sensitive = false
  value     = var.location
}

output "subscription_id" {
  sensitive = false
  value     = var.subscription_id
}

output "owner_email" {
  sensitive = false
  value     = var.owner_email
}

output "owner_entra_display_name" {
  sensitive = false
  value     = var.owner_entra_display_name
}

output "owner_entra_object_id" {
  sensitive = false
  value     = var.owner_entra_object_id
}

output "containerregistry_id" {
  sensitive = false
  value     = try(module.containerregistry.resource_id, "")
}

output "automationaccount_id" {
  sensitive = false
  value     = try(azurerm_automation_account.this.id, "")
}

output "automationaccount_name" {
  sensitive = false
  value     = try(azurerm_automation_account.this.name, "")
}
