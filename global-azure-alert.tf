
resource "azurerm_resource_group" "billing" {
  name     = "rg-billing-${lower(var.location)}"
  location = var.location

  tags = local.permanent_tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring-${lower(var.location)}"
  location = var.location

  tags = local.permanent_tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

resource "azurerm_monitor_action_group" "alertme" {
  name                = "azure-health-alert"
  resource_group_name = module.global_resource_group.name
  location            = module.global_resource_group.location
  short_name          = "AzureAlerts" ## can only be 12 character long

  dynamic "email_receiver" {
    for_each = var.alert_email == null ? [] : [var.alert_email]

    content {
      name                    = var.alert_name
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
  dynamic "sms_receiver" {
    for_each = var.alert_sms_number != null && var.alert_sms_country != null ? [var.alert_sms_number] : []

    content {
      name         = var.alert_name
      country_code = var.alert_sms_country
      phone_number = sms_receiver.value
    }
  }
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
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

resource "azurerm_monitor_activity_log_alert" "service_health_incidents" {
  name                = "alrt-service-health-incidents"
  resource_group_name = module.global_resource_group.name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
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
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

resource "azurerm_monitor_activity_log_alert" "service_health_maintenance" {
  name                = "alrt-service-health-maintenance"
  resource_group_name = module.global_resource_group.name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
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
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

resource "azurerm_monitor_activity_log_alert" "service_health_advisory" {
  name                = "alrt-service-health-advisory"
  resource_group_name = module.global_resource_group.name
  location            = module.global_resource_group.location
  scopes              = ["/subscriptions/${var.subscription_id}"]
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
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  for_each = local.service_health_alerts

  name                = each.value.name
  resource_group_name = module.global_resource_group.name
  location            = module.global_resource_group.location
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
    action_group_id = azurerm_monitor_action_group.alertme.id
  }
  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}
