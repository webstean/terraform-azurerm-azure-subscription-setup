locals {
  vwan_name = "vwan-${lower(var.location)}"
  vwan_sku  = "Basic" ## Possible values include: Basic and Standard. Defaults to Standard.
}

resource "azurerm_virtual_wan" "this" {
  count = var.vwan_id == null ? 1 : 0

  name                = local.vwan_name
  resource_group_name = azurerm_resource_group.global.name
  location            = azurerm_resource_group.global.location

  disable_vpn_encryption            = false
  allow_branch_to_branch_traffic    = false
  office365_local_breakout_category = "Optimize" ## Possible values include: Optimize, OptimizeAndAllow, All, None. Defaults to None.
  ## With Basic, the hubs are free!
  type = local.vwan_sku

  tags = { for key, value in azurerm_resource_group.global.tags : key => value if lower(key) != "created" }
}
