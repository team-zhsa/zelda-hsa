local enemy = ...

local behavior = require("enemies/generic/towards_hero")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 8,
  damage = 6,
  normal_speed = 40,
  faster_speed = 50,
}

behavior:create(enemy, properties)
