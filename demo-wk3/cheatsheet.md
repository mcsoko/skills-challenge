# Terraform Quick Reference

> Short, practical snippets for plan/import, state cleanup, logging, and HCP Terraform.

---

## Config-Driven Import

**Workflow**
1. Run plan with config generation:
   - `terraform plan -generate-config-out=generated.tf`
2. Review the generated resource block.
3. Copy the resource into your main `.tf` config.
4. Remove any conflicting arguments, then re-run plan.

**Common conflict example**
The `aws_instance` resource allows `ipv6_address_count` *or* `ipv6_addresses`, but not both.
Remove one and re-run `terraform plan`.

**Import block example**
```terraform
import {
  id = ""
  to = new_resource.address
}
```

---

## Remove From State (Keep Resource)

Remove a resource from state without destroying it. Also comment out or delete it from config to avoid drift.

```terraform
removed {
  from = <resource address>

  lifecycle {
    destroy = false
  }
}
```

---

## Debug Logging

```bash
export TF_LOG=DEBUG
export TF_LOG_CORE=TRACE
export TF_LOG_PROVIDER=TRACE
export TF_LOG_PATH=
```

---

## Workspace Contents (Local vs HCP)

HCP Terraform workspaces and local working directories serve the same purpose, but they store their data differently.

| Component | Local Terraform | HCP Terraform |
| :--- | :--- | :--- |
| Terraform configuration | On disk | In linked version control repository, or periodically uploaded via API/CLI |
| Variable values | As .tfvars files, as CLI arguments, or in shell environment | In workspace |
| State | On disk or in remote backend | In workspace |
| Credentials and secrets | In shell environment or entered at prompts | In workspace, stored as sensitive variables |

---

## HCP Terraform Block

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
  }

  cloud {
    organization = "rakatan"
    workspaces {
      tags = ["test-cli"]
    }
  }

  required_version = "~> 1.2"
}
```