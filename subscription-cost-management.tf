resource "azurerm_subscription_cost_management_view" "sard" {
  name            = "SARDCostView - Month to date"
  display_name    = substr("SARD Cost View - Subscription: ${data.azurerm_subscription.current.display_name}", 0, 50)
  subscription_id = format("/%s/%s", "subscriptions", var.subscription_id)

  chart_type  = "Area"
  accumulated = true

  report_type = "Usage"
  timeframe   = "MonthToDate"

  dataset {
    granularity = "Monthly"

    aggregation {
      name        = "totalCost"
      column_name = "Cost"
    }

    #grouping {
    #  name  = "department"
    #  type  = "TagKey"
    #}
    sorting {
      direction = "Descending"
      name      = "totalCost"
    }
  }

  ## upto 3 pivots are allowed
  pivot {
    name = "ServiceName"
    type = "Dimension"
  }

  pivot {
    name = "ResourceType"
    type = "Dimension"
  }

  pivot {
    name = "ResourceGroupName"
    type = "Dimension"
  }
}

resource "azurerm_cost_management_scheduled_action" "this" {
  name         = "examplescheduledaction"
  display_name = "Weekly Report for this Month"

  view_id = azurerm_subscription_cost_management_view.sard.id

  email_address_sender = "sard@azure.com"
  email_subject        = "Cost Management Report"
  email_addresses      = var.alert_emails
  message              = "Hi all, take a look at SARD subscription spending this month!"

  frequency    = "Weekly"
  days_of_week = ["Friday"]
  hour_of_day  = 8
  start_date   = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "-1m"))}T00:00:00Z"
  end_date     = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "+1y"))}T00:00:00Z"
}

resource "azurerm_consumption_budget_subscription" "this" {
  name            = "example"
  subscription_id = format("/%s/%s", "subscriptions", var.subscription_id)

  amount     = 80
  time_grain = "Monthly"

  time_period {
    start_date = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "-1m"))}T00:00:00Z"
    end_date   = "9999-12-31T23:59:59+10:00"
  }

  filter {
    dimension {
      name = "SubscriptionID"
      values = [
        format("/%s/%s", "subscriptions", var.subscription_id)
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_groups = [
      azurerm_monitor_action_group.alertme.id,
    ]
  }

  notification {
    enabled        = true
    threshold      = 95.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.alertme.id,
    ]
  }
}
