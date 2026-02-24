resource "random_string" "dns" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# Optional Log Analytics (Enable Container Insights)
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_enabled ? 1 : 0
  name                = "${var.name}-law"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.name}-${random_string.dns.result}"

  default_node_pool {
    name                = "sys"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.subnet_id
    type                = "VirtualMachineScaleSets"
    only_critical_addons_enabled = false
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"   # azure CNI
    network_policy = "azure"
    outbound_type  = "loadBalancer"
  }

  azure_policy_enabled = false

  oms_agent {
    enabled                    = var.log_analytics_enabled
    log_analytics_workspace_id = var.log_analytics_enabled ? azurerm_log_analytics_workspace.this[0].id : null
  }

  sku_tier = "Free"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

# Grant Kubelet MSI permission to pull from ACR
data "azurerm_container_registry" "acr" {
  id = var.acr_id
}

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}