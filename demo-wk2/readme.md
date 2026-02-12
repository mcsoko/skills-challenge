# Terraform Skills Challenge - Week 2 - Core Concepts Deep Dive

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

## Demo Objectives

This demo explores core Terraform concepts using a practical AWS web server deployment:

- **Terraform Config Blocks**: `resource`, `data`, `variable`, `output`, `check`
- **Resource Addressing & References**: Accessing resources with dot notation
- **Dynamic Expressions**: `for` loops, conditionals, and interpolation
- **Resource Graph & Dependencies**: Understanding implicit and explicit depends_on
- **Sensitive Variables**: Handling secrets securely
- **Terraform Modules**: Consuming public modules from the Registry
- **Terraform State**: Understanding state management and resource tracking

---

## Prerequisites

```bash
# Set Vault token (if using Vault data source)
export VAULT_TOKEN="your-token"

# Ensure AWS credentials are configured
export AWS_REGION=us-east-2
```

---

## Part 1: Terraform Configuration Blocks

### 1.1 Variables - Declaring Input Parameters

Variables are inputs to your configuration. They can be simple or sensitive.

**View the variables:**
- variables.tf

**Key concepts:**
- `variable "instance_count"` - standard input variable
- `variable "app_secret"` - **sensitive** = true marks it as sensitive (won't display in logs)
- `variable "vault_address"` - environment integration

**Talk track:**
> "Variables are how we parameterize our infrastructure. Notice `app_secret` has `sensitive = true`. This tells Terraform to redact this value from logs and console output, protecting secrets."

---

### 1.2 Data Sources - Querying Existing Infrastructure

Data sources read information from AWS without managing it.

**See data sources in action:**
- main.tf

Output shows:
- `data "aws_vpc" "default"` - Query the default VPC
- `data "aws_availability_zones" "available"` - List available AZs
- `data "aws_subnets" "default"` - Find default subnets
- `data "aws_subnet" "by_id"` - Get details for each subnet (using `for_each`)
- `data "aws_ami" "latest_linux"` - Find the latest Amazon Linux 2023 AMI
- `data "http" "endpoint"` - Check HTTP status of running instances
- `data "vault_generic_secret" "example"` - Retrieve secrets from Vault

**Talk track:**
> "Data sources let us query AWS without creating anything. We're discovering the default VPC, subnets in each AZ, and the latest AMI. This makes our code more portable—it adapts to any AWS account."

---

### 1.3 Resources - Declaring Infrastructure to Create

Resources are the infrastructure we actually provision.

**View all resources:**
- main.tf

Key resources:
- `aws_security_group` - Firewall rules
- `aws_iam_role` - IAM permissions
- `aws_iam_instance_profile` - Attach IAM role to EC2
- `aws_instance` - EC2 instances with `count = var.instance_count` (creates multiple)

**Talk track:**
> "Resources are what we're actually creating in AWS. Notice the EC2 instance uses `count` to create multiple instances. We'll see how references and addressing work next."

---

### 1.4 Outputs - Exposing Values from Your Configuration

Outputs expose data after `apply`, making it available to users or other configs.

**View outputs:**
- main.tf

Key outputs demonstrate different patterns:
- `website_url` - List comprehension (`for` loop)
- `http_status_code` - Map with `for` loop
- `az_subnet_instance_url` - Complex map structure
- `s3_bucket_name` - Module reference
- `vault` - Sensitive output (redacted in logs)

**Talk track:**
> "Outputs let us display useful information. `az_subnet_instance_url` is a sophisticated output that maps availability zones to subnets, instances, and URLs—all built with dynamic expressions."

---

### 1.5 Checks - Validating Assumptions

Checks assert conditions about your infrastructure without managing it.

**View checks:**
- main.tf

Two checks in this config:
1. `instance_az_count` - Validates `instance_count <= available_azs`
2. `health_check` - Validates HTTP 200 response from all instances

**Talk track:**
> "Checks are assertions about your infrastructure. The health check validates that all web servers are responding before we consider the deployment successful. If it fails, we see a detailed error message."

---

## Part 2: Resource Addressing and References

### 2.1 Referencing Resources with Dot Notation

Resources are referenced using: `resource_type.resource_name[index]`

**Examples from the code:**

```hcl
# Single resource reference
vpc_id = data.aws_vpc.default.id

# List index reference
subnet_id = data.aws_subnets.default.ids[0]

# For-each reference
az_to_subnet[local.az_names[count.index % length(local.az_names)]]

# Attribute access
url = "http://${each.value.public_dns}"
```

**View resource graph:**
```bash
terraform graph | head -50
```

**Talk track:**
> "Resource addressing is how we reference one resource from another. When we say `data.aws_vpc.default.id`, we're accessing the VPC's ID attribute. These references create dependency edges in Terraform's graph."

---

### 2.2 Implicit Dependencies

Dependencies are created automatically when you reference another resource.

**Trace a dependency chain:**
```bash
# The EC2 instance depends on the security group implicitly:
grep -A2 "vpc_security_group_ids" main.tf
```

**Explicit dependencies (when needed):**
```bash
grep "depends_on" main.tf
```

The `time_sleep` resource uses explicit `depends_on` to wait for instances before checking health.

**Talk track:**
> "Terraform automatically detects dependencies through references. When we reference a security group ID, Terraform knows the security group must exist before the instance. Explicit `depends_on` is rare—only use when the dependency isn't obvious."

---

## Part 3: Dynamic Expressions

### 3.1 For Loops - Iterating Over Collections

The `for` expression is used everywhere in this config.

**Example 1: Simple for-each on data source**
```bash
grep -A3 "data \"aws_subnet\" \"by_id\"" main.tf
```
Creates a separate data source for each subnet ID.

**Example 2: For loop in locals**
```bash
grep -A2 "az_to_subnet = " main.tf
```
Transforms a list of subnets into a map keyed by availability zone.

**Example 3: For loop in output**
```bash
grep -A5 "az_subnet_instance_url" main.tf
```
Maps instances by their AZ.

**Talk track:**
> "For loops transform data. Here we convert a list of subnets into a map indexed by AZ. This makes it easy to distribute instances across zones—look at line 113 where we index into this map using modulo arithmetic."

---

### 3.2 Conditionals - The ? : Operator

The ternary operator filters or selects based on conditions.

**Example in dynamic_tags:**
```bash
grep "dynamic_tags" main.tf
```

**Talk track:**
> "The `if` condition filters out empty tag values. `for k, v in var.extra_tags : k => v if v != ''` only includes non-empty tags."

---

### 3.3 Interpolation - Embedding Expressions in Strings

```bash
grep "echo.*Instance Index" main.tf
```

The user_data uses interpolation: `${count.index}` embeds the count index into the HTML.

**Talk track:**
> "String interpolation with `${}` lets us embed dynamic values. Each instance's HTML shows its unique index, making them distinguishable."

---

## Part 4: Resource Graph and Dependencies

### 4.1 Visualizing the Dependency Graph

```bash
# Generate and view the graph (requires Graphviz)
terraform graph > /tmp/graph.dot
cat /tmp/graph.dot | head -30
```

Or view the graph structure:
```bash
# List all implicit dependencies:
grep -E "vpc_id|subnet_id|security_group|iam_" main.tf
```

**Dependency flow:**
```
VPC (data) 
  └─> Subnets (data) 
      └─> Subnet Details (data)
          └─> EC2 Instances (resource with count)
              └─> HTTP Checks (data)
                  └─> Health Check (check)
```

**Talk track:**
> "The dependency graph ensures resources are created in the right order. AWS VPC must exist before subnets, subnets before instances, instances before health checks. Terraform computes this graph automatically."

---

### 4.2 Parallel Execution

Resources with no dependencies can be created in parallel.

**Talk track:**
> "Terraform creates independent resources in parallel. The security group and IAM role can be created simultaneously since neither depends on the other. This makes deployments faster."

---

## Part 5: Sensitive Variables

### 5.1 Declaring and Using Sensitive Variables

**View sensitive variable:**
```bash
grep -A3 "variable \"app_secret\"" variables.tf
```

**Usage in user_data:**
```bash
grep "echo.*APP_SECRET" main.tf
```

**View in state (note: Terraform marks it but state still contains value):**
```bash
terraform state show -json | grep -i "app_secret" || echo "Not in current state"
```

**Talk track:**
> "Sensitive variables are marked with `sensitive = true`. Terraform redacts them from console output and logs. However, they're still stored in the state file, so secure your state with encryption and access controls."

---

### 5.2 Sensitive Outputs

```bash
grep -B2 -A2 "sensitive = true" main.tf | grep -A2 "output"
```

Sensitive outputs are also redacted from `terraform output` commands.

**Talk track:**
> "Outputs can also be sensitive. The vault output containing secrets is redacted just like sensitive variables."

---

## Part 6: Terraform Modules

### 6.1 Using a Public Module

```bash
grep -A8 "module \"s3_bucket\"" main.tf
```

This uses the `terraform-aws-modules/s3-bucket/aws` module from the Terraform Registry.

**Initialize and fetch modules:**
```bash
terraform init
```

**View downloaded modules:**
```bash
ls -la .terraform/modules/
```

**Talk track:**
> "Modules are reusable packages of Terraform code. The S3 module encapsulates best practices for bucket creation—versioning, tagging, and security. We just pass variables; the module handles the complexity."

---

### 6.2 Module Outputs

```bash
grep "module.s3_bucket" main.tf
```

We reference the module's output to get the bucket name.

**Talk track:**
> "Modules expose outputs just like root configurations. We access them with `module.MODULE_NAME.OUTPUT_NAME`."

---

## Part 7: Terraform State

### 7.1 Understanding State

State is Terraform's source of truth about real infrastructure.

**View state structure:**
```bash
terraform state list
```

**Inspect a specific resource:**
```bash
terraform state show 'aws_instance.web_server[0]' 2>/dev/null || echo "Resource not yet created"
```

**View raw state file:**
```bash
cat terraform.tfstate | jq '.resources | length'
```

**Talk track:**
> "State maps Terraform configuration to real resources. When you run `terraform apply`, Terraform compares desired state (config) to current state (state file) to determine what to create, update, or destroy."

---

### 7.2 State Backend

```bash
grep -A5 "backend" terraform.tf
```

This config uses S3 backend with state locking.

**Talk track:**
> "By default, state is local (`terraform.tfstate`). In production, use a remote backend like S3 with locking to prevent concurrent modifications. Our config uses S3 with locking enabled."

---

### 7.3 State and Sensitivity

```bash
# Verify sensitive values are in state (they are, even though redacted in output)
terraform state show -json 2>/dev/null | grep -i secret || echo "Not in current state"
```

**Talk track:**
> "Sensitive values are stored in state but redacted from console output. Protect your state with encryption at rest and fine-grained access control."

---

## Full Workflow - Talk Track

### Setup
```bash
# 1. Initialize: download providers and modules
terraform init

# 2. Validate: check syntax
terraform validate

# 3. Format: apply style guidelines
terraform fmt -check
```

**Talk track:**
> "Initialization downloads the AWS, HTTP, Vault, and Time providers, plus the S3 module. Validation checks syntax. Formatting ensures consistent style."

### Planning
```bash
# Create a plan with necessary inputs
terraform plan -var="instance_count=2" -var="app_secret=my-secret-123"
```

**Talk track:**
> "The plan shows what Terraform will create. With `instance_count=2`, we'll create 2 EC2 instances in different AZs, distributed across subnets. Review the plan carefully before applying."

### Applying
```bash
terraform apply -var="instance_count=2" -var="app_secret=my-secret-123"
```

**Talk track:**
> "Apply provisions the infrastructure. Terraform creates the VPC, IAM roles, security groups, then instances in parallel. It waits 90 seconds for web server startup, then validates HTTP 200 responses."

### Viewing Outputs
```bash
terraform output
terraform output az_subnet_instance_url
terraform output vault  # Shows [redacted] for sensitive data
```

**Talk track:**
> "Outputs display key information: URLs, status codes, and the AZ-to-instance mapping. Sensitive outputs are redacted."

### Inspecting State
```bash
terraform state list
terraform state show aws_instance.web_server
```

**Talk track:**
> "State tracks every resource. You can inspect specific resources to see their current attributes."

### Cleanup
```bash
terraform destroy
```

**Talk track:**
> "Destroy removes all managed infrastructure and updates state. Non-managed resources (like things created manually) are left untouched."

---

## Key Takeaways

| Concept | Purpose | Example |
|---------|---------|---------|
| **Variables** | Parameterize configuration | `var.instance_count`, `var.app_secret` |
| **Data Sources** | Query existing infrastructure | `data.aws_vpc.default`, `data.aws_ami.latest_linux` |
| **Resources** | Declare infrastructure to create | `aws_instance.web_server` |
| **Outputs** | Expose values after apply | Website URLs, bucket names |
| **Checks** | Assert conditions | Health check validates HTTP 200 |
| **For Loops** | Iterate over data | Map subnets by AZ |
| **Modules** | Reuse configuration | S3 bucket best practices |
| **State** | Track real infrastructure | `terraform.tfstate` |
| **Sensitive** | Protect secrets | Redacted in logs, protected in state |

---

## Debugging Commands

```bash
# Enable debug logging
TF_LOG=DEBUG terraform plan

# Inspect graph
terraform graph | dot -Tpng > graph.png

# Validate specific file
terraform validate

# Check for unused variables
terraform plan -var-file=/dev/null 2>&1 | grep -i "unused"

# Force refresh state from AWS
terraform refresh

# View specific state attribute
terraform state show -json aws_instance.web_server[0] | jq '.instances[0].attributes.public_ip'
```

---

## Further Reading

- [Terraform Language Reference](https://www.terraform.io/language)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Modules Registry](https://registry.terraform.io)
- [State Locking & Backends](https://www.terraform.io/language/state/backends)


## Optional
```
export TF_LOG=DEBUG
```
- Add environment variable to show detailed debug for troubleshooting.

## Resources
[CLI Cheatsheet](./cheatsheet.md)