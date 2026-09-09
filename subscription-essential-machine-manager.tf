## Global Essential Machine Management User Assigned Identity and Role Assignments
## https://learn.microsoft.com/en-us/azure/azure-arc/servers/essential-machine-management/enrollment

module "global_essential_machine_management_user_assigned_identity" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name = "id-global-essential-machine-management"

  resource_group_name = module.global_resource_group.resource.name
  location            = module.global_resource_group.resource.location
  isolation_scope     = "Regional"
  tags                = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

resource "azurerm_role_assignment" "essential_machine_management_administrator" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Essential Machine Management Administrator"
  principal_id         = module.global_essential_machine_management_user_assigned_identity.principal_id
  description          = local.iac_message
}

resource "azurerm_role_assignment" "essential_machine_management_identity_operator" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.global_essential_machine_management_user_assigned_identity.principal_id
  description          = local.iac_message
}

resource "azurerm_role_assignment" "essential_machine_management_resource_policy_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Resource Policy Contributor"
  principal_id         = module.global_essential_machine_management_user_assigned_identity.principal_id
  description          = local.iac_message
}

## During public preview, the Azure portal is the only supported method for enabling machine management.

