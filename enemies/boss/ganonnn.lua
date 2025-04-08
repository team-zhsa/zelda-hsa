local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Ropa.

local properties = {
  sprite = "enemies/boss/ganonnn",
  life = 10000,
  damage = 0,
  normal_speed = 420,
  faster_speed = 420,
}
behavior:create(enemy, properties)