local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Crab: a basic enemy.

local properties = {
  sprite = "enemies/outside/crab",
  life = 2,
  damage = 8,
  normal_speed = 32,
  faster_speed = 40,
}
behavior:create(enemy, properties)