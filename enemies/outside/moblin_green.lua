local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Green Moblin.

local properties = {
  sprite = "enemies/outside/moblin(2)",
  life = 16,
  damage = 12,
  normal_speed = 40,
  faster_speed = 48
}

behavior:create(enemy, properties)