# Open Policy Agent (OPA) Region Restriction Policy
package azure.governance.regions

import future.keywords.in

allowed_regions := ["eastus", "eastus2", "centralus", "westeurope"]

deny[msg] {
    some resource in input.resource_changes
    resource.change.actions[_] in ["create", "update"]
    
    location := lower(resource.change.after.location)
    not location in allowed_regions
    
    msg := sprintf("Resource '%v' (%v) is being provisioned in non-compliant region '%v'. Allowed regions: %v", [resource.address, resource.type, location, allowed_regions])
}
