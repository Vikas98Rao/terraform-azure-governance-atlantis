package azure.governance.tags_test

import future.keywords.in
import data.azure.governance.tags.deny

test_deny_missing_tags {
    mock_input := {
        "resource_changes": [
            {
                "address": "azurerm_resource_group.test",
                "type": "azurerm_resource_group",
                "change": {
                    "actions": ["create"],
                    "after": {}
                }
            }
        ]
    }
    count(deny) > 0 with input as mock_input
}

test_allow_compliant_tags {
    mock_input := {
        "resource_changes": [
            {
                "address": "azurerm_resource_group.test",
                "type": "azurerm_resource_group",
                "change": {
                    "actions": ["create"],
                    "after": {
                        "tags": {
                            "Environment": "prod",
                            "Owner": "vikas.rao",
                            "Project": "governance-platform",
                            "CostCenter": "CC-9021",
                            "ManagedBy": "Terraform"
                        }
                    }
                }
            }
        ]
    }
    count(deny) == 0 with input as mock_input
}
