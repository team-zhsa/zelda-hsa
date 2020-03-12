local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle.

local properties = {
  sprite = "enemies/tentacle_purple",
  life = 2,
  damage = 5,
  normal_speed = 64,
  faster_speed = 64,
  movement_create = function()
    return sol.movement.create("path_finding")
  end
}
behavior:create(enemy, properties)