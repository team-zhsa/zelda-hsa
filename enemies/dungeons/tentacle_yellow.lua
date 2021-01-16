local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle.

local properties = {
  sprite = "enemies/dungeons/tentacle_yellow",
  life = 4,
  damage = 4,
  normal_speed = 16,
  faster_speed = 32,
  movement_create = function()
    return sol.movement.create("random")
  end
}
behavior:create(enemy, properties)