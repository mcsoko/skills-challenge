provider "minecraft" {
  address  = "localhost:25575"
  password = "terraform"
}

resource "minecraft_block" "diamond" {
  material = "minecraft:diamond_block"
  position = {
    x = 15
    y = 136
    z = 78
  }
}



locals {
  # Where to place the top-left of the grid in the world
  origin = { x = 0, y = 10, z = 0 }

  # Scale + density
  # pixel_size controls spacing between "pixels" in blocks
  # fill controls how many blocks to draw inside each pixel to avoid a dotted look
  pixel_size = 2
  fill       = 1

  material = "minecraft:purple_concrete"

  # Grid sampled from your image (20 columns x 34 rows)
  # '#' = filled, '.' = empty
  shape = [
    "#...................",
    "###.................",
    "#####...............",
    "######..............",
    "########............",
    "##########..........",
    "############........",
    "#############.......",
    "###############.....",
    "#################...",
    "##################..",
    "###################.",
    "###################.",
    "###################.",
    "###################.",
    ".##################.",
    "..#################.",
    "....###############.",
    "......#############.",
    ".......############.",
    ".........##########.",
    "...........########.",
    ".............######.",
    "..............#####.",
    "................###.",
    "..................##",
    "...................#",
  ]

  shape2 = [
  "...................#",
  ".................###",
  "...............#####",
  "..............######",
  "............########",
  "..........##########",
  "........############",
  ".......#############",
  ".....###############",
  "...#################",
  "..##################",
  ".###################",
  ".###################",
  ".###################",
  ".###################",
  ".##################.",
  ".#################..",
  ".###############....",
  ".#############......",
  ".############.......",
  ".##########.........",
  ".########...........",
  "######.............",
  "#####..............",
  "###................",
  "##..................",
  "#...................",
  ]

  placements = {
    left   = { x = -42, y = 60, z = 0 }
    center = { x = 0, y = 35, z = 0 }
    bottom = { x = 0, y = 0, z = 0 }
  }

  placements2 = {
    right = { x = 42, y = 35, z = 0 }

  }
  # Turn grid into "on pixels"
  pixels = flatten([
    for row_i, row in local.shape : [
      for col_i, ch in split("", row) : {
        row = row_i
        col = col_i
        on  = ch == "#"
      }
    ]
  ])

  # Turn grid into "on pixels"
  pixels2 = flatten([
    for row_i, row in local.shape2 : [
      for col_i, ch in split("", row) : {
        row = row_i
        col = col_i
        on  = ch == "#"
      }
    ]
  ])

  on_pixels = [for p in local.pixels : p if p.on]

  on_pixels2 = [for p in local.pixels2 : p if p.on]

  # Expand: for each placement -> for each on_pixel -> for each fill cell -> a block
  blocks = {
    for b in flatten([
      for name, origin in local.placements : [
        for p in local.on_pixels : [
          for fx in range(local.fill) : [
            for fy in range(local.fill) : {
              key = "${name}_${p.row}_${p.col}_${fx}_${fy}"
              x   = origin.x + (p.col * local.pixel_size) + fx
              y   = origin.y - (p.row * local.pixel_size) - fy
              z   = origin.z
            }
          ]
        ]
      ]
    ]) : b.key => b
  }

  # Expand: for each placement -> for each on_pixel -> for each fill cell -> a block
  blocks2 = {
    for b in flatten([
      for name, origin in local.placements2 : [
        for p in local.on_pixels2 : [
          for fx in range(local.fill) : [
            for fy in range(local.fill) : {
              key = "${name}_${p.row}_${p.col}_${fx}_${fy}"
              x   = origin.x + (p.col * local.pixel_size) + fx
              y   = origin.y - (p.row * local.pixel_size) - fy
              z   = origin.z
            }
          ]
        ]
      ]
    ]) : b.key => b
  }
}


resource "minecraft_block" "shape_instances" {
  for_each = local.blocks

  material = local.material
  position = { x = each.value.x, y = each.value.y, z = each.value.z }
}

resource "minecraft_block" "shape_instances2" {
  for_each = local.blocks2

  material = local.material
  position = { x = each.value.x, y = each.value.y, z = each.value.z }
}

