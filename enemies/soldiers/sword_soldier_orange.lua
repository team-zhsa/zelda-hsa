local enemy = ...
local behavior = require("enemies/generic/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 12,
  damage = 6,
  normal_speed = 60,
  faster_speed = 65
}

behavior:create(enemy, properties)