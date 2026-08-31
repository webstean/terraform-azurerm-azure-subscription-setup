resource "azurerm_role_assignment" "essential_machine_management_administrator" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Essential Machine Management Administrator"
  principal_id         = var.owner_entra_object_id
  description          = local.iac_message
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.owner_entra_object_id
  description          = local.iac_message
}

resource "azurerm_role_assignment" "resource_policy_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Resource Policy Contributor"
  principal_id         = var.owner_entra_object_id
  description          = local.iac_message
}


