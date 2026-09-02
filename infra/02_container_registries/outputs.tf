output "ACR_RESOURCE_GROUP" {
  value = azurerm_resource_group.this.name
}

output "ACR_AZURE_LOCATION" {
  value = azurerm_resource_group.this.location
}

output "ACR_DMZ_REGISTRY_NAME" {
  value = azurerm_container_registry.dmz.name
}

output "ACR_DMZ_REGISTRY_ENDPOINT" {
  value = azurerm_container_registry.dmz.login_server
}

output "ACR_DMZ_REGISTRY_ID" {
  value = azurerm_container_registry.dmz.id
}

output "ACR_GOLD_REGISTRY_NAME" {
  value = azurerm_container_registry.gold.name
}

output "ACR_GOLD_REGISTRY_ENDPOINT" {
  value = azurerm_container_registry.gold.login_server
}

output "ACR_GOLD_REGISTRY_ID" {
  value = azurerm_container_registry.gold.id
}
