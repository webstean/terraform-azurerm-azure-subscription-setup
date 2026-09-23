locals {
  aib_name          = "aib"
  aib_name_location = lower("${local.aib_name}-${lower(var.location)}")
  aib_random_suffix = substr(md5(local.aib_name_location), 0, 6)
  aib_name_hostname = lower(substr(replace("cc${local.aib_random_suffix}${local.aib_name_location}", "-", ""), 0, 24))
  aib_enabled       = var.deploy_azure_image_builder

  # Azure Image Builder does not support updating an existing image template (PUT on an
  # existing template returns 409 Conflict). Suffix the template name with a hash of the
  # inputs that define its content so any change forces Terraform to create a new template
  # (and delete the old one) instead of attempting an in-place update.
  image_template_content_hash = substr(md5(jsonencode({
    image_source          = local.aib_image_template_image_source
    customization_steps   = local.aib_image_template_customization_steps
    vm_size               = local.aib_vm_size
    build_timeout_minutes = local.aib_build_timeout_in_minutes
  })), 0, 8)
  image_template_name = "it-${local.aib_name_location}-${local.image_template_content_hash}"

  aib_image_template_image_source = {
    type      = "PlatformImage"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }
  aib_build_timeout_in_minutes = 360
  aib_vm_size                  = "Standard_D2s_v5"
  aib_image_template_customization_steps = [
    {
      type = "PowerShell"
      name = "Marker file"
      inline = [
        "Set-Content -Path 'C:\\aib-marker.txt' -Value \"Built by Azure Image Builder at $(Get-Date -Format o)\"",
        "Get-Content -Path 'C:\\aib-marker.txt'",
      ]
      runElevated = true
      runAsSystem = true
    },
    {
      type           = "WindowsRestart"
      restartTimeout = "5m"
    }
  ]
}

resource "azapi_resource" "vnet" {
  count = local.aib_enabled ? 1 : 0

  name      = "vnet-${local.aib_name_location}"
  parent_id = module.imagebuilder_resource_group.resource_id
  location  = module.imagebuilder_resource_group.resource.location
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  body = {
    properties = {
      addressSpace = { addressPrefixes = ["10.10.0.0/16"] }
      subnets = [
        {
          name = "subnet-build"
          properties = {
            addressPrefix                     = "10.10.0.0/24"
            privateLinkServiceNetworkPolicies = "Disabled"
            serviceEndpoints                  = [{ service = "Microsoft.Storage" }]
          }
        },
        {
          name = "subnet-aci"
          properties = {
            addressPrefix                     = "10.10.1.0/24"
            privateLinkServiceNetworkPolicies = "Disabled"
            delegations = [{
              name       = "aci"
              properties = { serviceName = "Microsoft.ContainerInstance/containerGroups" }
            }]
          }
        }
      ]
    }
  }
  response_export_values = ["properties.subnets"]
  tags                   = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

locals {
  aci_subnet_id   = try("${azapi_resource.vnet[0].id}/subnets/subnet-aci", "")
  build_subnet_id = try("${azapi_resource.vnet[0].id}/subnets/subnet-build", "")
}

# --- Image builder pattern module ---
module "windows-image-builder" {
  count = local.aib_enabled ? 1 : 0

  source           = "Azure/avm-ptn-azureimagebuilder/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name                = local.aib_name_location
  image_template_name = local.image_template_name
  location            = module.imagebuilder_resource_group.resource.location
  parent_id           = module.imagebuilder_resource_group.resource_id

  image_builder_identity_resource_id = module.global_user_managed_identity.resource_id

  compute_gallery_image_definition_name = "windows-2025-devops"
  compute_gallery_image_definitions = {
    windows = {
      name               = "windows-2025-devops"
      os_type            = "Windows"
      os_state           = "Generalized"
      hyper_v_generation = "V2"
      architecture       = "x64"
      identifier = {
        publisher = "devops"
        offer     = "devops_windows"
        sku       = "devops_windows_az"
      }
    }
  }
  image_template_image_source = local.aib_image_template_image_source
  build = {
    enabled                                  = true
    cleanup_gallery_image_version_on_destroy = true
  }
  build_timeout_in_minutes = local.aib_build_timeout_in_minutes
  # Pre-create the staging RG so the image builder identity is granted Contributor
  # before the build starts; avoids "Unauthorized" errors on the auto-created
  # staging storage account (vhds container) under restrictive subscription policies.
  staging_resource_group_resource_id = module.imagebuilder_staging_resource_group.resource.id
  image_template_customization_steps = local.aib_image_template_customization_steps
  vm_profile = {
    vm_size = local.aib_vm_size
    vnet_config = {
      subnet_id                    = local.build_subnet_id
      container_instance_subnet_id = local.aci_subnet_id
    }
  }
  optimize_vm_boot = true
  tags             = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }

  depends_on = [module.global_user_managed_identity]
}

output "image_builder_id" {
  sensitive = false
  value     = try(module.windows-image-builder[0].resource_id, null)
}

output "image_builder_name" {
  sensitive = false
  value     = try(module.windows-image-builder[0].name, null)
}

output "image_builder_location" {
  sensitive = false
  value     = try(module.windows-image-builder[0].resource.location, null)
}

output "image_builder_compute_gallery_id" {
  sensitive = false
  value     = try(module.windows-image-builder[0].compute_gallery_id, null)
}

output "image_builder_managed_identity_principal_id" {
  sensitive = false
  value     = try(module.windows-image-builder[0].image_builder_identity_principal_id, null)
}

output "image_builder_windows_image_template_id" {
  sensitive = false
  value     = try(module.windows-image-builder[0].image_template_id, null)
}

output "image_builder_windows_image_template_name" {
  sensitive = false
  value     = module.windows-image-builder[0].image_template_name
}
