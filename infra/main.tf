locals {
  name_prefix = "${var.project_name}-${var.env}"
  tags        = merge(var.tags, { project = var.project_name, env = var.env })
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.tags
}

module "network" {
  source             = "./modules/network"
  rg_name            = module.resource_group.name
  location           = var.location
  vnet_name          = "${local.name_prefix}-vnet"
  address_space      = var.vnet_address_space
  aks_subnet_name    = "${local.name_prefix}-aks-snet"
  aks_subnet_cidr    = var.subnet_aks_cidr
  tags               = local.tags
}

module "acr" {
  source   = "./modules/acr"
  rg_name  = module.resource_group.name
  location = var.location
  name     = replace("${local.name_prefix}acr", "-", "")
  sku      = "Standard"
  tags     = local.tags
}

module "aks" {
  source                = "./modules/aks"
  rg_name               = module.resource_group.name
  location              = var.location
  name                  = "${local.name_prefix}-aks"
  node_count            = var.aks_node_count
  node_vm_size          = var.aks_node_vm_size
  subnet_id             = module.network.aks_subnet_id
  log_analytics_enabled = true
  tags                  = local.tags

  # Link ACR for image pulls (via role assignment)
  acr_id = module.acr.id
}