data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  resource_token = substr(sha256("${data.azurerm_subscription.current.id}-${var.environment_name}-${var.location}"), 0, 10)

  tags = {
    "azd-env-name" = var.environment_name
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.environment_name}-${local.resource_token}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "uami-gh-federated-identity-${local.resource_token}"
  resource_group_name = azurerm_resource_group.this.name
}

