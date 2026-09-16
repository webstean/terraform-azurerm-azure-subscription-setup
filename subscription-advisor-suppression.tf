
data "azurerm_advisor_recommendations" "all" {}

data "azurerm_advisor_recommendations" "automation_account" {
  filter_by_category     = ["Security"]
  filter_by_resource_ids = [azurerm_automation_account.this.id]
}

locals {
  automation_account_variable_encryption_recommendations = [
    for recommendation in data.azurerm_advisor_recommendations.automation_account.recommendations : recommendation
    if(
      strcontains(lower(recommendation.recommendation_name), "variable") && strcontains(lower(recommendation.recommendation_name), "encrypt")
      ) || (
      strcontains(lower(recommendation.description), "variable") && strcontains(lower(recommendation.description), "encrypt")
    )
  ]
}

resource "azurerm_advisor_suppression" "automation_account_variables_should_be_encrypted" {
  name              = "automation-account-variables-should-be-encrypted"
  recommendation_id = local.automation_account_variable_encryption_recommendations[0].recommendation_name
  resource_id       = azurerm_automation_account.this.id
  ## ttl               = "01:00:00:00" ## omit to suppress indefinitely
}

output "advisor_suppression_candidates" {
  description = "Advisor recommendations across the subscription that can be used as suppression candidates."
  sensitive   = false
  value = [
    for recommendation in data.azurerm_advisor_recommendations.all.recommendations : {
      advisor_recommendation_id = recommendation.id
      category                  = recommendation.category
      description               = recommendation.description
      impact                    = recommendation.impact
      recommendation_id         = recommendation.recommendation_name
      recommendation_type_id    = recommendation.recommendation_type_id
      resource_name             = recommendation.resource_name
      resource_type             = recommendation.resource_type
      suppression_names         = recommendation.suppression_names
      updated_time              = recommendation.updated_time
    }
  ]
}
