# Open Policy Agent (OPA) Network Security Policy
package azure.governance.network

import future.keywords.in

# Disallow inbound 0.0.0.0/0 on SSH (22) and RDP (3389)
deny[msg] {
    some resource in input.resource_changes
    resource.type == "azurerm_network_security_rule"
    resource.change.actions[_] in ["create", "update"]
    
    rule := resource.change.after
    rule.direction == "Inbound"
    rule.access == "Allow"
    rule.source_address_prefix in ["*", "0.0.0.0/0", "Internet"]
    rule.destination_port_range in ["22", "3389", "*"]
    
    msg := sprintf("NSG rule '%v' allows unrestricted inbound traffic from '%v' on administrative port '%v'.", [resource.address, rule.source_address_prefix, rule.destination_port_range])
}
