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
