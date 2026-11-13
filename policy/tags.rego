# Open Policy Agent (OPA) Tag Governance Policy
package azure.governance.tags

import future.keywords.in

required_tags := ["Environment", "Owner", "Project", "CostCenter", "ManagedBy"]

# Check all created or modified resources in the Terraform planned changes
deny[msg] {
    some resource in input.resource_changes
    resource.change.actions[_] in ["create", "update"]
    
    # Check for missing tags object
    not resource.change.after.tags
    msg := sprintf("Resource '%v' (%v) has no tags defined. Required tags: %v", [resource.address, resource.type, required_tags])
}

deny[msg] {
    some resource in input.resource_changes
    resource.change.actions[_] in ["create", "update"]
    resource.change.after.tags
    
    some tag in required_tags
    not resource.change.after.tags[tag]
    msg := sprintf("Resource '%v' (%v) is missing mandatory tag: '%v'", [resource.address, resource.type, tag])
}
