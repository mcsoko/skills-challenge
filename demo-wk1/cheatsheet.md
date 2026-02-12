# Terraform CLI Cheatsheet

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

A quick reference for common Terraform CLI commands, flags, and workflows.

## Table of Contents
- [Initialization](#initialization)
- [Formatting and Validation](#formatting-and-validation)
- [Plan & Apply](#plan-and-apply)
- [State Management](#state-management)
- [Debugging & Repair](#debugging-and-repair)
- [Outputs & Variables](#outputs-and-variables)
- [Modules & Imports](#modules-and-imports)
- [Utilities](#utilities)
- [Useful Links](#useful-links)

---

## Initialization

| Command | Description |
| :--- | :--- |
| `terraform init` | Initialize a new or existing Terraform configuration directory. |
| `terraform init -upgrade` | Upgrade providers and modules to the latest allowed versions. |

## Formatting and Validation

| Command | Description |
| :--- | :--- |
| `terraform fmt` | Reformat configuration files to canonical style. |
| `terraform fmt -recursive` | Reformat files in the current directory and all subdirectories. |
| `terraform validate` | Check whether the configuration is valid (syntax & types). |

## Plan and Apply

| Command / Flag | Description |
| :--- | :--- |
| `terraform plan` | Show changes required by the current configuration. |
| `terraform plan -out=tfplan` | Save the plan to a file for later apply (recommended for CI/CD). |
| `terraform apply` | Apply the changes required by the configuration. |
| `terraform apply tfplan` | Apply a previously saved plan file. |
| `terraform apply -auto-approve` | Apply changes without asking for interactive confirmation. |
| `terraform apply -target=<res>` | **Advanced:** Limit operation to a specific resource (e.g., `aws_instance.web`). |
| `terraform destroy` | Destroy all managed infrastructure. |

## State Management

| Command | Description |
| :--- | :--- |
| `terraform state list` | List resources in the current state. |
| `terraform state show <res>` | Show attributes of a single resource in the state. |
| `terraform state rm <res>` | Stop managing a resource (removes from state, does **not** delete object). |
| `terraform state mv <src> <dst>` | Rename a resource in the state file (preserves history when renaming in code). |
| `terraform apply -refresh-only` | Update state to match real-world infrastructure (Safe replacement for `refresh`). |

## Debugging and Repair

| Command | Description |
| :--- | :--- |
| `terraform console` | Open an interactive shell to test functions and variables. |
| `terraform force-unlock <id>` | Manually unlock the state if a previous apply crashed. |
| `terraform providers` | Show the providers required for the configuration. |
| `terraform graph` | Output the dependency graph in DOT format. |

## Outputs and Variables

| Command | Description |
| :--- | :--- |
| `terraform output` | Show all outputs. |
| `terraform output <name>` | Show a specific output value. |
| `terraform output -json` | Show all outputs in machine-readable JSON format. |
| `terraform apply -var="k=v"` | Set a variable value on the command line. |
| `terraform apply -var-file="f.tfvars"` | Set variables from a specific file. |

## Modules and Imports

| Command | Description |
| :--- | :--- |
| `terraform get` | Download and update modules mentioned in the configuration. |
| `terraform import <res> <id>` | **Legacy:** Import existing infrastructure into state (requires manual HCL). |

## Utilities

| Command | Description |
| :--- | :--- |
| `terraform version` | Show the current Terraform version. |
| `terraform -chdir=<dir> <cmd>` | Switch to a different directory before running a command. |
| `terraform <command> -help` | Show help for a specific command. |

---

## Useful Links

- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform Registry](https://registry.terraform.io/)