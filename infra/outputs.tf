output "resource_group_name" {
  value = module.resource_group.name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_name" {
  value = module.aks.name
}

output "aks_rg" {
  value = module.resource_group.name
}

output "kubelet_identity_object_id" {
  value       = module.aks.kubelet_identity_object_id
  description = "Kubelet MSI object ID (has ACR pull role)."
}

output "kube_config_command" {
  description = "Run this to merge kubeconfig."
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.name} --overwrite-existing"
}