output "LAYER_1_AZURE_RESOURCE_GROUP" {
  description = "Federated identities resource group."
  value       = azurerm_resource_group.this.name
}

output "LAYER_1_AZURE_LOCATION" {
  description = "Region of the federated identities resource group."
  value       = azurerm_resource_group.this.location
}

output "GITHUB_ACTIONS_CLIENT_ID" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "GITHUB_ACTIONS_PRINCIPAL_ID" {
  value = azurerm_user_assigned_identity.this.principal_id
}

output "GITHUB_ACTIONS_IDENTITY_NAME" {
  value = azurerm_user_assigned_identity.this.name
}

output "AZURE_PRINCIPAL_ID" {
  value = data.azurerm_client_config.current.object_id
}
