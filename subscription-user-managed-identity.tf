module "global_user_managed_identity" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name = "id-global"

  role_assignments = {
    "AcrPush" = {
      scope                            = module.containerregistry.resource_id
      role_definition_id_or_name       = "AcrPush"
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
      description                      = local.iac_message

    }
  }

  resource_group_name = module.global_resource_group.resource.name
  location            = module.global_resource_group.resource.location
  isolation_scope     = "Regional"
  tags                = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

moved {
  from = azurerm_user_assigned_identity.environment
  to   = module.global_user_managed_identity.azurerm_user_assigned_identity.this
}
