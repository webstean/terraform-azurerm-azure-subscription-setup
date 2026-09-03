resource "azurerm_subscription_cost_management_view" "view1" {
  name            = "TerraformCostView"
  display_name    = "Azure Cost View - Subscription: ${data.azurerm_subscription.current.display_name}"
  subscription_id = format("/%s/%s", "subscriptions", data.azurerm_client_config.current.subscription_id)

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
  }

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

/*
resource "azurerm_cost_management_scheduled_action" "action1" {
  name         = "${azurerm_subscription_cost_management_view.view1.name}"

  display_name = "${azurerm_subscription_cost_management_view.view1.display_name}"

  view_id = azurerm_subscription_cost_management_view.view1.id

  add_action_group_ids = [azurerm_monitor_action_group.techalert1.id]

  frequency  = "Weekly"
  days_of_week = "Friday"
}
*/

/*
resource "azurerm_consumption_budget_management_group" "example" {
  name                = "example"
  management_group_id = azurerm_management_group.example.id

  amount     = 20
  time_grain = "Daily"

  time_period {
    start_date = "2022-06-01T00:00:00Z"
    end_date   = "2022-07-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        azurerm_resource_group.example.name,
      ]
    }

    tag = each.value.tags
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }

  notification {
    enabled        = false
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
*/
