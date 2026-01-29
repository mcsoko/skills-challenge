provider "minecraft" {
  address  = "localhost:25575"
  password = "terraform"
}

# resource "minecraft_block" "diamond" {
#   material = "minecraft:diamond_block"
#   position = {
#     x = 0
#     y = 97
#     z = 0
#   }
# }



















# locals {
#   origin = { x = 0, y = 94, z = 0 }

#   blocks = {
#     # 5x5 iron platform
#     for c in flatten([
#       for dx in range(-2, 3) : [
#         for dz in range(-2, 3) : {
#           key = "base_${dx}_${dz}"
#           x   = local.origin.x + dx
#           y   = local.origin.y
#           z   = local.origin.z + dz
#           mat = "minecraft:iron_block"
#         }
#       ]
#     ]) : c.key => { x = c.x, y = c.y, z = c.z, mat = c.mat }
#   }

#   beacon = {
#     "beacon" = { x = local.origin.x, y = local.origin.y + 1, z = local.origin.z, mat = "minecraft:beacon" }
#     "glass"  = { x = local.origin.x, y = local.origin.y + 2, z = local.origin.z, mat = "minecraft:glass" }
#   }

#   all = merge(local.blocks, local.beacon)
# }

# resource "minecraft_block" "diamond" {
#   for_each = local.all

#   material = each.value.mat
#   position = {
#     x = each.value.x
#     y = each.value.y
#     z = each.value.z
#   }
# }