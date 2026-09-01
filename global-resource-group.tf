
resource "azurerm_resource_group" "global" {
  name     = "rg-global-${lower(var.location)}"
  location = var.location

  tags = local.tags
  lifecycle {
    ignore_changes = [tags.created]
  }
}

