locals {
  # Deterministic per-environment suffix so ACR names stay globally unique and stable
  # across re-provisions of the same azd environment.
  resource_token = substr(sha256("${var.subscription_id}-${var.environment_name}-${var.location}"), 0, 10)

  tags = {
    "azd-env-name" = var.environment_name
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.environment_name}"
  location = var.location
  tags     = local.tags
}

# CSSC "Acquire" stage: external images land here first and are treated as untrusted
# until they have been scanned and attested.
resource "azurerm_container_registry" "dmz" {
  name                = "acrdmz${local.resource_token}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = var.acr_sku

  admin_enabled          = false
  anonymous_pull_enabled = false

  tags = merge(local.tags, {
    "cssc-stage" = "acquire"
    "purpose"    = "dmz-quarantine"
  })
}

# CSSC "Catalog" stage: the golden registry. Only images promoted out of quarantine
# land here, and they are continuously rescanned and patched in place.
resource "azurerm_container_registry" "gold" {
  name                = "acrgold${local.resource_token}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = var.acr_sku

  admin_enabled          = false
  anonymous_pull_enabled = false

  tags = merge(local.tags, {
    "cssc-stage" = "catalog"
    "purpose"    = "gold-standard"
  })
}
