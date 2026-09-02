/*
# Wait 10 seconds for the network watcher to be created as a byproduct of the VNet creation
resource "time_sleep" "wait_10_seconds_for_network_watcher_creation" {
  create_duration = "10s"

  depends_on = [azurerm_virtual_network.this]
}

# Network Watcher — one per region per subscription is the norm; Azure will reject a
# duplicate if one already exists in this region, so remove/import this resource if so.
data "azurerm_network_watcher" "this" {
  name                = "NetworkWatcher_${lower(var.location)}"
  resource_group_name = "NetworkWatcherRG"
  depends_on          = [azurerm_virtual_network.this]
}
*/
