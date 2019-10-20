local enemy = ...
local behavior = require("enemies/generic/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 10,
  damage = 4,
  normal_speed = 40,
  faster_speed = 48
}

behavior:create(enemy, properties)