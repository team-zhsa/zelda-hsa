local enemy = ...

local behavior = require("enemies/generic/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 4,
  normal_speed = 30,
  faster_speed = 50,
}

behavior:create(enemy, properties)
