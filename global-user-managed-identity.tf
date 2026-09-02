module "global_user_managed_identity" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name = "id-global"

  resource_group_name = module.global_resource_group.resource.name
  location            = module.global_resource_group.resource.location
  isolation_scope     = "Regional"
  tags                = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

moved {
  from = azurerm_user_assigned_identity.environment
  to   = module.global_user_managed_identity.azurerm_user_assigned_identity.this
}
