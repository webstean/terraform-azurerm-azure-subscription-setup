locals {
  vwan_name = "vwan-global" ## You only have one, then multiple hubs per locaton (region), per environment
  vwan_sku  = var.virtual_wan_sku
}

resource "azurerm_virtual_wan" "this" {
  count = var.virtual_wan_id == null ? 1 : 0

  name                = local.vwan_name
  resource_group_name = module.global_resource_group.name
  location            = module.global_resource_group.location

  disable_vpn_encryption            = false
  allow_branch_to_branch_traffic    = false
  office365_local_breakout_category = "Optimize" ## Possible values include: Optimize, OptimizeAndAllow, All, None. Defaults to None.
  ## With Basic, the hubs are free!
  type = local.vwan_sku

  tags = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}
