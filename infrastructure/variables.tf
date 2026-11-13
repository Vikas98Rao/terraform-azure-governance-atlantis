variable "environment" {
  type        = string
  description = "Target deployment environment."
  default     = "prod"
}

variable "location" {
  type        = string
  description = "Primary compliant Azure region."
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Resource prefix identifier."
  default     = "govcloud"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Virtual Network address space."
  default     = ["10.20.0.0/16"]
}

variable "subnet_prefixes" {
  type        = map(string)
  description = "CIDR prefixes for segmented subnets."
  default = {
    compute = "10.20.1.0/24"
    data    = "10.20.2.0/24"
  }
}

variable "tags" {
  type        = map(string)
  description = "Mandatory OPA tags required for all resources."
  default = {
    Environment = "prod"
    Owner       = "vikas.rao"
    Project     = "azure-governance"
    CostCenter  = "CC-5501"
    ManagedBy   = "Terraform-Atlantis"
  }
}
