# Terraform Skills Challenge - Office Hours 1 - Demo Script

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

## Demo Objectives
- Review Terraform Core Workflow
    - Write - Author infrastructure as code
    - Plan - Preview changes before applying
    - Apply - Provision reproducible infrastructure 
- Use Terraform Core Workdlow Commands
    - `terraform init`
    - `terraform plan`
    - `terraform apply`
    - `terraform destroy`
- Review
    - Terraform state
    - `terraform.lock.hcl`
    - `.terraform`

## Review Terraform Core Workflow

### Write - Author infrastructure as code
Create a new directory to store the IaC files, switch to that directory
```
mkdir demo-wk1
cd demo-wk1
```
Create files to hold our Terraform configuration
```
touch main.tf
touch terraform.tf
``` 
Add a required provider to terraform.tf
```terraform
terraform {
   required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
  }
  required_version = "~> 1.2"
}
```
Initialize the configuration
```
terraform init
```
Review `.terraform.lock.hcl` - see the provider selections  <br>
<br>
Configure the provider in main.tf
```terraform
provider "aws" {
  region = "us-west-2"
}
```
Describe a resource as code
```
resource "aws_s3_bucket" "this" {
  bucket = "my-skills-challenge-bucket-wk1"
  tags = {
    ManagedBy = "terraform"
    CreatedBy       = "soko"
  }
}
```
Validate the configuration
```
terraform validate
```
Format the code to Terraform style guidelines
```
terraform fmt
```

### Plan - Preview changes before applying
```
terraform plan
```
Review the output and note the CRUD operations Terraform plans to take

### Apply - Provision reproducible infrastructure
```
terraform apply
```
Review the plain again, and answer `yes` to proceed with applying the config

### Review the State File & Real World Resources
- Check out both the `terraform.tfstate` and the resource in the AWS console 
- Delete the S3 bucket in the AWS console
- Run `terraform plan` and notice it says it will create the bucket again
- Apply the configration `terraform apply --auto-approve`

## Destroy the Resources
```
terraform destroy
```
- This will show a plan of what it will destroy
- Review the plan and answer `yes` to destroy the reource in AWS console and remove it from state.


## AWS Creds
AWS CLI must be configured in order for this to work
- `doormat login`
- `doormat aws list`
- `doormat aws console --role`
- `doormat aws export --account`