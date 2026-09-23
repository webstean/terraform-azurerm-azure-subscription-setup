locals {
  aib_name          = "aib"
  aib_name_location = lower("${local.aib_name}-${lower(var.location)}")
  aib_random_suffix = substr(md5(local.aib_name_location), 0, 6)
  aib_name_hostname = lower(substr(replace("cc${local.aib_random_suffix}${local.aib_name_location}", "-", ""), 0, 24))
}

resource "azapi_resource" "vnet" {
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
  aci_subnet_id   = "${azapi_resource.vnet.id}/subnets/subnet-aci"
  build_subnet_id = "${azapi_resource.vnet.id}/subnets/subnet-build"
}

# --- Image builder pattern module ---
module "image-builder" {
  source           = "Azure/avm-ptn-azureimagebuilder/azurerm"
  version          = "~>0.0, < 1.0"
  enable_telemetry = var.enable_telemetry

  name      = local.aib_name_location
  location  = module.imagebuilder_resource_group.resource.location
  parent_id = module.imagebuilder_resource_group.resource_id

  compute_gallery_image_definition_name = "windows-2025-devops"
  compute_gallery_image_definitions = {
    windows = {
      name    = "windows-2025-devops"
      os_type = "Windows"
      identifier = {
        publisher = "devops"
        offer     = "devops_windows"
        sku       = "devops_windows_az"
      }
    }
  }
  image_template_image_source = {
    type      = "PlatformImage"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }
  build                    = { enabled = true }
  build_timeout_in_minutes = 360
  # Pre-create the staging RG so the image builder identity is granted Contributor
  # before the build starts; avoids "Unauthorized" errors on the auto-created
  # staging storage account (vhds container) under restrictive subscription policies.
  staging_resource_group_name = "rg-${local.aib_name_location}-staging"
  image_template_customization_steps = [
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
  vm_profile = {
    vm_size = "Standard_D2s_v5"
    vnet_config = {
      subnet_id                    = local.build_subnet_id
      container_instance_subnet_id = local.aci_subnet_id
    }
  }
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

output "image_builder_id" {
  sensitive = false
  value     = module.image-builder.resource_id
}

output "image_builder_name" {
  sensitive = false
  value     = module.image-builder.name
}

output "image_builder_location" {
  sensitive = false
  value     = module.imagebuilder_resource_group.resource.location
}

output "image_builder_compute_gallery_id" {
  sensitive = false
  value     = module.image-builder.compute_gallery_id
}

output "image_builder_image_builder_identity_principal_id" {
  sensitive = false
  value     = module.image-builder.image_builder_identity_principal_id
}



