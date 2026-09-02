module "global_log_analytics_workspace" {
  source           = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name                                      = "law-global"
  resource_group_name                       = module.global_resource_group.name
  location                                  = module.global_resource_group.location
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_daily_quota_gb    = 5
  log_analytics_workspace_retention_in_days = 30 ## free

  log_analytics_workspace_identity = {
    type = "SystemAssigned"
    #identity_ids = [azurerm_user_assigned_identity.environment.id]
  }

  /*
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = "Monitoring Metrics Publisher"
      principal_id               = azurerm_user_assigned_identity.environment.principal_id
      description                = local.iac_message
    }
    role_assignment_2 = {
      role_definition_id_or_name = "Log Analytics Reader"
      principal_id               = azurerm_user_assigned_identity.environment.principal_id
      description                = local.iac_message
    }
    role_assignment_3 = {
      role_definition_id_or_name = "Log Analytics Contributor"
      principal_id               = azurerm_user_assigned_identity.environment.principal_id
      description                = local.iac_message
    }
  }
*/
  #log_analytics_workspace_tables_update = {
  #  for name in local.law_basic_table_names : name => {
  #    name = name
  #    plan = "Basic"
  #  }
  #}

  lock = (tobool(var.data_pii) || tobool(var.data_phi) || tobool(var.deploy_private_endpoints)) ? {
    kind = "CanNotDelete"
  } : null
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
  depends_on = [
    module.global_resource_group
  ]
}

resource "azurerm_monitor_diagnostic_setting" "subscription1" {
  name                       = "Log-Metrics-${data.azurerm_subscription.current.display_name}-to-Azure-Monitor"
  target_resource_id         = var.subscription_id
  log_analytics_workspace_id = module.global_log_analytics_workspace.resource_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "subscription2" {
  name                       = "Audit-${data.azurerm_subscription.current.display_name}-to-Azure-Monitor"
  target_resource_id         = var.subscription_id
  log_analytics_workspace_id = module.global_log_analytics_workspace.resource_id

  enabled_log {
    category_group = "audit"
  }
}

