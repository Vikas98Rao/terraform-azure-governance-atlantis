output "resource_group_name" {
  value = azurerm_resource_group.gov_rg.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.gov_vnet.id
}

output "storage_account_name" {
  value = azurerm_storage_account.secure_storage.name
}

output "storage_primary_endpoint" {
  value = azurerm_storage_account.secure_storage.primary_blob_endpoint
}
