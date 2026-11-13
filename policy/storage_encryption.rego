# Open Policy Agent (OPA) Storage Encryption Policy
package azure.governance.storage

import future.keywords.in

deny[msg] {
    some resource in input.resource_changes
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] in ["create", "update"]
    
    config := resource.change.after
    config.enable_https_traffic_only != true
    
    msg := sprintf("Storage Account '%v' must have 'enable_https_traffic_only' set to true.", [resource.address])
}

deny[msg] {
    some resource in input.resource_changes
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] in ["create", "update"]
    
    config := resource.change.after
    config.min_tls_version != "TLS1_2"
    
    msg := sprintf("Storage Account '%v' must enforce minimum TLS version 'TLS1_2'. Current: '%v'.", [resource.address, config.min_tls_version])
}
