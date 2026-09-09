locals {
  search_friendly_name      = "Azure AI Search"
  search_name               = "aisearch-free"
  search_name_location      = lower("${local.search_name}-${lower(var.location)}")
  search_name_random_suffix = substr(md5(local.search_name_location), 0, 6)
  search_name_hostname      = lower(substr(replace("f${local.search_name_random_suffix}${local.search_name_location}", "-", ""), 0, 24))
  search_sku                = "free"
  search_semantic_sku       = "free"
}

module "search_keyvault" {
  source           = "Azure/avm-res-keyvault-vault/azurerm"
  version          = "~>0.7, < 1.0"
  enable_telemetry = var.enable_telemetry

  name                            = local.search_name_hostname
  resource_group_name             = module.global_resource_group.name
  location                        = module.global_resource_group.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7
  public_network_access_enabled   = true
  legacy_access_policies_enabled  = false
  enabled_for_deployment          = false ## Whether Azure Virtual Machines are permitted to retrieve certificates
  enabled_for_disk_encryption     = false ## Whether Azure Disk Encryption is permitted to retrieve secrets from the vault
  enabled_for_template_deployment = false ## Whether Azure Resource Manager is permitted to retrieve secrets from the vault
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
    #virtual_network_subnet_ids = [for subnets in azurerm_virtual_network.this.subnet : subnets.id if contains(subnets.service_endpoints, "Microsoft.KeyVault")]
  }

  /*
  diagnostic_settings = {
    diag_setting_1 = {
      name                           = "Logs-Metrics-And-Audit to Azure Monitor ${module.log_analytics_workspace.resource.name}"
      log_groups                     = ["allLogs", "audit"]
      metric_categories              = ["AllMetrics"]
      log_analytics_destination_type = null
      workspace_resource_id          = module.log_analytics_workspace.resource_id
    }
  }
*/
  /*
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = module.global_user_managed_identity.principal_id
      description                = local.iac_message
    }
    role_assignment_2 = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = module.global_user_managed_identity.principal_id
      description                = local.iac_message
    }
  }
*/
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
  #depends_on = [
  #  module.global_user_managed_identity
  #]
}

module "ai_search_service" {
  source           = "Azure/avm-res-search-searchservice/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry ## see variables.tf

  name                = local.search_name_location
  resource_group_name = module.global_resource_group.name
  location            = module.global_resource_group.location

  sku                          = local.search_sku
  semantic_search_sku          = local.search_sku == "free" ? null : local.search_semantic_sku
  local_authentication_enabled = true
  authentication_failure_mode  = "http401WithBearerChallenge"
  network_rule_bypass_option   = "AzureServices"
  replica_count                = 1
  partition_count              = 1

  managed_identities = {
    system_assigned = true
    #    user_assigned_resource_ids = [
    #      module.global_user_managed_identity.resource_id
    #    ]
  }

  role_assignments = {
    #    role_assignment_1 = {
    #      role_definition_id_or_name = "Search Service Contributor"
    #      principal_id               = module.global_user_managed_identity.principal_id
    #      description                = local.iac_message
    #    }
    role_assignment_2 = {
      role_definition_id_or_name = "Search Service Contributor"
      principal_id               = var.owner_entra_object_id
      description                = local.iac_message
    }
  }

  /*
  diagnostic_settings = {
    diag_setting_1 = {
      name              = "Logs-Metrics-And-Audit to Azure Monitor ${module.log_analytics_workspace.resource.name}"
      log_groups        = ["allLogs", "audit"]
      metric_categories = ["AllMetrics"]
      #metric_categories              = ["SLI", "Requests"]
      log_analytics_destination_type = null
      workspace_resource_id          = module.log_analytics_workspace.resource_id
    }
  }
*/
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

output "ai_free_search_id" {
  description = "The ID of the AI search service"
  sensitive   = false
  value       = module.ai_search_service.resource.id
}

output "ai_free_search_endpoint" {
  description = "The endpoint of the AI search service"
  sensitive   = false
  value       = module.ai_search_service.resource.endpoint
}

output "ai_free_search_primary_key" {
  description = "The primary key of the AI search service"
  sensitive   = true
  value       = module.ai_search_service.resource.primary_key
}

output "ai_free_search_secondary_key" {
  description = "The secondary key of the AI search service"
  sensitive   = true
  value       = module.ai_search_service.resource.secondary_key
}

output "ai_free_search_principal_id" {
  description = "The principal ID of the AI search service's system-assigned managed identity"
  sensitive   = true
  value       = module.ai_search_service.resource.identity[0].principal_id
}
