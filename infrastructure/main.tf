# ==============================================================================
# Terraform-Based Azure Infrastructure Automation & Governance
# Compliant Resource Definitions adhering to OPA Policy Guardrails
# ==============================================================================

resource "azurerm_resource_group" "gov_rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "gov_vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.gov_rg.location
  resource_group_name = azurerm_resource_group.gov_rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "compute" {
  name                 = "snet-compute-${var.environment}"
  resource_group_name  = azurerm_resource_group.gov_rg.name
  virtual_network_name = azurerm_virtual_network.gov_vnet.name
  address_prefixes     = [var.subnet_prefixes["compute"]]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data-${var.environment}"
  resource_group_name  = azurerm_resource_group.gov_rg.name
  virtual_network_name = azurerm_virtual_network.gov_vnet.name
  address_prefixes     = [var.subnet_prefixes["data"]]
}

# Network Security Group strictly compliant with OPA (No 0.0.0.0/0 on Port 22)
resource "azurerm_network_security_group" "gov_nsg" {
  name                = "nsg-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.gov_rg.location
  resource_group_name = azurerm_resource_group.gov_rg.name

  security_rule {
    name                       = "Allow-Internal-VNet-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_address_space[0]
    destination_address_prefix = var.subnet_prefixes["compute"]
  }

  security_rule {
    name                       = "Deny-All-Internet-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "compute_assoc" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.gov_nsg.id
}

# Compliant Secure Storage Account (HTTPS only, TLS 1.2 minimum)
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "secure_storage" {
  name                     = "st${var.project_name}${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.gov_rg.name
  location                 = azurerm_resource_group.gov_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 14
    }
  }

  tags = var.tags
}
