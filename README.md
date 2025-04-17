# Infrastructure as Code (IaC) Repository

This repository contains Terraform code for provisioning and managing cloud infrastructure.

---
## 📁 Repository Structure

```
/
├── environments/       # Environment-specific infrastructure definitions
├── global-resources/   # Shared, cross-environment infrastructure
├── modules/            # Reusable Terraform modules
├── scripts/            # Helper scripts for Terraform workflows
└── README.md           # This file
```
---

## 📖 Folder Overview

### `/environments/`
Contains Terraform configurations for each individual environment (e.g. `dev`, `staging`, `prod`).  
Each subfolder defines infrastructure unique to that environment and references reusable modules from `/modules/`.

**Example:**
```
environments/
  dev/
    main.tf
    variables.tf
    terraform.tfvars
```

---

### `/global-resources/`
Contains Terraform configurations for resources that are shared across multiple environments or are global to the entire cloud account or organization.

**Examples:**
- VPC peering connections
- Global DNS zones
- Shared IAM roles
- Centralized state storage (e.g. S3 bucket + DynamoDB for Terraform state locking)

---

### `/modules/`
Contains reusable, self-contained Terraform modules that encapsulate groups of resources for common infrastructure patterns (e.g. `vpc`, `rabbitmq`, `eks-cluster`) and will be used in `/environments/`

**Each module should include:**
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `README.md` (optional but recommended)

---

### `/scripts/`
Contains helper scripts to automate or simplify Terraform-related workflows, such as:
- Plan and apply automation
- Linting and validation
- Backend bootstrapping

Scripts should be well-documented, portable, and avoid hardcoded sensitive values.

---

## ✅ Usage Guidelines

- Keep environment-specific resources isolated in `/environments/`.
- Place shared/global resources in `/global-resources/`.
- Encapsulate reusable infrastructure patterns as modules in `/modules/`.
- Use `/scripts/` to support and automate infrastructure operations.
- Follow Terraform best practices:
  - Use `terraform fmt` for consistent formatting.
  - Lint code with `tflint`.
  - Pin provider and module versions.
  - Never commit sensitive data to version control.

---

## 📦 Requirements

- [Terraform](https://www.terraform.io/downloads.html) vX.X.X or higher
- Cloud provider credentials configured locally (e.g., via AWS CLI, environment variables, or Vault)

---

## 🚀 Getting Started

1. Bootstrap global resources:
   ```
   cd global-resources/state-backend/
   terraform init
   terraform apply
   ```

2. Deploy an environment:
   ```
   cd environments/dev/
   terraform init
   terraform plan
   terraform apply
   ```

3. Use provided scripts for automation:
   ```
   ./scripts/terraform-plan.sh dev
   ```

---

## 📜 License

[MIT](LICENSE) — or your preferred license.

---

## 📞 Contact

For questions, ideas, or issues — open a GitHub issue or reach out to the infrastructure team.
