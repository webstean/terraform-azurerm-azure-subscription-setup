
module "global_resource_group" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name     = "rg-global-${lower(var.location)}"
  location = var.location
  /*
  role_assignments = {
    "sp_roleassignment1" = {
      name                             = uuidv5("url", "${module.environment_resource_group.resource.id}/Contributor/${module.global_user_managed_identity.principal_id}")
      role_definition_id_or_name       = "Contributor"
      principal_id                     = module.global_user_managed_identity.principal_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
      description                      = local.iac_message
    }
  }
*/
  tags = merge(local.temporary_tags, {
    type = "permanent"
  })
}
