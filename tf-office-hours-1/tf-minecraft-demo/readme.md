# Terraform Minecraft Demo

Add the minecraft provider to `required_providers`
```terraform
terraform {
  required_providers {
    minecraft = {
      source  = "HashiCraft/minecraft"
      version = "~> 0.1.1"
    }
  }
}
```
Initialize the Terraform configuration
```
terraform init
```
Configure the provider in main.tf
```terraform
provider "minecraft" {
  address  = "localhost:25575"
  password = "terraform"
}
```
Describe a resource as code
```terraform

resource "minecraft_block" "diamond" {
  material = "minecraft:diamond_block"
  position = {
    x = 0
    y = 97
    z = 0
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
Plan the changes before applying
```
terraform plan
```
Review the output and note the CRUD operations Terraform plans to take <br>
Provision the reproducible infrastructure
```
terraform apply
```
Review the plan again and answer `yes` to proceed <br>
Review the state file and the minecraft game <br>
Destroy the resource
```
terraform destroy
```
Review the plan and answer `yes` to destroy the resource in minecraft and remove it from state
### Try with the more complex code
```terraform
locals {
  origin = { x = 0, y = 94, z = 0 }

  blocks = {
    # 5x5 iron platform
    for c in flatten([
      for dx in range(-2, 3) : [
        for dz in range(-2, 3) : {
          key = "base_${dx}_${dz}"
          x   = local.origin.x + dx
          y   = local.origin.y
          z   = local.origin.z + dz
          mat = "minecraft:iron_block"
        }
      ]
    ]) : c.key => { x = c.x, y = c.y, z = c.z, mat = c.mat }
  }

  beacon = {
    "beacon" = { x = local.origin.x, y = local.origin.y + 1, z = local.origin.z, mat = "minecraft:beacon" }
    "glass"  = { x = local.origin.x, y = local.origin.y + 2, z = local.origin.z, mat = "minecraft:glass" }
  }

  all = merge(local.blocks, local.beacon)
}

resource "minecraft_block" "diamond" {
  for_each = local.all

  material = each.value.mat
  position = {
    x = each.value.x
    y = each.value.y
    z = each.value.z
  }
}
```