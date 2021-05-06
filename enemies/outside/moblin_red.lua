local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Moblin.

local properties = {
  sprite = "enemies/outside/moblin_red",
  life = 5,
  damage = 5,
  normal_speed = 40,
  faster_speed = 48
}

behavior:create(enemy, properties)