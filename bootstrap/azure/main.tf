resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_storage_account" "state" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
# Your CLI identity needs Storage Blob Data Contributor before this resource.
resource "azurerm_storage_container" "state" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}
