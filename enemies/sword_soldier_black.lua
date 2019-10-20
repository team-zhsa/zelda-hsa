local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 10,
  damage = 4,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)
