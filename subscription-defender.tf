locals {
  security_resource_types = {
    AI = {
      active        = true
      resource_type = "AI"
      subplan       = null
    }
    Api = {
      active        = true
      resource_type = "Api"
      subplan       = null
    }
    AppServices = {
      active        = true
      resource_type = "AppServices"
      subplan       = null
    }
    Arm = {
      active        = true
      resource_type = "Arm"
      subplan       = "PerApiCall"
    }
    Containers = {
      active        = true
      resource_type = "Containers"
      subplan       = null
    }
    ContainerRegistry = {
      active        = true
      resource_type = "ContainerRegistry"
      subplan       = null
    }
    CosmosDbs = {
      active        = true
      resource_type = "CosmosDbs"
      subplan       = null
    }
    Dns = { ## discontinued
      active        = false
      resource_type = "Dns"
      subplan       = null
    }
    KeyVaults = {
      active        = true
      resource_type = "KeyVaults"
      subplan       = null
    }
    KubernetesService = {
      active        = true
      resource_type = "KubernetesService"
      subplan       = null
    }
    OpenSourceRelationalDatabases = {
      active        = true
      resource_type = "OpenSourceRelationalDatabases"
      subplan       = null
    }
    SqlServers = {
      active        = true
      resource_type = "SqlServers"
      subplan       = null
    }
    SqlServerVirtualMachines = {
      active        = true
      resource_type = "SqlServerVirtualMachines"
      subplan       = null
    }
    StorageAccounts = {
      active        = true
      resource_type = "StorageAccounts"
      subplan       = "DefenderForStorageV2"
    }
    VirtualMachines = {
      active        = true
      resource_type = "VirtualMachines"
      subplan       = "P2"
    }
  }
}

resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = { for k, v in local.security_resource_types : k => v if v.active }

  resource_type = each.value.resource_type
  tier          = var.defender_for_cloud_enabled ? "Standard" : "Free"
  subplan       = var.defender_for_cloud_enabled ? each.value.subplan : null
}

resource "azurerm_security_center_subscription_pricing" "cloudposture" {
  count = var.defender_for_cloud_enabled ? 1 : 0

  resource_type = "CloudPosture"
  tier          = "Standard"

  extension {
    name = "ContainerRegistriesVulnerabilityAssessments"
  }

  extension {
    name = "AgentlessVmScanning"
    additional_extension_properties = {
      ExclusionTags = "[]"
    }
  }

  extension {
    name = "AgentlessDiscoveryForKubernetes"
  }

  extension {
    name = "SensitiveDataDiscovery"
  }
}

## https://learn.microsoft.com/en-us/azure/templates/microsoft.security/securityconnectors?pivots=deployment-language-terraform
