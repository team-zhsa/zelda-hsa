local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle.

local properties = {
  sprite = "enemies/dungeons/tentacle_purple",
  life = 2,
  damage = 5,
  normal_speed = 40,
  faster_speed = 40,
  movement_create = function()
    return sol.movement.create("random")
  end
}
behavior:create(enemy, properties)