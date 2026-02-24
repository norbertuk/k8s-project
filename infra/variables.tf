variable "project_name" {
  description = "Project short name (used in resource names)."
  type        = string
}

variable "location" {
  description = "Azure region (e.g., westeurope, uksouth)."
  type        = string
  default     = "eastus"
}

variable "env" {
  description = "Environment name (dev|test|prod)."
  type        = string
  default     = "dev"
}

variable "aks_node_count" {
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_aks_cidr" {
  type        = string
  default     = "10.20.30.0/24"
}

variable "tags" {
  type        = map(string)
  default     = {
    owner = "norbert.soltesz@verint.com"
    Project = "learn k8s automation"
  }
}
