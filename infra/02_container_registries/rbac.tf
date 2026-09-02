locals {
  registries = {
    dmz  = azurerm_container_registry.dmz.id
    gold = azurerm_container_registry.gold.id
  }

  # GitHub needs push on the DMZ registry (az acr import writes there), pull on the DMZ
  # registry (scanning), and both on the gold registry (import target plus copa repush).
  # "Container Registry Data Importer and Data Reader" grants importImage/action and
  # registries/read, which az acr import needs but AcrPush/AcrPull (data-plane only) lack.
  github_roles = var.github_actions_principal_id == "" ? [] : ["AcrPush", "AcrPull", "Container Registry Data Importer and Data Reader"]

  github_assignments = {
    for pair in setproduct(keys(local.registries), local.github_roles) :
    "${pair[0]}-${lower(pair[1])}" => {
      registry = pair[0]
      role     = pair[1]
    }
  }
}

resource "azurerm_role_assignment" "github_actions" {
  for_each = local.github_assignments

  scope                = local.registries[each.value.registry]
  role_definition_name = each.value.role
  principal_id         = var.github_actions_principal_id
  principal_type       = "ServicePrincipal"
}

# Local operator gets read-only access so the demo can be inspected from a workstation
# without ever enabling the ACR admin user.
resource "azurerm_role_assignment" "operator_pull" {
  for_each = var.principal_id == "" ? {} : local.registries

  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}
