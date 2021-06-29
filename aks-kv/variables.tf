variable "location" {
  type    = string
  default = "eastus"
  #   default = "westeurope"
}

variable "env" {
  type        = string
  description = "Environment Name"
  default     = "prod02"
}

variable "tags" {
  type        = map(string)
  description = "Tag Name"
  default = {
    source = "devo"
  }
}
# variable "kv-name" {
#   type        = string
#   description = "Key Vault Name"
#   default     = "temo"
#   #   default     = "prod"
# }

variable "vnet_address_prefix" {
  description = "VNET address prefix"
  default     = "10.100.0.0/18"
}

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "10.100.0.0/20"
}

variable "kubversion" {
  description = "kubernetes version"
  default     = "1.20.7"
}
variable "vm_size" {
  description = "AKS Node Poll VM Size"
  default     = "Standard_DS2_v2"
}

variable "os_size" {
  description = "AKS Node os disk size in GB"
  default     = 50
}
variable "max_node" {
  description = "Max node number"
  default     = 4
}

variable "min_node" {
  description = "Min node number"
  default     = 2
}

variable "azure_ad_admin_groups" {
  description = "This list of groups Priniciple Ids who will be bounded to cluster-Admin role to get full Admin rights for this cluster. This used only if `azure_ad` is enabled"
  type        = list(string)
  default     = ["c6122f91-4a1b-420b-a836-183baa5a0cca"]

}
