# Terraform-Based Azure Infrastructure Automation & Governance

[![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Governance_CI-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Atlantis](https://img.shields.io/badge/Atlantis-GitOps_PR_Workflow-438EFF?logo=atlantis&logoColor=white)](https://www.runatlantis.io/)
[![OPA](https://img.shields.io/badge/OPA-Policy_as_Code-567482?logo=open-policy-agent&logoColor=white)](https://www.openpolicyagent.org/)

An enterprise GitOps and Policy-as-Code governance platform for Microsoft Azure. Automates Terraform pull-request planning, state locks, and reviews via Atlantis, while enforcing strict compliance and security guardrails using Open Policy Agent (OPA / Rego) and GitHub Actions.

---

## 1. GitOps & Policy Enforcement Workflow

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Engineer
    participant GH as GitHub Pull Request
    participant GHA as GitHub Actions CI
    participant Atl as Atlantis Server
    participant OPA as OPA / Conftest
    participant Az as Microsoft Azure

    Dev->>GH: Open PR (IaC Modifications)
    par Automated GHA Gate
        GH->>GHA: Trigger PR Check
        GHA->>GHA: terraform fmt & validate
        GHA->>OPA: conftest test tfplan.json
        OPA-->>GHA: Policy Pass / Fail Matrix
        GHA-->>GH: Post Status Check
    and Atlantis GitOps
        GH->>Atl: Webhook Event
        Atl->>Atl: atlantis plan (Acquires Lock)
        Atl-->>GH: Comment Speculative Plan Diff
    end

    Dev->>GH: Review & Peer Approval
    Dev->>GH: Comment: 'atlantis apply'
    GH->>Atl: Trigger Apply
    Atl->>OPA: Verify Conftest Policies
    Atl->>Az: terraform apply
    Atl-->>GH: Report Success & Merge PR
```

---

## 2. Policy-as-Code Guardrail Matrix (Rego)

| Guardrail Policy | Target Resource | Enforcement Rule | Business Impact |
| :--- | :--- | :--- | :--- |
| **`tags.rego`** | All Azure Resources | Must include `Environment`, `Owner`, `Project`, `CostCenter`, `ManagedBy` | FinOps accountability & automated chargeback |
| **`regions.rego`** | All Resource Groups | Prohibits provisioning outside `eastus`, `eastus2`, `centralus`, `westeurope` | Data residency compliance & regulatory adherence |
| **`network_rules.rego`** | `azurerm_network_security_rule` | Strictly blocks inbound `0.0.0.0/0` on port `22` (SSH) and `3389` (RDP) | Eliminates brute-force exposure |
| **`storage_encryption.rego`** | `azurerm_storage_account` | Requires `enable_https_traffic_only = true` and `min_tls_version = "TLS1_2"` | Zero-trust encryption in transit |

---

## 3. Directory Layout

```
.
├── atlantis.yaml                   # Atlantis server-side GitOps configuration
├── .github/
│   └── workflows/
│       └── terraform-governance.yml # GitHub Actions PR governance workflow
├── policy/                         # Open Policy Agent (OPA) Rego definitions
│   ├── tags.rego                   # Tag taxonomy enforcement
│   ├── regions.rego                # Permitted Azure regional boundaries
│   ├── network_rules.rego          # Ingress NSG perimeter controls
│   ├── storage_encryption.rego     # In-transit TLS and HTTPS requirements
│   └── tests/
│       └── governance_test.rego    # Automated test cases validating Rego policies
├── infrastructure/
│   ├── main.tf                     # Compliant cloud resource declarations
│   ├── variables.tf                # Parameter declarations with validation
│   ├── outputs.tf                  # Exported state outputs
│   └── versions.tf                 # Provider constraints and backend state
└── examples/
    └── terraform.tfvars.example    # Compliant sample variables
```

---

## 4. Atlantis Configuration (`atlantis.yaml`)

Atlantis runs pull request planning and execution through server-side webhooks:

- **Autoplan:** Automatically triggers `atlantis plan` when `.tf` files or `.rego` policies are modified.
- **Pre-Apply Policy Check:** Executes `conftest test` against the generated `tfplan.json` prior to permitting `atlantis apply`.
- **Apply Requirements:** Mandates that PRs must be approved and mergeable before state changes can be applied to production.

---

## 5. Local Policy Verification

Engineers can validate their Terraform plan against OPA policies locally before raising pull requests:

```bash
# 1. Initialize and generate plan JSON
cd infrastructure
terraform init -backend=false
terraform plan -var-file="../examples/terraform.tfvars.example" -out=tfplan.bin
terraform show -json tfplan.bin > tfplan.json

# 2. Test against OPA Rego policies with Conftest
conftest test tfplan.json --policy ../policy/

# 3. Execute Rego unit tests
conftest verify --policy ../policy/
```
