
resource "azurerm_resource_group" "billing" {
  name     = "rg-billing-${lower(var.location)}"
  location = var.location

  tags = locals.tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring-${lower(var.location)}"
  location = var.location

  tags = locals.tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

resource "azurerm_monitor_action_group" "alertme" {
  name                = "azure-health-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  short_name          = "AzureAlerts" ## can only be 12 character long

  email_receiver {
    name                    = var.alert_name
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
  tags = locals.tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health_incidents" {
  name                = "alrt-service-health-incidents"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  scopes              = [data.azurerm_subscription.current.id]
  description         = "** Azure Service Health incident **"
  enabled             = true

  criteria {
    category = "ServiceHealth"

    service_health {
      events = [
        "Incident"
      ]

      locations = var.locations_tomonitor
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alertme.id
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health_maintenance" {
  name                = "alrt-service-health-maintenance"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Azure planned maintenance affecting this subscription."
  enabled             = true

  criteria {
    category = "ServiceHealth"

    service_health {
      events = [
        "Maintenance"
      ]

      locations = var.locations_tomonitor
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alertme.id
  }
}

locals {
  service_health_alerts = {
    incidents = {
      name        = "alrt-service-health-incidents"
      description = "Azure Service Health incidents"
      events      = ["Incident"]
    }

    maintenance = {
      name        = "alrt-service-health-maintenance"
      description = "Azure planned maintenance"

      events = ["Maintenance"]
    }

    advisory = {
      name        = "alrt-service-health-advisory"
      description = "Azure Service Health advisories and action-required events."
      events      = ["Informational", "ActionRequired"]
    }
  }

  service_health_locations = var.locations_tomonitor
}

resource "azurerm_monitor_activity_log_alert" "service_health_advisory" {
  name                = "alrt-service-health-advisory"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Azure Service Health advisories and informational events."
  enabled             = true

  criteria {
    category = "ServiceHealth"

    service_health {
      events = [
        "Informational",
        "ActionRequired"
      ]

      locations = var.locations_tomonitor
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alertme.id
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  for_each = local.service_health_alerts

  name                = each.value.name
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = each.value.description
  enabled             = true

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = each.value.events
      locations = local.service_health_locations
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.service_health.id
  }
}
