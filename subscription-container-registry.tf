locals {
  acr_name          = "acr-global"
  acr_name_location = lower("${local.acr_name}-${lower(var.location)}")
  acr_random_suffix = substr(md5(local.acr_name_location), 0, 6)
  acr_name_hostname = lower(substr(replace("c${local.acr_random_suffix}${local.acr_name_location}", "-", ""), 0, 24))
  acr_sku           = "Basic" ## Basic ($0.17 per day, $5.1 per month), Standard ($0.67 cents per day, $20 per month), Premium ($1.7 dollars per day, $51 per month)
}

module "containerregistry" {
  source           = "Azure/avm-res-containerregistry-registry/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry ## see variables.tf

  name                          = local.acr_name_hostname
  resource_group_name           = module.global_resource_group.name
  location                      = module.global_resource_group.location
  sku                           = local.acr_sku
  admin_enabled                 = true ## must be enabled for certain scenarios. See: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?WT.mc_id=Portal-fx&tabs=azure-cli#admin-account
  public_network_access_enabled = true
  quarantine_policy_enabled     = local.acr_sku == "Premium" ? true : false
  retention_policy_in_days      = local.acr_sku == "Premium" ? 14 : null
  anonymous_pull_enabled        = local.acr_sku == "Basic" ? false : true
  zone_redundancy_enabled       = local.acr_sku == "Premium" ? true : false
  data_endpoint_enabled         = local.acr_sku == "Premium" ? true : false

  cache_rules = {
    github = {
      name              = "github-cache"
      source_repository = "ghcr.io/*"
      target_repository = "ghcr/*"
    }
    azureml = {
      name              = "azureml-cache"
      source_repository = "mcr.microsoft.com/azureml/*"
      target_repository = "azureml/*"
    }
    mmlspark = {
      name              = "mmlspark-cache"
      source_repository = "mcr.microsoft.com/mmlspark/*"
      target_repository = "mmlspark/*"
    }
    deployment_environments = {
      name              = "azure-deployment-environments-cache"
      source_repository = "mcr.microsoft.com/deployment-environments/*"
      target_repository = "deployment-environments/*"
    }
    dotnet = {
      name              = "dotnet-cache"
      source_repository = "mcr.microsoft.com/dotnet/*"
      target_repository = "dotnet/*"
    }
    sql = {
      name              = "sql-cache"
      source_repository = "mcr.microsoft.com/azure-databases/*"
      target_repository = "sql/*"
    }
  }

  managed_identities = {
    system_assigned = true
    user_assigned_resource_ids = [
      module.global_user_managed_identity.resource_id
    ]
  }

  georeplications = contains(["premium"], local.acr_sku) ? [
    {
      location                = local.regions[module.global_resource_group.location].default_rep_location
      zone_redundancy_enabled = true
    }
  ] : []


  /*
  diagnostic_settings = {
    diag_setting_1 = {
      name                           = "Logs-Audit-and-Metrics-to-${module.log_analytics_workspace.resource.name}"
      log_groups                     = ["allLogs", "audit"]
      metric_categories              = ["AllMetrics"] ## "SLI", "Requests"
      log_analytics_destination_type = null
      workspace_resource_id          = module.log_analytics_workspace.resource_id
    }
  }
*/

  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "AcrPull"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
      description                      = local.iac_message
    }
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
      description                      = local.iac_message
    }
  }
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
  #lock = (tobool(var.data_pii) || tobool(var.data_phi)) ? {
  #  kind = "CanNotDelete"
  #} : null
  depends_on = [
    module.global_log_analytics_workspace
  ]
}

// Cache will only occur after at least one image pull is complete on the available container image.
// For every new image available, a new image pull must be complete. Artifact cache doesn't automatically pull new tags of images when a new tag is available.
// ## It is on the roadmap but not supported in this release.

### Supported upstreams or login servers for the ACR cache are:
## docker.io,
## dhi.io,
## eu.gcr.io,
## gcr.io,
## ghcr.io,
## quay.io,
## mcr.microsoft.com,
## nvcr.io,
## public.ecr.aws,
## registry.k8s.io,
## registry.redhat.io,
## registry.access.redhat.com.
## *.pkg.dev,

output "container_registry_id" {
  description = "The ID of the Azure Container Registry."
  sensitive   = false
  value       = try(module.containerregistry.resource_id, "")
}

output "container_registry_name" {
  description = "The name of the Azure Container Registry."
  sensitive   = false
  value       = module.containerregistry.name
}

output "container_registry_login_server" {
  description = "The global URL of the login server of the Azure Container Registry."
  sensitive   = false
  value       = try(format("https://%s", module.containerregistry.login_server), "")
}

